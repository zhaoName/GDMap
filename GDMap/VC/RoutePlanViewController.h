//
//  RoutePlanViewController.h
//  GDMap
//
//  Created by zhao on 16/10/20.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RoutePlanViewController : UIViewController

@property (nonatomic, assign) CLLocationCoordinate2D startCoordinate; /**< 用户起点坐标*/
@property (nonatomic, strong) NSString *currentCityName; /**< 当前城市名称*/

@end
