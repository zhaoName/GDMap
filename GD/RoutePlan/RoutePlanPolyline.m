//
//  RoutePlanPolyline.m
//  GDMap
//
//  Created by zhao on 16/10/31.
//  Copyright © 2016年 zhaoName. All rights reserved.
//  添加路线和标注

#import "RoutePlanPolyline.h"
#import "DashLinePolyline.h"


@interface RoutePlanPolyline ()

@property (nonatomic, strong) MAMapView *mapView;

@end

@implementation RoutePlanPolyline

#pragma mark -- 初始化

// 乘车或步行
- (instancetype)routePlanWithPath:(AMapPath *)path routePlanType:(RoutePlanViewType)type showTraffict:(BOOL)showTraffict startPoint:(AMapGeoPoint *)startPoint endPoint:(AMapGeoPoint *)endPoint
{
    if([super init])
    {
        if(type == RoutePlanViewTypeDrive && showTraffict) // 乘车
        {
            NSArray *multipleColor = nil;
            MAPolyline *polyline = [self multipleColorPolylineWithDrivePath:path multipleColor:&multipleColor];
            if(polyline)
            {
                [self.routePolylines addObject:polyline];
                self.multiplePolylineColors = [multipleColor mutableCopy];
            }
        }
        else // 步行
        {
            
        }
    }
    // 补充起点和终点对于路径的空隙
    [self replenishPolylinesForStartPoint:startPoint endPoint:endPoint];
    return self;
}

// 公交车
- (instancetype)routePlanWithTransit:(AMapTransit *)transit startPoint:(AMapGeoPoint *)startPoint endPoint:(AMapGeoPoint *)endPoint
{
    if([super init])
    {
        
    }
    return self;
}

#pragma mark --

// 将overlay和标注添加到地图上
- (void)addPolylineAndAnnotationToMapView:(MAMapView *)mapView
{
    self.mapView = mapView;
    
    if(self.routeAnnotations.count > 0)
    {
        [mapView addAnnotations:self.routeAnnotations];
    }
    if(self.routePolylines.count > 0 )
    {
        [mapView addOverlays:self.routePolylines];
    }
}

// 清空地图上的polyline和标注
- (void)clearMapView
{
    if(self.mapView == nil) return;
    
    if(self.routePolylines.count > 0)
    {
        [self.mapView removeOverlays:self.routePolylines];
    }
    if(self.routeAnnotations.count > 0)
    {
        [self.mapView removeAnnotations:self.routeAnnotations];
    }
    
    self.mapView = nil;
}

- (void)setRoutePlanPolylineVisibility:(BOOL)visible
{
    
}

#pragma mark -- 出行方式数据处理

// 驾车
- (MAPolyline *)multipleColorPolylineWithDrivePath:(AMapPath *)path multipleColor:(NSArray **)multipleColor
{
    if(path == nil) return nil;
    
    NSMutableArray *coorArray = [[NSMutableArray alloc] init];
    NSMutableArray<AMapTMC *> *tmcs = [[NSMutableArray alloc] init];
    NSMutableArray *polylineColors = [[NSMutableArray alloc] init];
    NSMutableArray *coordinates = [[NSMutableArray alloc] init];
    NSMutableArray *indexes = [[NSMutableArray alloc] init];
    
    // 获取坐标和路况信息
    [path.steps enumerateObjectsUsingBlock:^(AMapStep * _Nonnull step, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [coorArray addObjectsFromArray:[step.polyline componentsSeparatedByString:@";"]];
        [tmcs addObjectsFromArray:step.tmcs];
    }];
    
    NSInteger sumLength = 0;
    NSInteger statusesIndex = 0;
    // 当前路况下的距离
    NSInteger currentTrafficLength = tmcs.firstObject.distance;
    // 当前路况对应的颜色
    [polylineColors addObject:[self colorWithTrafficStatus:tmcs.firstObject.status]];
    [coordinates addObject:coorArray.firstObject];
    [indexes addObject:@0];
    
    int i = 1;
    for(; i<coorArray.count; i++)
    {
        // 计算两个坐标之间的距离
        double coorDistance = [self calculateDistanceBetweenFirstCoordiante:[self coordinateWithString:coorArray[i]] andSecondCoordinate:[self coordinateWithString:coorArray[i-1]]];
        
        if (sumLength + coorDistance >= currentTrafficLength)
        {
            if (sumLength + coorDistance == currentTrafficLength)
            {
                [coordinates addObject:[coorArray objectAtIndex:i]];
                [indexes addObject:[NSNumber numberWithInteger:([coordinates count]-1)]];
            }
            else // 需要插入一个点
            {
                double rate = (coorDistance == 0 ? 0 : ((currentTrafficLength - sumLength) / coorDistance));
                NSString *extrnPoint = [self calculatePointWithStartPoint:[coorArray objectAtIndex:i-1] endPoint:[coorArray objectAtIndex:i] rate:MAX(MIN(rate, 1.0), 0)];
                if (extrnPoint)
                {
                    [coordinates addObject:extrnPoint];
                    [indexes addObject:[NSNumber numberWithInteger:([coordinates count]-1)]];
                    [coordinates addObject:[coorArray objectAtIndex:i]];
                }
                else
                {
                    [coordinates addObject:[coorArray objectAtIndex:i]];
                    [indexes addObject:[NSNumber numberWithInteger:([coordinates count]-1)]];
                }
            }
            sumLength = sumLength + coorDistance - currentTrafficLength;
            if (++statusesIndex >= [tmcs count])
            {
                break;
            }
            currentTrafficLength = tmcs[statusesIndex].distance;
            [polylineColors addObject:[self colorWithTrafficStatus:tmcs[statusesIndex].status]];
        }
        else
        {
            [coordinates addObject:[coorArray objectAtIndex:i]];
            sumLength += coorDistance;
        }
    }
    
    //将最后一个点对齐到路径终点
    if (i < [coorArray count])
    {
        while (i < [coorArray count])
        {
            [coordinates addObject:[coorArray objectAtIndex:i]];
            i++;
        }
        [indexes removeLastObject];
        [indexes addObject:[NSNumber numberWithInteger:([coordinates count]-1)]];
    }
    
    // 添加overlay
    CLLocationCoordinate2D *runningCoords = (CLLocationCoordinate2D *)malloc(coordinates.count * sizeof(CLLocationCoordinate2D));
    for (int j = 0; j < coordinates.count; ++j)
    {
        runningCoords[j] = [self coordinateWithString:coordinates[j]];
    }
    // 分段绘制，根据经纬度坐标数据生成多段线
    MAMultiPolyline *polyline = [MAMultiPolyline polylineWithCoordinates:runningCoords count:coordinates.count drawStyleIndexes:indexes];
    free(runningCoords);
    
    // 颜色
    if(polylineColors) *multipleColor = [polylineColors mutableCopy];
    
    return polyline;
}

#pragma mark -- 补充起点和终点对于路径的空隙

/**
 *  补充起点和终点对于路径的空隙(虚线)
 *
 *  @param start 起点坐标
 *  @param end   终点坐标
 */
- (void)replenishPolylinesForStartPoint:(AMapGeoPoint *)start endPoint:(AMapGeoPoint *)end
{
    if(self.routePolylines.count < 1 || start == nil || end == nil) return;
    
    DashLinePolyline *startDashLine = nil;
    DashLinePolyline *endDashLine = nil;
    
    // 补充起点
    CLLocationCoordinate2D startCoordinate1 = CLLocationCoordinate2DMake(start.latitude, start.longitude);
    CLLocationCoordinate2D endCoordinate1 = startCoordinate1;
    
    MAPolyline *polyline1 = self.routePolylines.firstObject;
    [polyline1 getCoordinates:&endCoordinate1 range:NSMakeRange(0, 1)];
    startDashLine = [self replenishPolylineWithStart:startCoordinate1 end:endCoordinate1];
    
    // 补充终点
    CLLocationCoordinate2D startCoordinate2;
    CLLocationCoordinate2D endCoordinate2;
    
    MAPolyline *polyline2 = self.routePolylines.lastObject;
    [polyline2 getCoordinates:&startCoordinate2 range:NSMakeRange(polyline2.pointCount - 1, 1)];
    endCoordinate2 = CLLocationCoordinate2DMake(end.latitude, end.longitude);
    endDashLine = [self replenishPolylineWithStart:startCoordinate2 end:endCoordinate2];
    
    if(startDashLine) [self.routePolylines addObject:startDashLine];
    if(endDashLine) [self.routePolylines addObject:endDashLine];
}

/**
 *  补充起点或终点对于路径的空隙
 */
- (DashLinePolyline *)replenishPolylineWithStart:(CLLocationCoordinate2D)startCoor end:(CLLocationCoordinate2D)endCoor
{
    if (!CLLocationCoordinate2DIsValid(startCoor) || !CLLocationCoordinate2DIsValid(endCoor)) return nil;
    
    double distance = MAMetersBetweenMapPoints(MAMapPointForCoordinate(startCoor), MAMapPointForCoordinate(endCoor));
    DashLinePolyline *dashline = nil;
    // 若起点距离路径的距离较近，则不用添加虚线
    if(distance >= 10)
    {
        CLLocationCoordinate2D points[2];
        points[0] = startCoor;
        points[1] = endCoor;
        MAPolyline *polyline = [MAPolyline polylineWithCoordinates:points count:2];
        dashline = [DashLinePolyline initWithPolyline:polyline];
    }
    return dashline;
}

#pragma mark -- 私有方法

/**
 *  根据路况决定当前这条线的颜色
 */
- (UIColor *)colorWithTrafficStatus:(NSString *)status
{
    if(status == nil) status = @"未知";
    
    static NSDictionary *colorMapping = nil;
    if (colorMapping == nil)
    {
        colorMapping = @{@"未知":[UIColor greenColor], @"畅通":[UIColor greenColor], @"缓行":[UIColor yellowColor], @"拥堵":[UIColor redColor]};
    }
    return colorMapping[status] ?: [UIColor greenColor];
}

/**
 *  计算两个坐标之间的投影距离
 */
- (double)calculateDistanceBetweenFirstCoordiante:(CLLocationCoordinate2D)firstCoordinate andSecondCoordinate:(CLLocationCoordinate2D)secondCoordinate
{
    // 经纬度坐标转平面投影坐标
    MAMapPoint mapPointA = MAMapPointForCoordinate(firstCoordinate);
    MAMapPoint mapPointB = MAMapPointForCoordinate(secondCoordinate);
    // 投影两点之间的距离
    return MAMetersBetweenMapPoints(mapPointA, mapPointB);
}

/**
 *  将得到的字符串坐标转换成正常的坐标
 */
- (CLLocationCoordinate2D)coordinateWithString:(NSString *)string
{
    NSArray *coorArray = [string componentsSeparatedByString:@","];
    if (coorArray.count != 2)
    {
        return kCLLocationCoordinate2DInvalid;
    }
    return CLLocationCoordinate2DMake([coorArray[1] doubleValue], [coorArray[0] doubleValue]);
}


- (NSString *)calculatePointWithStartPoint:(NSString *)start endPoint:(NSString *)end rate:(double)rate
{
    if (rate > 1.0 || rate < 0) return nil;
    
    MAMapPoint from = MAMapPointForCoordinate([self coordinateWithString:start]);
    MAMapPoint to = MAMapPointForCoordinate([self coordinateWithString:end]);
    
    double latitudeDelta = (to.y - from.y) * rate;
    double longitudeDelta = (to.x - from.x) * rate;
    
    MAMapPoint newPoint = MAMapPointMake(from.x + longitudeDelta, from.y + latitudeDelta);
    
    CLLocationCoordinate2D coordinate = MACoordinateForMapPoint(newPoint);
    return [NSString stringWithFormat:@"%.6f,%.6f", coordinate.longitude, coordinate.latitude];
}

#pragma mark -- getter

- (NSMutableArray *)routePolylines
{
    if(!_routePolylines)
    {
        _routePolylines = [[NSMutableArray alloc] init];
    }
    return _routePolylines;
}

- (NSMutableArray *)routeAnnotations
{
    if(!_routeAnnotations)
    {
        _routeAnnotations = [[NSMutableArray alloc] init];
    }
    return _routeAnnotations;
}

- (NSMutableArray *)multiplePolylineColors
{
    if(!_multiplePolylineColors)
    {
        _multiplePolylineColors = [[NSMutableArray alloc] init];
    }
    return _multiplePolylineColors;
}

@end
