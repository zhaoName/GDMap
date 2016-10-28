//
//  SelectCityAndAddressView.m
//  GDMap
//
//  Created by zhao on 16/10/20.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import "SelectCityAndAddressView.h"

#define SELECT_WIDTH self.frame.size.width
#define SELECT_HEIGHT self.frame.size.height

@implementation SelectCityAndAddressView
@synthesize dataArray = _dataArray;

// 快速初始化
+ (instancetype)initWithFrame:(CGRect)frame
{
    return [[self alloc] initWithFrame:frame];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if([super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        self.layer.cornerRadius = 5.0;
        self.layer.masksToBounds = YES;
        // 创建选择城市按钮
        [self setupCityButton];
        // 创建POI搜索
        [self setupPOISearchBar];
        // 创建分割线
        [self setupSeparateLine];
    }
    return self;
}

#pragma mark -- 城市选择按钮

/**
 *  创建选择城市按钮
 */
- (void)setupCityButton
{
    self.cityBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cityBtn.backgroundColor = [UIColor whiteColor];
    self.cityBtn.frame = CGRectMake(0, 0, SELECT_WIDTH/4, SELECT_HEIGHT);
    self.cityBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.cityBtn setTitle:@"未知" forState:UIControlStateNormal];
    [self.cityBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.cityBtn addTarget:self action:@selector(touchCityBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cityBtn];
}

// 选择城市按钮的点击事件
- (void)touchCityBtn:(UIButton *)btn
{
    self.jumpInterfaceBlock();
}

#pragma mark -- 分隔线
/**
 *  创建分隔线
 */
- (void)setupSeparateLine
{
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(SELECT_WIDTH/4 - 2, 2, 1, SELECT_HEIGHT - 4)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:lineView];
}

#pragma mark -- POI

/**
 *  创建SearchBar
 */
- (void)setupPOISearchBar
{
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(SELECT_WIDTH/4, -2, SELECT_WIDTH/4*3, SELECT_HEIGHT+4)];
    self.searchBar.delegate = self;
    self.searchBar.barTintColor = [UIColor whiteColor];
    [self addSubview:self.searchBar];
}

#pragma mark -- UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    }
    AMapTip *tip = self.dataArray[indexPath.row];
    cell.textLabel.text = tip.name;
    cell.detailTextLabel.text = tip.address;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.frame = CGRectMake(15, 84, SCREEN_WIDTH - 30, 40);
    self.tableView.hidden = YES;
    [self.searchBar resignFirstResponder];
    
    if([self.selectDelegate respondsToSelector:@selector(didSelectedRowAtIndexPath:)])
    {
        [self.selectDelegate didSelectedRowAtIndexPath:indexPath];
    }
}

#pragma mark -- setter/getter

- (UITableView *)tableView
{
    if(!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (void)setDataArray:(NSMutableArray *)dataArray
{
    _dataArray = dataArray;
    
    if(dataArray.count == 0)
    {
        self.frame = CGRectMake(15, 84, SCREEN_WIDTH - 30, 40);
        [self.tableView reloadData];
        self.tableView.hidden = YES;
    }
    else
    {
        self.frame = CGRectMake(15, 84, [UIScreen mainScreen].bounds.size.width - 30, 300);
        self.tableView.hidden = NO;
        self.tableView.frame = CGRectMake(0, 45, SELECT_WIDTH, SELECT_HEIGHT - 45);
        [self addSubview:self.tableView];
        [self.tableView reloadData];
    }
}

- (NSMutableArray *)dataArray
{
    if(!_dataArray)
    {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

@end
