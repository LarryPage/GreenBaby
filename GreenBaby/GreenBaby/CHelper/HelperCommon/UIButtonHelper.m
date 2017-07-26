//
//  UIButtonHelper.m
//  CardBump
//
//  Created by sbtjfdn on 12-5-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIButtonHelper.h"

@implementation UIButton (custom)

//重写函数
- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event{
    NSString *actionString = NSStringFromSelector(action);
    NSString *touchUpInsideMethodName = [[self actionsForTarget:target forControlEvent:UIControlEventTouchUpInside] lastObject];
    //NSLog(@"touchUpInsideMethodName:%@,self:%@,target:%@",touchUpInsideMethodName,[self description],[target description]);
    if ([touchUpInsideMethodName isEqualToString:actionString]){
        
    }
    
    // all other events we simple pass on
    [super sendAction:action to:target forEvent:event];
}

//override
- (UIEdgeInsets)alignmentRectInsets {
    UIEdgeInsets insets;
    if ([[UIDevice getSystemVersion] floatValue] >= 7.0) {
        if (self.tag == LEFT_BAR_BUTTON) {
            insets = UIEdgeInsetsMake(0, 20.0f, 0, 0);
        }
        else if (self.tag == RIGHT_BAR_BUTTON) { // IF_ITS_A_RIGHT_BUTTON
            insets = UIEdgeInsetsMake(0, 0, 0, 20.0f);
        }
        else{
            insets = UIEdgeInsetsMake(0, 0, 0, 0);
        }
    } else {
        insets = UIEdgeInsetsZero;
    }
    
    return insets;
}

@end
