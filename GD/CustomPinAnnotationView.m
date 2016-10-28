//
//  CustomPinAnnotationView.m
//  GDMap
//
//  Created by zhao on 16/10/19.
//  Copyright © 2016年 zhaoName. All rights reserved.
//  自定义标注view

#import "CustomPinAnnotationView.h"

#define CalloutButtonWidth 44
#define CalloutButtonHeight 50

@implementation CustomPinAnnotationView

- (id)initWithAnnotation:(id<MAAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    if ([super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier])
    {
        self.leftCalloutAccessoryView = [CalloutButton createCalloutButtonWithframe:CGRectMake(0, 0, CalloutButtonWidth, CalloutButtonHeight) title:@"导航" image:[UIImage imageNamed:@"userPosition"]];
        self.rightCalloutAccessoryView = [CalloutButton createCalloutButtonWithframe:CGRectMake(0, 0, CalloutButtonWidth, CalloutButtonHeight) title:@"路线" image:[UIImage imageNamed:@"navi"]];
    }
    return self;
}

@end


@implementation CalloutButton

+ (CalloutButton *)createCalloutButtonWithframe:(CGRect)frame title:(NSString *)title image:(UIImage *)image
{
    CalloutButton *btn = [CalloutButton buttonWithType:UIButtonTypeCustom];
    
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:12];
    btn.backgroundColor = [UIColor blueColor];
    [btn setImage:image forState:UIControlStateNormal];
    btn.frame = frame;
    
    return btn;
}


/**
 *  防止文字太长或图片太大 导致图片或文字的位置不在中间
 */
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if(self.titleLabel.text && self.imageView.image)
    {
        CGFloat marginH = (self.frame.size.height - self.imageView.frame.size.height - self.titleLabel.frame.size.height)/3;
        
        // 图片
        CGPoint imageCenter = self.imageView.center;
        imageCenter.x = self.frame.size.width/2;
        imageCenter.y = self.imageView.frame.size.height/2 + marginH;
        self.imageView.center = imageCenter;
        // 文字
        CGRect newFrame = self.titleLabel.frame;
        newFrame.origin.x = 0;
        newFrame.origin.y = self.frame.size.height - newFrame.size.height - marginH;
        newFrame.size.width = self.frame.size.width;
        self.titleLabel.frame = newFrame;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
}

@end