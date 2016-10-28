//
//  GDMapView.h
//  GDMap
//
//  Created by zhao on 16/10/19.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SelectCityAndAddressView.h"


@interface GDMapView : UIView

@property (nonatomic, strong) NSString *selectedCity; /**< 手动选择的城市名称*/
@property (nonatomic, strong) MAUserLocation *userLocation; /**< 用户定位信息(起点)*/
@property (nonatomic, strong) SelectCityAndAddressView *selectView;
@property (nonatomic, strong) void(^jumpRoutePlanVCBlock)(void);

/**
 *  快速初始化GDMapView类
 */
+ (instancetype)initWithFrame:(CGRect)frame;

/**
 *  根据具体地址获取地理编码
 *
 *  @param address 具体地址
 */
- (void)searchGeocodeWithCoordinate:(NSString *)address;

/**
 *  根据坐标获取逆地理编码
 *
 *  @param coordinate 坐标
 */
- (void)searchReGeocodeWithCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 *  根据输入的内容，展示提示查询结果
 *
 *  @param keywords 查询关键字
 */
- (void)searchTipWithKeywords:(NSString *)keywords;

/**
 *  根据选择的城市 地图自动切换到此城市
 *
 *  @param name 手动选择的城市
 */
- (void)searchDistrictWithCityName:(NSString *)name;

@end
