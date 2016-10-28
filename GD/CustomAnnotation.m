//
//  CustomAnnotation.m
//  GDMap
//
//  Created by zhao on 16/10/19.
//  Copyright © 2016年 zhaoName. All rights reserved.
//  自定义标注显示内容

#import "CustomAnnotation.h"

@implementation CustomAnnotation
@synthesize coordinate = _coordinate;

// 长按地图
- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate reGeocode:(AMapReGeocode *)reGeocode
{
    if([super init])
    {
        self.coordinate = coordinate;
        //
        self.title = [NSString stringWithFormat:@"%@附近", reGeocode.pois[0].name ?:@""];
        // 包含省、城市、区、街道名称、门牌号
        self.subtitle = [NSString stringWithFormat:@"%@%@%@%@%@",
                         reGeocode.addressComponent.province ?: @"",
                         reGeocode.addressComponent.city ?: @"",
                         reGeocode.addressComponent.district?: @"",
                         reGeocode.addressComponent.streetNumber.street ?:@"",
                         reGeocode.addressComponent.streetNumber.number ?:@""];
    }
    return self;
}

// 单击地图
- (instancetype)initWithAMapPOI:(AMapPOI *)poi
{
    if([super init])
    {
        self.coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
        //
        self.title = [NSString stringWithFormat:@"%@", poi.name ?:@""];
        // 包含省、城市、区、街道名称、门牌号
        self.subtitle = [NSString stringWithFormat:@"%@%@%@%@",
                         poi.province ?: @"",
                         poi.city ?: @"",
                         poi.district ?:@"",
                         poi.address?: @""];
    }
    return self;
}


- (void)setTip:(AMapTip *)tip
{
    _tip = tip;
    
    self.coordinate = CLLocationCoordinate2DMake(tip.location.latitude, tip.location.longitude);
    self.title = [NSString stringWithFormat:@"%@", tip.name ?:@""];
    self.subtitle = [NSString stringWithFormat:@"%@", tip.address];
}
// 选择POI
- (instancetype)initWithAMapTip:(AMapTip *)tip
{
    if([super init])
    {
        self.coordinate = CLLocationCoordinate2DMake(tip.location.latitude, tip.location.longitude);
        self.title = [NSString stringWithFormat:@"%@", tip.name ?:@""];
        self.subtitle = [NSString stringWithFormat:@"%@", tip.address];
    }
    return self;
}

@end
