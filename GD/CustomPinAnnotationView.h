//
//  CustomPinAnnotationView.h
//  GDMap
//
//  Created by zhao on 16/10/19.
//  Copyright © 2016年 zhaoName. All rights reserved.
//  自定义标注view

#import <MAMapKit/MAMapKit.h>

@interface CustomPinAnnotationView : MAPinAnnotationView

/**
 *  创建自定义的气泡view
 */
- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;

@end



@interface CalloutButton : UIButton

/**
 *  创建自定义气泡左右两侧显示的view
 *
 *  @param frame view的位置
 *  @param title view的标题
 *  @param image view的图片
 */
+ (CalloutButton *)createCalloutButtonWithframe:(CGRect)frame title:(NSString *)title image:(UIImage *)image;

@end