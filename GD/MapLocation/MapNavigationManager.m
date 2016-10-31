//
//  MapNavigationManager.m
//  GDMap
//
//  Created by zhao on 16/10/28.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import "MapNavigationManager.h"
#import <MapKit/MapKit.h>

@implementation MapNavigationManager

#pragma mark -- 初始化
+ (MapNavigationManager *)defaultNavigationManager
{
    static MapNavigationManager* manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

// 使用URI方式打开手机上已有地图进行导航
- (void)mapNavigationWithDestination:(CLLocationCoordinate2D)destination
{
    if(self.userLocation == nil ) return;
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"选择导航所用地图" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [[self getCurrentViewController] presentViewController:alertVC animated:YES completion:nil];
    
    // 打开高德地图导航
    [self openGDMapNavigation:alertVC destination:destination];
    // 打开百度地图导航
    [self openBaiDuMapNavigation:alertVC destination:destination];
    // 打开苹果地图导航
    [self openAppleMapNavigation:alertVC destination:destination];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
}

#pragma mark -- 打开地图
/**
 *  URI方式打开高德地图导航
 *
 *  @param destination 终点坐标
 */
- (void)openGDMapNavigation:(UIAlertController *)alertVC destination:(CLLocationCoordinate2D)destination
{
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://map/"]])
    {
        [alertVC addAction:[UIAlertAction actionWithTitle:@"高德地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            NSString *gdNaviParameter = @"iosamap://navi?sourceApplication=%@&backScheme=%@&poiname=%@&poiid=&lat=%f&lon=%f&dev=0&style=2";
            NSString *urlString = [[NSString stringWithFormat:gdNaviParameter, @"GDMap", @"GDMap", @"终点", destination.latitude, destination.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        }]];
    }
}

/**
 *  URI方式打开百度地图导航
 *
 *  @param destination 终点坐标
 */
- (void)openBaiDuMapNavigation:(UIAlertController *)alertVC destination:(CLLocationCoordinate2D)destination
{
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://map/"]])
    {
        [alertVC addAction:[UIAlertAction actionWithTitle:@"百度地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            CLLocationCoordinate2D baiduDestination = [self gcj02CoordianteToBD09:destination];
            NSString *baiduParameter = @"baidumap://map/direction?origin=latlng:%f,%f|name:我的位置&destination=latlng:%f,%f|name:终点&mode=driving";
            NSString *urlString = [[NSString stringWithFormat:baiduParameter,
                                    self.userLocation.location.coordinate.latitude,
                                    self.userLocation.location.coordinate.longitude,
                                    baiduDestination.latitude,
                                    baiduDestination.longitude]
                                   stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ;
            
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:urlString]];
            
        }]];
    }
}

/**
 *  使用系统自带地图导航
 *
 *  @param destination 终点坐标
 */
- (void)openAppleMapNavigation:(UIAlertController *)alertVC destination:(CLLocationCoordinate2D)destination
{
    [alertVC addAction:[UIAlertAction actionWithTitle:@"苹果地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        //起点
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        //终点
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:destination addressDictionary:nil]];
        //默认驾车
        [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                       launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
                                       MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
    }]];
}

#pragma mark -- 坐标的转换
/**
 *  将GCJ-02坐标转换为BD-09坐标 即将高德地图上获取的坐标转换成百度坐标
 */
- (CLLocationCoordinate2D)gcj02CoordianteToBD09:(CLLocationCoordinate2D)gdCoordinate
{
    double x_PI = M_PI * 3000 / 180.0;
    double gd_lat = gdCoordinate.latitude;
    double gd_lon = gdCoordinate.longitude;
    
    double z = sqrt(gd_lat * gd_lat + gd_lon * gd_lon) + 0.00002 * sin(gd_lat * x_PI);
    double theta = atan2(gd_lat, gd_lon) + 0.000003 * cos(gd_lon * x_PI);
    
    return CLLocationCoordinate2DMake(z * sin(theta) + 0.006, z * cos(theta) + 0.0065);
}

/**
 *  将BD-09坐标转换为GCJ-02坐标 即将百度地图上获取的坐标转换成高德地图的坐标
 */
- (CLLocationCoordinate2D)bd09CoordinateToGCJ02:(CLLocationCoordinate2D)bdCoordinate
{
    double x_PI = M_PI * 3000 / 180.0;
    double bd_lat = bdCoordinate.latitude - 0.006;
    double bd_lon = bdCoordinate.longitude - 0.0065;
    
    double z = sqrt(bd_lat * bd_lat + bd_lon * bd_lon) + 0.00002 * sin(bd_lat * x_PI);
    double theta = atan2(bd_lat, bd_lon) + 0.000003 * cos(bd_lon * x_PI);
    
    return CLLocationCoordinate2DMake(z * cos(theta), z * sin(theta));
}

#pragma mark -- 获取当前VC

/**
 * 获取当前呈现的ViewController
 */
- (UIViewController *)getCurrentViewController
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

@end
