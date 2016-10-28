//
//  CustomAnnotation.h
//  GDMap
//
//  Created by zhao on 16/10/19.
//  Copyright © 2016年 zhaoName. All rights reserved.
//  自定义标注显示内容

#import <Foundation/Foundation.h>

@interface CustomAnnotation : NSObject <MAAnnotation>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, strong) AMapTip *tip;

/**
 *  显示长按标注信息
 *
 *  @param coordinate 坐标
 *  @param reGeocode  逆地理编码得到的信息
 *
 *  @return 标注
 */
- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate reGeocode:(AMapReGeocode *)reGeocode;

/**
 *  显示单击地图的信息
 *
 *  @param poi 查uid获得的POI信息
 */
- (instancetype)initWithAMapPOI:(AMapPOI *)poi;

/**
 *  显示选中提示POI信息
 *
 *  @param tip 选中的提示POI信息
 */
- (instancetype)initWithAMapTip:(AMapTip *)tip;

@end
