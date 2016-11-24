//
//  GDMapView.m
//  GDMap
//
//  Created by zhao on 16/10/19.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import "GDMapView.h"
#import "CustomPinAnnotationView.h"
#import "CustomAnnotation.h"
#import "MapNavigationManager.h"
#import "CommonUtility.h"

#define RightCallOutTag 1
#define LeftCallOutTag 2

@interface GDMapView ()<MAMapViewDelegate, AMapSearchDelegate, SelectCityAndAddressViewDelagate, UISearchBarDelegate>

@property (nonatomic, strong) MAMapView *mapView; /**< 高德地图*/
@property (nonatomic, strong) AMapSearchAPI *searchApi; /**< 搜索API*/

@property (nonatomic, strong) MAAnnotationView *userLocationAnnotationView; /**<带箭头的自身定位点*/
@property (nonatomic, strong) CustomAnnotation *lastCustomAn; /**< 上个标注*/
@property (nonatomic, strong) MAPointAnnotation *lastPointAn; /**< */

@property (nonatomic, assign) BOOL isFirstLocation;/**< 第一次定位成功*/
@property (nonatomic, strong) UIButton *locationBtn;/**< 重新定位btn*/

@end

@implementation GDMapView

// 快速初始化
+ (instancetype)initWithFrame:(CGRect)frame
{
    return [[self alloc] initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if([super initWithFrame:frame])
    {
        // 初始化地图
        self.mapView = [[MAMapView alloc] initWithFrame:self.bounds];
        self.mapView.delegate = self;
        // 把地图添加至view
        [self addSubview:self.mapView];
        
        // 是否显示用户位置
        self.mapView.showsUserLocation = YES;
        // 追踪用户的位置与方向更新
        self.mapView.userTrackingMode = MAUserTrackingModeFollow;
        // 是否支持单击地图获取POI信息
        self.mapView.touchPOIEnabled = YES;
        // 罗盘原点位置
        self.mapView.compassOrigin = CGPointMake(12, 136);
        [self.mapView setCompassImage:[UIImage imageNamed:@"compass"]];
        
        // 搜索
        self.searchApi = [[AMapSearchAPI alloc] init];
        self.searchApi.delegate = self;
        
        self.isFirstLocation = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self addSubview:self.locationBtn];
    self.selectView.selectDelegate = self;
    self.selectView.searchBar.delegate = self;
}

- (void)dealloc
{
    [self.selectView removeObserver:self forKeyPath:@"cityBtn.titleLabel.text"];
}

/**
 *  点击定位按钮
 */
- (void)touchLocationButton:(UIButton *)loBtn
{
    // 是否显示用户位置
    self.mapView.showsUserLocation = YES;
    [self.mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
    // 当当前屏幕下可视地图太大，则缩放比例尺
    if(self.mapView.zoomLevel <= 12)
    {
        [self.mapView setZoomLevel:18 atPivot:self.center animated:YES];
    }
}

#pragma mark -- MAMapViewDelegate
#pragma mark -- 位置更新
// 位置更新 会进行定位回调
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (userLocation != nil)
    {
        self.userLocation = userLocation;
        if(self.isFirstLocation) // 第一次定位
        {
            [self searchReGeocodeWithCoordinate:userLocation.location.coordinate];
        }
    }
    // 让定位箭头随着方向旋转
    if (!updatingLocation && self.userLocationAnnotationView != nil)
    {
        [UIView animateWithDuration:0.1 animations:^{
            
            double degree = userLocation.heading.trueHeading - self.mapView.rotationDegree;
            self.userLocationAnnotationView.transform = CGAffineTransformMakeRotation(degree * M_PI / 180.f);
        }];
    }
}

#pragma mark -- 创建MAAnnotationView

// 根据anntation生成对应的View
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    // 自己的位置annotation，结合表示方向的箭头
    if([annotation isKindOfClass:[MAUserLocation class]])
    {
        static NSString *userLocationStyleReuseIndetifier = @"userLocationStyleReuseIndetifier";
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:userLocationStyleReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:userLocationStyleReuseIndetifier];
        }
        annotationView.image = [UIImage imageNamed:@"userPosition"];
        self.userLocationAnnotationView = annotationView;
        
        return annotationView;
    }
    // 点选或长按出现的定位点annotation
    if ([annotation isKindOfClass:[CustomAnnotation class]])
    {
        CustomPinAnnotationView *customAnView = (CustomPinAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if(customAnView == nil)
        {
            customAnView = [[CustomPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
        }
        
        customAnView.canShowCallout= YES;// 设置气泡可以弹出，默认为NO
        customAnView.animatesDrop = YES;// 设置标注动画显示，默认为NO
        customAnView.draggable = YES; // 设置标注可被拖动，默认为NO
        
        // 更改点标注的图片、位置
        customAnView.image = [UIImage imageNamed:@"locate"];
        customAnView.centerOffset = CGPointMake(0, -12);
        
        // 设置显示在气泡view的tag值
        customAnView.leftCalloutAccessoryView.tag = LeftCallOutTag;
        customAnView.rightCalloutAccessoryView.tag = RightCallOutTag;
        
        return customAnView;
    }
    return nil;
}

#pragma mark -- 点击气泡左右两侧的view

// 标注view的左右两侧view(必须继承自UIControl)被点击时，触发该回调
- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if([view.annotation isKindOfClass:[CustomAnnotation class]])
    {
        if(control.tag == LeftCallOutTag) // 点击气泡左侧view
        {
             // 导航
            [MapNavigationManager defaultNavigationManager].userLocation = self.userLocation;
            [[MapNavigationManager defaultNavigationManager] mapNavigationWithDestination:[view.annotation coordinate]];
        }
        else if(control.tag == RightCallOutTag)// 点击气泡右侧view
        {
            self.jumpRoutePlanVCBlock();// 界面跳转
        }
    }
}

#pragma mark -- 单击、长按地图

// 单击地图使用该回调获取POI信息
- (void)mapView:(MAMapView *)mapView didTouchPois:(NSArray *)pois
{
    if (pois.count == 0)
    {
        [self.mapView removeAnnotation:self.lastCustomAn];
        return;
    }
    for (MATouchPoi *touchPoi in pois)
    {
        // 改变地图的中心点
        [self.mapView setCenterCoordinate:touchPoi.coordinate animated:YES];
        // POI ID查询接口
        AMapPOIIDSearchRequest *poiIDRequset = [[AMapPOIIDSearchRequest alloc] init];
        poiIDRequset.uid = touchPoi.uid;
        [self.searchApi AMapPOIIDSearch:poiIDRequset];
    }
}

// 长按地图
- (void)mapView:(MAMapView *)mapView didLongPressedAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    // 重新设置地图的中心点
    [self.mapView setCenterCoordinate:coordinate animated:YES];
    [self searchReGeocodeWithCoordinate:coordinate];
}

#pragma mark -- AMapSearchDelegate
#pragma mark -- 地理编码

/**
 *  根据具体地址获取地理编码
 *
 *  @param address 具体地址
 */
- (void)searchGeocodeWithCoordinate:(NSString *)address
{
    AMapGeocodeSearchRequest *geocodeRequest = [[AMapGeocodeSearchRequest alloc] init];
    geocodeRequest.address = address;
    // 地址编码查询接口
    [self.searchApi AMapGeocodeSearch:geocodeRequest];
}

// 地理编码回调 (地址转坐标)
- (void)onGeocodeSearchDone:(AMapGeocodeSearchRequest *)request response:(AMapGeocodeSearchResponse *)response
{
    
}

#pragma mark -- 逆地理编码

/**
 *  根据坐标获取逆地理编码
 *
 *  @param coordinate 坐标
 */
- (void)searchReGeocodeWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    AMapReGeocodeSearchRequest *reGeocodeRequest = [[AMapReGeocodeSearchRequest alloc] init];
    reGeocodeRequest.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    // 是否返回扩展信息
    reGeocodeRequest.requireExtension = YES;
    // 逆地址编码查询接口
    [self.searchApi AMapReGoecodeSearch:reGeocodeRequest];
}

// 逆地理编码回调 (坐标转地址)
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    if(response.regeocode != nil && self.isFirstLocation)
    {
        self.isFirstLocation = NO;
        // 显示定位到的城市
        [self.selectView.cityBtn setTitle:response.regeocode.addressComponent.city forState:UIControlStateNormal];
        [self.selectView addObserver:self forKeyPath:@"cityBtn.titleLabel.text" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        return;
    }
    if (response.regeocode != nil && !self.isFirstLocation)
    {
        CustomAnnotation *customAn = [[CustomAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(request.location.latitude, request.location.longitude) reGeocode:response.regeocode];
        
        // 移除上次的标注
        [self.mapView removeAnnotation:self.lastCustomAn];
        [self.mapView addAnnotation:customAn];
        // 显示具体信息
        [self.mapView selectAnnotation:customAn animated:YES];
        self.lastCustomAn = customAn;
    }
}

// KVO监测手动选择的城市名，并把地图切换到响应的城市
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    // 地图切换到选择的城市
    [self searchDistrictWithCityName:change[NSKeyValueChangeNewKey]];
}

#pragma mark -- 搜索失败回调

// 搜索失败回调
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"搜索失败:%@", error);
}

#pragma mark -- 拖动标注回调

// 拖动标注 重新显示定位信息
- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view didChangeDragState:(MAAnnotationViewDragState)newState fromOldState:(MAAnnotationViewDragState)oldState
{
    view.image = [UIImage imageNamed:@"locate"];
    if (newState == MAAnnotationViewDragStateEnding)
    {
        self.mapView.centerCoordinate = view.annotation.coordinate;
        // 获取拖动后的地理信息
        [self searchReGeocodeWithCoordinate:view.annotation.coordinate];
    }
}

#pragma mark -- 地图自动切换到选择的城市
/**
 *  根据选择的城市 地图自动切换到此城市
 *
 *  @param name 手动选择的城市
 */
- (void)searchDistrictWithCityName:(NSString *)name
{
    AMapDistrictSearchRequest *district = [[AMapDistrictSearchRequest alloc] init];
    district.keywords = name;
    district.requireExtension = YES;
    // 行政区域查询接口
    [self.searchApi AMapDistrictSearch:district];
}

// 行政区域查询回调函数
- (void)onDistrictSearchDone:(AMapDistrictSearchRequest *)request response:(AMapDistrictSearchResponse *)response
{
    if(response == nil || response.districts.count == 0) return;
    
    AMapDistrict *district = response.districts[0];
    // 当前地图的中心点
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(district.center.latitude, district.center.longitude) animated:YES];
    // 修改比例尺
    [self.mapView setZoomLevel:12 atPivot:self.center animated:YES];
    
    /*** 下面是将选择城市的所有地区放在屏幕上**/
//    MAMapRect sumBounds = MAMapRectZero;
//    for (NSString *polylineString in district.polylines)
//    {
//        // 将字符串坐标转换成CLLocationCoordinate2D
//        MAPolyline *polyline = [CommonUtility polylineForCoordinateString:polylineString];
//        // 合并两个MAMapRect
//        sumBounds = MAMapRectUnion(sumBounds, polyline.boundingMapRect);
//        [self.mapView setVisibleMapRect:sumBounds edgePadding:UIEdgeInsetsMake(-50, -50, -50, -50) animated:YES];
//    }
}

#pragma mark -- POI查询

// POI查询回调函数
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if(response != nil || response.pois.count != 0)
    {
        CustomAnnotation *customAn = [[CustomAnnotation alloc] initWithAMapPOI:response.pois[0]];
        
        // 移除上次的标注
        [self.mapView removeAnnotation:self.lastCustomAn];
        [self.mapView addAnnotation:customAn];
        // 显示具体信息
        [self.mapView selectAnnotation:customAn animated:YES];
        self.lastCustomAn = customAn;
    }
}

// searchBar输入框的值改变
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // 输入框为空 则不展示POI
    if(searchText.length == 0)
    {
        self.selectView.dataArray = nil;
        return;
    }
    [self searchTipWithKeywords:searchText];
}

/**
 *  根据输入的内容，展示提示查询结果
 *
 *  @param keywords 查询关键字
 */
- (void)searchTipWithKeywords:(NSString *)keywords
{
    AMapInputTipsSearchRequest *tipsRequest = [[AMapInputTipsSearchRequest alloc] init];
    tipsRequest.city = self.selectView.cityBtn.titleLabel.text;
    tipsRequest.keywords = keywords;
    tipsRequest.cityLimit = YES;
    // POI输入提示查询
    [self.searchApi AMapInputTipsSearch:tipsRequest];
}

// 取消键盘
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.selectView.searchBar resignFirstResponder];
}

// 输入提示查询回调函数
- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response
{
    if(response == nil) return;

    // 去除地址为空的数据
    NSMutableArray *array = [NSMutableArray array];
    for(AMapTip *tip in response.tips)
    {
        if(tip.uid.length != 0 && tip.address.length != 0)
        {
            [array addObject:tip];
        }
    }
    self.selectView.dataArray = array;
}

#pragma mark -- SelectCityAndAddressViewDelagate

// 选中某个POI的回调
- (void)didSelectedRowAtIndexPath:(NSIndexPath *)indexPath
{
    AMapTip *tip = self.selectView.dataArray[indexPath.row];
    
    // 添加标注
    CustomAnnotation *customTipAn = [[CustomAnnotation alloc] initWithAMapTip:tip];
    // 移除上次的标注
    [self.mapView removeAnnotation:self.lastCustomAn];
    [self.mapView addAnnotation:customTipAn];
    // 显示具体信息
    [self.mapView selectAnnotation:customTipAn animated:YES];
    self.lastCustomAn = customTipAn;
}

#pragma mark -- setter/getter

- (UIButton *)locationBtn
{
    if(!_locationBtn)
    {
        _locationBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _locationBtn.frame = CGRectMake(20, self.frame.size.height - 65, 35, 35);
        _locationBtn.backgroundColor = [UIColor whiteColor];
        [_locationBtn setImage:[UIImage imageNamed:@"gpsStat1"] forState:UIControlStateNormal];
        [_locationBtn addTarget:self action:@selector(touchLocationButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _locationBtn;
}

@end
