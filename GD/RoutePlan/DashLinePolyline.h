//
//  DashLinePolyline.h
//  GDMap
//
//  Created by zhao on 2016/11/21.
//  Copyright © 2016年 zhaoName. All rights reserved.
//  补充起点和终点对于路径的空隙(虚线)

#import <Foundation/Foundation.h>

@interface DashLinePolyline : NSObject <MAOverlay>

@property (nonatomic, assign, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign, readonly) MAMapRect boundingMapRect;
@property (nonatomic, strong) MAPolyline *polyline;

/**
 *  快速初始化DashLinePolyline类
 *
 *  @param polyline 虚线段
 */
+ (instancetype)initWithPolyline:(MAPolyline *)polyline;


@end
