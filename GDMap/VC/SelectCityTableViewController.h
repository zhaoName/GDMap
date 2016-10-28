//
//  SelectCityTableViewController.h
//  GDMap
//
//  Created by zhao on 16/10/21.
//  Copyright © 2016年 zhaoName. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectCityTableVCDelegate <NSObject>

- (void)sendSelectedeCityName:(NSString *)cityName;

@end


@interface SelectCityTableViewController : UITableViewController

@property (nonatomic, strong) NSString *currentCityName;
@property (nonatomic, weak) id<SelectCityTableVCDelegate> delegate;


@end
