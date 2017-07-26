//
//  SensibleScrollView.m
//  Hunt
//
//  Created by Li XiangCheng on 13-6-24.
//  Copyright (c) 2013年 Li XiangCheng. All rights reserved.
//

#import "SensibleScrollView.h"

@implementation SensibleScrollView

#pragma mark Multi-Touch logic

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //隐藏键盘
    if ([UIWindow isKeyboardVisible]) {
        [[[UIApplication sharedApplication].keyWindow findFirstResponder] resignFirstResponder];
    }
    
    [super touchesBegan:touches withEvent:event];
    return;
}

@end
