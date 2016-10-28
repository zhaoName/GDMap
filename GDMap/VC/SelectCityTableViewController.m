//
//  SelectCityTableViewController.m
//  GDMap
//
//  Created by zhao on 16/10/21.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import "SelectCityTableViewController.h"
#import "SortAlphabetically.h"

@interface SelectCityTableViewController () <UISearchBarDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray; /**< 未排序数据源数组*/
@property (nonatomic, strong) NSMutableDictionary *sortDict; /**< 排序后的数据源*/
@property (nonatomic, strong) NSMutableArray *letterArray; /**< 字母索引*/
@property (nonatomic, strong) NSMutableArray *searchArray; /**< 搜索到的数据源*/

@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation SelectCityTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置导航栏
    self.navigationItem.titleView = self.searchBar;
    // 处理数据源
    [self handleDataSource];
    
}

#pragma mark -- 处理数据源

/**
 *  处理数据源
 */
- (void)handleDataSource
{
    // 加载plist文件
    NSString *path = [[NSBundle mainBundle] pathForResource:@"cityList" ofType:@"plist"];
    self.dataArray = [NSMutableArray arrayWithArray:[NSDictionary dictionaryWithContentsOfFile:path][@"city"]];
    self.sortDict = [[SortAlphabetically shareSortAlphabetically] sortAlphabeticallyWithDataArray:self.dataArray propertyName:nil];
    self.letterArray = [[SortAlphabetically shareSortAlphabetically] sortAllKeysFromDictKey:[self.sortDict allKeys]];
}

#pragma mark -- UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(self.searchArray.count != 0) return 1;
    return self.letterArray.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.searchArray.count != 0) return self.searchArray.count;
    
    if (section == 0) return 1;
    return [self.sortDict[self.letterArray[section - 1]] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(self.searchArray.count != 0) return 0;
    
    return 25;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(self.searchArray.count != 0) return nil;
    
    if(section == 0) return @"当前位置";
    return self.letterArray[section - 1];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    
    if(self.searchArray.count != 0)
    {
        cell.imageView.image = nil;
        cell.textLabel.text = self.searchArray[indexPath.row];
    }
    else
    {
        if(indexPath.section == 0){
            cell.textLabel.text = self.currentCityName ?:@"未知";
            cell.imageView.image = [UIImage imageNamed:@"locate"];
        }
        else{
            cell.imageView.image = nil;
            cell.textLabel.text = self.sortDict[self.letterArray[indexPath.section - 1]][indexPath.row];
        }
    }
    return cell;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if(self.searchArray.count != 0) return nil;
    return self.letterArray;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cityName = nil;
    if(self.searchArray.count != 0)
    {
        cityName = self.searchArray[indexPath.row];
    }
    else
    {
        cityName = self.currentCityName;
        if(indexPath.section != 0)
        {
            cityName = self.sortDict[self.letterArray[indexPath.section - 1]][indexPath.row];
        }
    }
    if([self.delegate respondsToSelector:@selector(sendSelectedeCityName:)])
    {
        [self.delegate sendSelectedeCityName:cityName];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- UISearchBarDelegate

// 开始编辑搜索框
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    self.searchBar.showsCancelButton = YES;
    return YES;
}

// 搜索框内容变化
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.searchArray removeAllObjects];
    self.searchArray = [[SortAlphabetically shareSortAlphabetically] blurrySearchFromDataArray:self.dataArray propertyName:nil searchString:searchText];
    
    [self.tableView reloadData];
}

// 点击取消按钮
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    self.searchBar.showsCancelButton = NO;
    [self.searchBar resignFirstResponder];
}

// 点击键盘上搜索按钮
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
}

#pragma mark - getter

- (NSMutableArray *)dataArray
{
    if(!_dataArray)
    {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (NSMutableDictionary *)sortDict
{
    if(!_sortDict)
    {
        _sortDict = [[NSMutableDictionary alloc] init];
    }
    return _sortDict;
}

- (NSMutableArray *)letterArray
{
    if(!_letterArray)
    {
        _letterArray = [[NSMutableArray alloc] init];
    }
    return _letterArray;
}

- (NSMutableArray *)searchArray
{
    if(!_searchArray)
    {
        _searchArray = [[NSMutableArray alloc] init];
    }
    return _searchArray;
}

- (UISearchBar *)searchBar
{
    if(!_searchBar)
    {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.placeholder = @"输入城市中文名、拼音和首字母查询";
        _searchBar.delegate = self;
    }
    return _searchBar;
}

@end
