//
//  RoutePlanView.m
//  GDMap
//
//  Created by zhao on 16/10/31.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import "RoutePlanView.h"

@interface RoutePlanView () <UITableViewDelegate, UITableViewDataSource, AMapSearchDelegate, MAMapViewDelegate>

@property (nonatomic, strong) AMapSearchAPI *searchApi;
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation RoutePlanView

#pragma mark -- 初始化

// 快速初始化GDMapView类
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
        // 搜索
        self.searchApi = [[AMapSearchAPI alloc] init];
        self.searchApi.delegate = self;
        
        self.isBus = YES;
    }
    return self;
}

- (void)layoutSubviews
{
    [self addSubview:self.tableView];
}

#pragma mark -- 出行方式

/**
 *  公交路径规划查询
 */
- (void)searchRoutePlanBus
{
    AMapTransitRouteSearchRequest *busRoute = [[AMapTransitRouteSearchRequest alloc]init];
    busRoute.strategy = 0;
    busRoute.city = self.currentCityName;
    busRoute.nightflag = YES;
    busRoute.requireExtension = YES;
    
    // 起点
    busRoute.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude longitude:self.startCoordinate.longitude];
    // 终点
    busRoute.destination = self.desGeoPoint;
    
    [self.searchApi AMapTransitRouteSearch:busRoute];
}

/**
 *  步行路径规划查询
 */
- (void)searchRoutePlanWalk
{
    AMapWalkingRouteSearchRequest *walkRoute = [[AMapWalkingRouteSearchRequest alloc] init];
    walkRoute.multipath = 1;
    
    // 起点
    walkRoute.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude longitude:self.startCoordinate.longitude];
    // 终点
    walkRoute.destination = self.desGeoPoint;
    [self.searchApi AMapWalkingRouteSearch:walkRoute];
}

/**
 *  驾车路径规划查
 */
- (void)searchRoutePlanDrive
{
    AMapDrivingRouteSearchRequest *driveRoute = [[AMapDrivingRouteSearchRequest alloc] init];
    driveRoute.strategy = 5;
    driveRoute.requireExtension = YES;
    
    // 起点
    driveRoute.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude longitude:self.startCoordinate.longitude];
    // 终点
    driveRoute.destination = self.desGeoPoint;
    [self.searchApi AMapDrivingRouteSearch:driveRoute];
}

#pragma mark -- MAMapViewDelegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    return nil;
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    return nil;
}

#pragma mark -- AMapSearchDelegate

// 路径规划查询回调
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
{
    if(response == nil) return;
    
    if(self.isBus && response.route.transits.count != 0)
    {
        self.dataArray = [NSMutableArray arrayWithArray:response.route.transits];
        [self.tableView reloadData];
    }
    else if(!self.isBus && response.route.paths.count != 0)
    {
        self.dataArray = [NSMutableArray arrayWithArray:response.route.paths];
        [self.tableView reloadData];
    }
}

// 搜索失败回调
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
}

#pragma mark -- UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    if(self.isBus)
    {
        cell.textLabel.text = [self getBusRoute:self.dataArray[indexPath.row]];
        cell.detailTextLabel.text = [self getBusRouteDetail:self.dataArray[indexPath.row]];
    }
    else
    {
        cell.detailTextLabel.text = @"fuck";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark -- 处理公交路线数据

- (NSMutableString *)getBusRoute:(AMapTransit *)transit
{
    NSMutableString *busRoute = [NSMutableString string];
    
    for(int i=0; i<transit.segments.count; i++)
    {
        AMapSegment *segment = transit.segments[i];
        for(AMapBusLine *busLine in segment.buslines)
        {
            NSRange range = [busLine.name rangeOfString:@"("];
            NSString *string = [busLine.name substringToIndex:range.location];
            if([segment.buslines indexOfObject:busLine] != segment.buslines.count -1)
            {
                
                [busRoute appendFormat:@"%@/",string];
            }
            else
            {
                [busRoute appendFormat:@"%@",string];
            }
        }
        // 最后一个数据可能为空
        if([transit.segments.lastObject buslines].count == 0 && i == transit.segments.count - 2)
        {
            break;
        }
        if(i != transit.segments.count - 1)
        {
            [busRoute appendFormat:@" 转 "];
        }
    }
    return busRoute;
}

- (NSString *)getBusRouteDetail:(AMapTransit *)transit
{
    NSString *time = [NSString stringWithFormat:@"%ld分钟", transit.duration % 60];
    NSString *cost = [NSString stringWithFormat:@"%.f元", transit.cost];
    NSString *walkDistance = nil;
    if(transit.walkingDistance < 1000)
    {
        walkDistance = [NSString stringWithFormat:@"步行%lu米", transit.walkingDistance];
    }
    else
    {
        walkDistance = [NSString stringWithFormat:@"步行%.2f公里", transit.walkingDistance / 1000.0];
    }
    
    return [NSString stringWithFormat:@"%@ %@ %@", time, cost, walkDistance];
}

#pragma mark -- getter

- (UITableView *)tableView
{
    if(!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSMutableArray *)dataArray
{
    if(!_dataArray)
    {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


@end
