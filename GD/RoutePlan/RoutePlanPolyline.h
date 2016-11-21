//
//  RoutePlanPolyline.h
//  GDMap
//
//  Created by zhao on 16/10/31.
//  Copyright © 2016年 zhaoName. All rights reserved.
//  添加路线和标注

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RoutePlanViewType)
{
    RoutePlanViewTypeWalk = 0, /**< 步行*/
    RoutePlanViewTypeBus, /**< 公交车*/
    RoutePlanViewTypeDrive, /**< 驾车*/
};

@interface RoutePlanPolyline : NSObject

@property (nonatomic, strong) NSMutableArray *routeAnnotations;
@property (nonatomic, strong) NSMutableArray *routePolylines;
@property (nonatomic, strong) NSMutableArray *multiplePolylineColors;

/**
 *  乘车或步行路线图
 *
 *  @param path         未处理的乘车或步行数据
 *  @param type         乘车或步行
 *  @param showTraffict 是否展示路况
 *  @param startPoint   起点坐标
 *  @param endPoint     终点坐标
 */
- (instancetype)routePlanWithPath:(AMapPath *)path routePlanType:(RoutePlanViewType)type showTraffict:(BOOL)showTraffict startPoint:(AMapGeoPoint *)startPoint endPoint:(AMapGeoPoint *)endPoint;

/**
 *  公交车路线图
 *
 *  @param transit    公交路线数据
 *  @param startPoint 起点坐标
 *  @param endPoint   终点坐标
 */
- (instancetype)routePlanWithTransit:(AMapTransit *)transit startPoint:(AMapGeoPoint *)startPoint endPoint:(AMapGeoPoint *)endPoint;

/**
 *  将将路线和标注添加到地图上
 *
 *  @param mapView 地图
 */
- (void)addPolylineAndAnnotationToMapView:(MAMapView *)mapView;

/**
 *  清空地图上的overlay和标注
 */
- (void)clearMapView;

@end
