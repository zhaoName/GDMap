//
//  MapNavigationManager.h
//  GDMap
//
//  Created by zhao on 16/10/18.
//  Copyright © 2016年 zhaoName. All rights reserved.
//  导航

#import <Foundation/Foundation.h>


@interface MapNavigationManager : NSObject

@property (nonatomic, strong) MAUserLocation *userLocation; /**< 用户定位信息(起点)*/

/**
 *  单例创建MapNavigationManager
 */
+ (MapNavigationManager *)defaultNavigationManager;

/**
 *  使用URI方式打开手机上已有地图进行导航 默认出行方式为驾车
 *
 *  @param destination 终点
 */
- (void)mapNavigationWithDestination:(CLLocationCoordinate2D)destination;

@end
