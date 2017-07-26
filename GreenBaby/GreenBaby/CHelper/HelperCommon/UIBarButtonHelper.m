//
//  UIBarButtonItem+Custom.m
//  SuperResume
//
//  Created by Li XiangCheng on 13-10-10.
//  Copyright (c) 2013年 Li XiangCheng. All rights reserved.
//

#import "UIBarButtonHelper.h"
#import "UIButtonHelper.h"

@implementation UIBarButtonItem (Helper)

+ (UIBarButtonItem *)barButtonLeftWithTitle:(NSString *)title target:(id)target action:(SEL)action{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = LEFT_BAR_BUTTON;
    button.frame = CGRectMake(0, 0, 55, 31);
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:MKRGBA(246,246,248,255) forState:UIControlStateHighlighted];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    //[button setBackgroundImage:[UIImage createImageWithColor:MKRGBA(27,155,246,255)] forState:UIControlStateNormal];
    button.layer.cornerRadius = 2.0;
    button.layer.masksToBounds = YES;
    if ([[UIDevice getSystemVersion] floatValue] >= 7.0) {
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 1, 0, 0);
    }
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

+ (UIBarButtonItem *)barButtonRightWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = RIGHT_BAR_BUTTON;
    button.frame = CGRectMake(0, 0, 55, 31);
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:MKRGBA(246,246,248,255) forState:UIControlStateHighlighted];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    //[button setBackgroundImage:[UIImage createImageWithColor:MKRGBA(27,155,246,255)] forState:UIControlStateNormal];
    button.layer.cornerRadius = 2.0;
    button.layer.masksToBounds = YES;
    if ([[UIDevice getSystemVersion] floatValue] >= 7.0) {
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 1);
    }
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

@end
