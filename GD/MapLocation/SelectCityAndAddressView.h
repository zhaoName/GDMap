//
//  SelectCityAndAddressView.h
//  GDMap
//
//  Created by zhao on 16/10/20.
//  Copyright © 2016年 zhaoName. All rights reserved.
//  选择当前城市或兴趣点(POI)

#import <UIKit/UIKit.h>

@protocol SelectCityAndAddressViewDelagate <NSObject>

- (void)didSelectedRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface SelectCityAndAddressView : UIView <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UISearchBar *searchBar;/**< 兴趣点searchBar*/
@property (nonatomic, strong) UIButton *cityBtn; /**< 当前城市按钮*/
@property (nonatomic, strong) void(^jumpInterfaceBlock)(void);/**< 界面跳转block*/

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, weak) id<SelectCityAndAddressViewDelagate> selectDelegate;

/**
 *  快速初始化SelectCityAndAddressView类
 */
+ (instancetype)initWithFrame:(CGRect)frame;

@end
