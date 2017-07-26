//
//  UIBarButtonItem+Custom.h
//  SuperResume
//
//  Created by Li XiangCheng on 13-10-10.
//  Copyright (c) 2013年 Li XiangCheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Helper)

+ (UIBarButtonItem *)barButtonLeftWithTitle:(NSString *)title target:(id)target action:(SEL)action;
+ (UIBarButtonItem *)barButtonRightWithTitle:(NSString *)title target:(id)target action:(SEL)action;

@end
