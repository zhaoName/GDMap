//
//  RoutePlanView.h
//  GDMap
//
//  Created by zhao on 16/10/31.
//  Copyright © 2016年 zhaoName. All rights reserved.
//  路径规划

#import <UIKit/UIKit.h>
#import "RoutePlanPolyline.h"


@interface RoutePlanView : UIView

@property (nonatomic, strong) NSString *currentCityName; /**< 当前城市名称*/
@property (nonatomic, assign) CLLocationCoordinate2D startCoordinate; /**< 用户起点坐标*/
@property (nonatomic, strong) AMapGeoPoint *desGeoPoint; /**< 终点坐标*/
@property (nonatomic, assign) RoutePlanViewType routePlanType; /**<出行方式*/
@property (nonatomic, strong) void(^jumpRoutePlanBusVCBlock)(AMapTransit *);

/**
 *  快速初始化GDMapView类
 */
+ (instancetype)initWithFrame:(CGRect)frame;

/**
 *  步行路径规划查询
 */
- (void)searchRoutePlanWalk;

/**
 *  公交路径规划查询
 */
- (void)searchRoutePlanBus;

/**
 *  驾车路径规划查
 */
- (void)searchRoutePlanDrive;

@end
