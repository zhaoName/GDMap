//
//  DashLinePolyline.m
//  GDMap
//
//  Created by zhao on 2016/11/21.
//  Copyright © 2016年 zhaoName. All rights reserved.
//  补充起点和终点对于路径的空隙(虚线)

#import "DashLinePolyline.h"

@implementation DashLinePolyline
@synthesize coordinate;
@synthesize boundingMapRect;

+ (instancetype)initWithPolyline:(MAPolyline *)polyline
{
    return [[self alloc] initWithPolyline:polyline];
}

- (instancetype)initWithPolyline:(MAPolyline *)polyline
{
    if([super init])
    {
        self.polyline = polyline;
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    return [_polyline coordinate];
}

- (MAMapRect)boundingMapRect
{
    return [_polyline boundingMapRect];
}

@end
