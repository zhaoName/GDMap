//
//  DestinationTableViewController.h
//  GDMap
//
//  Created by zhao on 16/10/27.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DestinationTVCDelegate <NSObject>

/**
 *  获取手动选择的起点或终点信息
 *
 *  @param tip   起点或终点信息
 *  @param isDes 起点或终点
 */
- (void)sendCoordinate:(AMapTip *)tip isDestination:(BOOL)isDes;

@end

@interface DestinationTableViewController : UITableViewController

@property (nonatomic, strong) NSString *curCityName; /**< 当前城市名称*/
@property (nonatomic, assign) BOOL isDestination;
@property (nonatomic, weak) id<DestinationTVCDelegate> delagate;

@end
