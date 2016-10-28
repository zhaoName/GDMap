
//
//  RoutePlanViewController.m
//  GDMap
//
//  Created by zhao on 16/10/20.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import "RoutePlanViewController.h"
#import "DestinationTableViewController.h"

@interface RoutePlanViewController ()<AMapSearchDelegate, UITextFieldDelegate, DestinationTVCDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) AMapSearchAPI *searchApi;
@property (nonatomic, strong) UITextField *startTF; /**< 起点*/
@property (nonatomic, strong) UITextField *destinationTF; /**< 终点*/
@property (nonatomic, strong) AMapGeoPoint *desGeoPoint; /**< 终点坐标*/
@property (nonatomic, strong)  UISegmentedControl *segment;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation RoutePlanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.searchApi = [[AMapSearchAPI alloc] init];
    self.searchApi.delegate = self;
    
    // 设置导航栏
    [self setupNavigationBar];
    // 设置起点、终点TextField
    [self setupStartAndDestinationTextField];
    [self setupSeparateLine];
    [self.view addSubview:self.tableView];
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
        self.desGeoPoint = tip.location;
    }
    else // 起点
    {
        self.startTF.text = tip.name;
        self.startCoordinate = CLLocationCoordinate2DMake(tip.location.latitude, tip.location.longitude);
    }
    
    // 使用默认方式 选择路线规划
    if(self.startCoordinate.latitude != self.desGeoPoint.latitude && self.startCoordinate.longitude != self.desGeoPoint.longitude)
    {
        [self searchRoutePlanBus];
    }
}


#pragma mark -- 选择出行方式

// 选择出行方式
- (void)selectTripWay:(UISegmentedControl *)segment
{
    // 起点和终点坐标相同 则给个提示
    if(self.startCoordinate.latitude == self.desGeoPoint.latitude &&
       self.startCoordinate.longitude == self.desGeoPoint.longitude)
    {
        NSLog(@"终点和起点坐标相同");
        return;
    }
    if(self.desGeoPoint == nil)
    {
        NSLog(@"终点坐标为空");
        return;
    }
    
    if(segment.selectedSegmentIndex == 0)
    {
        [self searchRoutePlanDrive]; // 驾车
    }
    else if(segment.selectedSegmentIndex == 1)
    {
        [self searchRoutePlanBus]; // 公交
    }
    else
    {
        [self searchRoutePlanWalk]; // 步行
    }
}

/**
 *  公交路径规划查询
 */
- (void)searchRoutePlanBus
{
    AMapTransitRouteSearchRequest *busRoute = [[AMapTransitRouteSearchRequest alloc]init];
    busRoute.strategy = 0;
    busRoute.city = self.currentCityName;
    busRoute.nightflag = YES;
    busRoute.requireExtension = YES;
    
    // 起点
    busRoute.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude longitude:self.startCoordinate.longitude];
    // 终点
    busRoute.destination = self.desGeoPoint;
    
    [self.searchApi AMapTransitRouteSearch:busRoute];
}

/**
 *  步行路径规划查询
 */
- (void)searchRoutePlanWalk
{
    AMapWalkingRouteSearchRequest *walkRoute = [[AMapWalkingRouteSearchRequest alloc] init];
    walkRoute.multipath = 1;
    
    // 起点
    walkRoute.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude longitude:self.startCoordinate.longitude];
    // 终点
    walkRoute.destination = self.desGeoPoint;
    [self.searchApi AMapWalkingRouteSearch:walkRoute];
}

/**
 *  驾车路径规划查
 */
- (void)searchRoutePlanDrive
{
    AMapDrivingRouteSearchRequest *driveRoute = [[AMapDrivingRouteSearchRequest alloc] init];
    driveRoute.strategy = 5;
    driveRoute.requireExtension = YES;
    
    // 起点
    driveRoute.origin = [AMapGeoPoint locationWithLatitude:self.startCoordinate.latitude longitude:self.startCoordinate.longitude];
    // 终点
    driveRoute.destination = self.desGeoPoint;
    [self.searchApi AMapDrivingRouteSearch:driveRoute];
}

#pragma mark -- AMapSearchDelegate

// 路径规划查询回调
- (void)onRouteSearchDone:(AMapRouteSearchBaseRequest *)request response:(AMapRouteSearchResponse *)response
{
    if(response == nil) return;
    
    if(self.segment.selectedSegmentIndex == 1 && response.route.transits.count != 0)
    {
        self.dataArray = [NSMutableArray arrayWithArray:response.route.transits];
        [self.tableView reloadData];
    }
    else if(self.segment.selectedSegmentIndex != 1 && response.route.paths.count != 0)
    {
        self.dataArray = [NSMutableArray arrayWithArray:response.route.paths];
        [self.tableView reloadData];
    }
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
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    if(self.segment.selectedSegmentIndex == 1)
    {
        cell.textLabel.text = [self getBusRoute:self.dataArray[indexPath.row]];
        cell.detailTextLabel.text = [self getBusRouteDetail:self.dataArray[indexPath.row]];
    }
    else
    {
       cell.detailTextLabel.text = @"fuck";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark -- 处理公交路线数据

- (NSMutableString *)getBusRoute:(AMapTransit *)transit
{
    NSMutableString *busRoute = [NSMutableString string];
    
    for(int i=0; i<transit.segments.count; i++)
    {
        AMapSegment *segment = transit.segments[i];
        for(AMapBusLine *busLine in segment.buslines)
        {
            NSRange range = [busLine.name rangeOfString:@"("];
            NSString *string = [busLine.name substringToIndex:range.location];
            if([segment.buslines indexOfObject:busLine] != segment.buslines.count -1)
            {
                
                [busRoute appendFormat:@"%@/",string];
            }
            else
            {
                [busRoute appendFormat:@"%@",string];
            }
        }
        if([transit.segments.lastObject buslines].count == 0 && i == transit.segments.count - 2)
        {
            break;
        }
        if(i != transit.segments.count - 1)
        {
            [busRoute appendFormat:@" 转 "];
        }
    }
    return busRoute;
}

- (NSString *)getBusRouteDetail:(AMapTransit *)transit
{
    NSString *time = [NSString stringWithFormat:@"%ld分钟", transit.duration % 60];
    NSString *cost = [NSString stringWithFormat:@"%.f元", transit.cost];
    NSString *walkDistance = nil;
    if(transit.walkingDistance < 1000)
    {
        walkDistance = [NSString stringWithFormat:@"步行%lu米", transit.walkingDistance];
    }
    else
    {
        walkDistance = [NSString stringWithFormat:@"步行%.2f公里", transit.walkingDistance / 1000.0];
    }
    
    return [NSString stringWithFormat:@"%@ %@ %@", time, cost, walkDistance];
}

// 搜索失败回调
- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
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

- (UITableView *)tableView
{
    if(!_tableView)
    {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 125, SCREEN_WIDTH, SCREEN_HEIGHT - 125) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
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
