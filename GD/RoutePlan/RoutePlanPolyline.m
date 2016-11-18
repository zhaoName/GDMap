//
//  RoutePlanPolyline.m
//  GDMap
//
//  Created by zhao on 16/10/31.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import "RoutePlanPolyline.h"

@interface RoutePlanPolyline ()

@end

@implementation RoutePlanPolyline

#pragma mark -- 初始化

// 乘车或步行
- (instancetype)routePlanWithPath:(AMapPath *)path routePlanType:(RoutePlanViewType)type showTraffict:(BOOL)showTraffict startPoint:(AMapGeoPoint *)startPoint endPoint:(AMapGeoPoint *)endPoint
{
    if([super init])
    {
        if(type == RoutePlanViewTypeDrive && showTraffict)
        {
            NSArray *multipleColor = nil;
            MAPolyline *polyline = [self multipleColorPolylineWithDrivePath:path multipleColor:&multipleColor];
            if(polyline)
            {
                [self.routePolylines addObject:polyline];
                self.multiplePolylineColors = [multipleColor mutableCopy];
            }
        }
        else
        {
            
        }
    }
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


// 将路线和标注添加到地图上
- (void)addPolylineAndAnnotationToMapView:(MAMapView *)mapView
{
    [mapView addAnnotations:self.routePolylines];
    [mapView addOverlays:self.routePolylines];
}

- (void)setRoutePlanPolylineVisibility:(BOOL)visible
{
    
}

#pragma mark --

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
                NSString *extrnPoint = [self calcPointWithStartPoint:[coorArray objectAtIndex:i-1] endPoint:[coorArray objectAtIndex:i] rate:MAX(MIN(rate, 1.0), 0)];
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
    
    return polyline;
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


- (NSString *)calcPointWithStartPoint:(NSString *)start endPoint:(NSString *)end rate:(double)rate
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
