
//
//  RoutePlanViewController.m
//  GDMap
//
//  Created by zhao on 16/10/20.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import "RoutePlanViewController.h"
#import "DestinationTableViewController.h"
#import "RoutePlanView.h"

@interface RoutePlanViewController ()<UITextFieldDelegate, DestinationTVCDelegate>

@property (nonatomic, strong) RoutePlanView *routeView;
@property (nonatomic, strong) UITextField *startTF; /**< 起点*/
@property (nonatomic, strong) UITextField *destinationTF; /**< 终点*/
@property (nonatomic, strong) UISegmentedControl *segment; /**< 选择出行方式*/

@end

@implementation RoutePlanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 设置导航栏
    [self setupNavigationBar];
    // 设置起点、终点TextField
    [self setupStartAndDestinationTextField];
    [self setupSeparateLine];
    [self.view addSubview:self.routeView];
    self.routeView.startCoordinate = self.startCoordinate;
    self.routeView.currentCityName = self.currentCityName;
}

#pragma mark -- 导航栏
/**
 *  设置导航栏
 */
- (void)setupNavigationBar
{
    self.navigationController.navigationBar.barTintColor = [UIColor redColor];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(touchLeftItem)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.segment = [[UISegmentedControl alloc] initWithItems:@[@"开车", @"公交车", @"步行"]];
    self.segment.selectedSegmentIndex = 1;
    [self.segment addTarget:self action:@selector(selectTripWay:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.titleView = self.segment;
}

// 返回
- (void)touchLeftItem
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- 起点、终点

/**
 *  设置起点、终点TextField
 */
- (void)setupStartAndDestinationTextField
{
    [self.view addSubview:self.startTF];
    [self.view addSubview:self.destinationTF];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    DestinationTableViewController *destinationTVC = [[DestinationTableViewController alloc] init];
    destinationTVC.curCityName = self.currentCityName;
    destinationTVC.delagate = self;
    if(textField == self.startTF)
    {
        [self.startTF resignFirstResponder];
        destinationTVC.isDestination = NO;
    }
    else
    {
        destinationTVC.isDestination = YES;
        [self.destinationTF resignFirstResponder];
    }
    
    [self.navigationController pushViewController:destinationTVC animated:YES];
}

- (void)setupSeparateLine
{
    UIView *separateView = [[UIView alloc] initWithFrame:CGRectMake(0, 124, SCREEN_WIDTH, 1)];
    separateView.backgroundColor = [UIColor lightGrayColor];
    
    [self.view addSubview:separateView];
}

#pragma mark -- DestinationTVCDelegate

// 获取手动选择的起点或终点信息
- (void)sendCoordinate:(AMapTip *)tip isDestination:(BOOL)isDes
{
    if(isDes) // 终点
    {
        self.destinationTF.text = tip.name;
        self.routeView.desGeoPoint = tip.location;
    }
    else // 起点
    {
        self.startTF.text = tip.name;
        self.startCoordinate = CLLocationCoordinate2DMake(tip.location.latitude, tip.location.longitude);
        self.routeView.startCoordinate = self.startCoordinate;
    }
    
    // 使用默认方式 选择路线规划
    if(self.startCoordinate.latitude != self.routeView.desGeoPoint.latitude && self.startCoordinate.longitude != self.routeView.desGeoPoint.longitude)
    {
        self.routeView.isBus = YES;
        [self.routeView searchRoutePlanBus];
    }
}

#pragma mark -- 选择出行方式

// 选择出行方式
- (void)selectTripWay:(UISegmentedControl *)segment
{
    // 起点和终点坐标相同 则给个提示
    if(self.startCoordinate.latitude == self.routeView.desGeoPoint.latitude &&
       self.startCoordinate.longitude == self.routeView.desGeoPoint.longitude)
    {
        NSLog(@"终点和起点坐标相同");
        return;
    }
    if(self.routeView.desGeoPoint == nil)
    {
        NSLog(@"终点坐标为空");
        return;
    }
    
    if(segment.selectedSegmentIndex == 0)
    {
        self.routeView.isBus = NO;
        [self.routeView searchRoutePlanDrive]; // 驾车
    }
    else if(segment.selectedSegmentIndex == 1)
    {
        self.routeView.isBus = YES;
        [self.routeView searchRoutePlanBus]; // 公交
    }
    else
    {
        self.routeView.isBus = NO;
        [self.routeView searchRoutePlanWalk]; // 步行
    }
}

// 取消键盘
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark -- getter

- (UITextField *)startTF
{
    if(!_startTF)
    {
        _startTF = [[UITextField alloc] initWithFrame:CGRectMake(15, 64, SCREEN_WIDTH-30, 30)];
        _startTF.placeholder = @"输入起点";
        _startTF.delegate = self;
        _startTF.text = @"我的位置";
        _startTF.userInteractionEnabled = YES;
    }
    return _startTF;
}

- (UITextField *)destinationTF
{
    if(!_destinationTF)
    {
        _destinationTF = [[UITextField alloc] initWithFrame:CGRectMake(15, 94, SCREEN_WIDTH - 30, 30)];
        _destinationTF.delegate = self;
        _destinationTF.placeholder = @"输入终点";
    }
    return _destinationTF;
}

- (RoutePlanView *)routeView
{
    if(!_routeView)
    {
        _routeView = [RoutePlanView initWithFrame:CGRectMake(0, 125, SCREEN_WIDTH, SCREEN_HEIGHT - 125)];
    }
    return _routeView;
}

@end
