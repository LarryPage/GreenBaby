//
//  SensibleTableView.m
//  CardBump
//
//  Created by 香成 李 on 12-4-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SensibleTableView.h"

@implementation SensibleTableView

#pragma mark Multi-Touch logic

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    //隐藏键盘
    if ([UIWindow isKeyboardVisible]) {
        [[[AppDelegate sharedAppDelegate].window findFirstResponder] resignFirstResponder];
    }
    
    [super touchesBegan:touches withEvent:event];
    return;
}

@end
