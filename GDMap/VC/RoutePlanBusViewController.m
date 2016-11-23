//
//  RoutePlanBusViewController.m
//  GDMap
//
//  Created by zhao on 2016/11/21.
//  Copyright © 2016年 zhaoName. All rights reserved.
//  公交路线

#import "RoutePlanBusViewController.h"
#import "RoutePlanPolyline.h"
#import "DashLinePolyline.h"
#import "CommonUtility.h"

@interface RoutePlanBusViewController ()<MAMapViewDelegate>

@property (nonatomic, strong) MAMapView *mapView;

@end

@implementation RoutePlanBusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"公交路线";
    
    // 初始化地图
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    [self.view addSubview:self.mapView];
    
    RoutePlanPolyline *busPolyline = [[RoutePlanPolyline alloc] routePlanWithTransit:self.transit startPoint:self.startGeoPoint endPoint:self.endGeoPoint];
    [busPolyline addPolylineAndAnnotationToMapView:self.mapView];
    
    [self.mapView setVisibleMapRect:[CommonUtility mapRectForOverlays:busPolyline.routePolylines] edgePadding:UIEdgeInsetsMake(20, 20, 20, 20) animated:YES];
}

#pragma mark -- MAMapViewDelegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        MAAnnotationView *startOrEndAnnotation = (MAAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"StartOrEnd"];
        if(startOrEndAnnotation == nil)
        {
            startOrEndAnnotation = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"StartOrEnd"];
        }
        
        startOrEndAnnotation.centerOffset = CGPointMake(0, -10);
        if([annotation.title isEqualToString:@"起点"])
        {
            startOrEndAnnotation.image = [UIImage imageNamed:@"startPoint"];
        }
        else if ([annotation.title isEqualToString:@"终点"])
        {
            startOrEndAnnotation.image = [UIImage imageNamed:@"endPoint"];
        }
        return startOrEndAnnotation;
    }
    return nil;
}

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAMultiPolyline class]])// 路线
    {
        MAMultiColoredPolylineRenderer * polylineRenderer = [[MAMultiColoredPolylineRenderer alloc] initWithMultiPolyline:overlay];
        
        polylineRenderer.lineWidth = 10;
        //polylineRenderer.strokeColors = [self.multiplePolylineColors copy];
        polylineRenderer.gradient = YES;
        polylineRenderer.lineJoinType = kMALineCapRound;
        
        return polylineRenderer;
    }
    // 补充起点和终点对于路径的空隙（虚线）
    if([overlay isKindOfClass:[DashLinePolyline class]])
    {
        MAPolylineRenderer *dashPolylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:((DashLinePolyline *)overlay).polyline];
        dashPolylineRenderer.lineDash = YES;
        dashPolylineRenderer.lineWidth = 8.0;
        dashPolylineRenderer.strokeColor = [UIColor redColor];
        
        return dashPolylineRenderer;
    }
    if([overlay isKindOfClass:[MAPolyline class]]) // 步行路线
    {
        MAPolylineRenderer *walkPolylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        
        walkPolylineRenderer.lineWidth = 8.0;
        walkPolylineRenderer.strokeColor = [UIColor colorWithRed:47/255.0 green:147/255.0 blue:188/255.0 alpha:1];
        
        return walkPolylineRenderer;
    }
    return nil;
}

@end
