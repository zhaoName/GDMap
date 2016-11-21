//
//  DestinationTableViewController.m
//  GDMap
//
//  Created by zhao on 16/10/27.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import "DestinationTableViewController.h"

@interface DestinationTableViewController ()<UISearchBarDelegate, AMapSearchDelegate>

@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) AMapSearchAPI *searchApi;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation DestinationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchApi = [[AMapSearchAPI alloc] init];
    self.searchApi.delegate = self;
    
    [self setupSearchBar];
    [self.searchBar becomeFirstResponder];
}

/**
 *  创建SearchBar
 */
- (void)setupSearchBar
{
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 30, 30)];
    self.searchBar.delegate = self;
    self.searchBar.barTintColor = [UIColor whiteColor];
    [self.view addSubview:self.searchBar];
    self.navigationItem.titleView = self.searchBar;
}
// searchBar输入框的值改变
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    // 输入框为空 则不展示POI
    if(searchText.length == 0) return;
    [self searchTipWithKeywords:searchText];
}

/**
 *  根据输入的内容，展示提示查询结果
 *
 *  @param keywords 查询关键字
 */
- (void)searchTipWithKeywords:(NSString *)keywords
{
    AMapInputTipsSearchRequest *tipsRequest = [[AMapInputTipsSearchRequest alloc] init];
    tipsRequest.city = self.curCityName;
    tipsRequest.keywords = keywords;
    tipsRequest.cityLimit = YES;
    // POI输入提示查询
    [self.searchApi AMapInputTipsSearch:tipsRequest];
}

#pragma mark -- AMapSearchDelegate

// 输入提示查询回调函数
- (void)onInputTipsSearchDone:(AMapInputTipsSearchRequest *)request response:(AMapInputTipsSearchResponse *)response
{
    if(response == nil) return;
    
    // 去除地址为空的数据
    NSMutableArray *array = [NSMutableArray array];
    for(AMapTip *tip in response.tips)
    {
        if(tip.uid.length != 0 && tip.address.length != 0)
        {
            [array addObject:tip];
        }
    }
    self.dataSource = array;
    [self.tableView reloadData];
}

#pragma mark -- UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    }
    AMapTip *tip = self.dataSource[indexPath.row];
    cell.textLabel.text = tip.name;
    cell.detailTextLabel.text = tip.address;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AMapTip *tip = self.dataSource[indexPath.row];
    if([self.delagate respondsToSelector:@selector(sendCoordinateWithTip:isDestination:)])
    {
        [self.delagate sendCoordinateWithTip:tip isDestination:self.isDestination];
    }
    [self.searchBar resignFirstResponder];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -- getter

- (NSMutableArray *)dataSource
{
    if(!_dataSource)
    {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

@end
