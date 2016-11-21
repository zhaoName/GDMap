//
//  RoutePlanBusViewController.h
//  GDMap
//
//  Created by zhao on 2016/11/21.
//  Copyright © 2016年 zhaoName. All rights reserved.
//  公交路线

#import <UIKit/UIKit.h>

@interface RoutePlanBusViewController : UIViewController

@property (nonatomic, strong) AMapTransit *transit;
@property (nonatomic, strong) AMapGeoPoint *startGeoPoint;
@property (nonatomic, strong) AMapGeoPoint *endGeoPoint;

@end
