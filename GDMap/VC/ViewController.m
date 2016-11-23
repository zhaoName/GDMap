//
//  ViewController.m
//  GDMap
//
//  Created by zhao on 16/10/17.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import "ViewController.h"
#import "GDMapView.h"
#import "SelectCityAndAddressView.h"
#import "SelectCityTableViewController.h"
#import "RoutePlanViewController.h"

@interface ViewController ()<SelectCityTableVCDelegate>

@property (nonatomic, strong) GDMapView *mapView;
@property (nonatomic, strong) SelectCityAndAddressView *selectView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 地图
    [self setupMapView];
    // 选择城市、POI
    [self setupSelectView];
}

/**
 *  创建地图View
 */
- (void)setupMapView
{
    [self.view addSubview:self.mapView];
    
    __weak typeof(ViewController) *weakSelf = self;
    self.mapView.jumpRoutePlanVCBlock = ^(void)
    {
        // 查找路线
        RoutePlanViewController *routePlanVC = [[RoutePlanViewController alloc] init];
        routePlanVC.startCoordinate = weakSelf.mapView.userLocation.location.coordinate;
        routePlanVC.currentCityName = weakSelf.selectView.cityBtn.titleLabel.text;
        UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:routePlanVC];
        
        [weakSelf presentViewController:nv animated:YES completion:nil];
    };
}

/**
 *  创建选择view
 */
- (void)setupSelectView
{
    [self.view addSubview:self.selectView];
    __weak typeof(ViewController) *weakSelf = self;
    
    // 点击选择城市按钮 跳转界面
    self.selectView.jumpInterfaceBlock = ^(void)
    {
        SelectCityTableViewController *selectVC = [[SelectCityTableViewController alloc] init];
        selectVC.delegate = weakSelf;
        selectVC.currentCityName = weakSelf.selectView.cityBtn.titleLabel.text;
        UINavigationController *nv = [[UINavigationController alloc] initWithRootViewController:selectVC];
        [weakSelf presentViewController:nv animated:YES completion:nil];
    };
}

#pragma mark -- SelectCityTableVCDelegate

- (void)sendSelectedeCityName:(NSString *)cityName
{
    // 将选择的城市名称赋值
    [self.selectView.cityBtn setTitle:cityName forState:UIControlStateNormal];
}

// 取消第一响应
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark -- getter

- (GDMapView *)mapView
{
    if(!_mapView)
    {
        _mapView = [GDMapView initWithFrame:self.view.bounds];
        _mapView.selectView = self.selectView;
    }
    return _mapView;
}

- (SelectCityAndAddressView *)selectView
{
    if(!_selectView)
    {
        _selectView = [SelectCityAndAddressView initWithFrame:CGRectMake(15, 84, SCREEN_WIDTH - 30, 40)];
    }
    return _selectView;
}

@end
