//
//  UIButtonHelper.m
//  CardBump
//
//  Created by sbtjfdn on 12-5-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UIButtonHelper.h"
#include <objc/message.h>

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

@implementation UIButton (Tracking)

- (void)enableEventTracking
{
    NSString *className = [NSString stringWithFormat:@"EventTracking_%@",self.class];
    Class kClass        = objc_getClass([className UTF8String]);
    
    if (!kClass) {
        kClass = objc_allocateClassPair([self class], [className UTF8String], 0);
    }
    SEL setterSelector  = NSSelectorFromString(@"sendAction:to:forEvent:");
    Method setterMethod = class_getInstanceMethod([self class], setterSelector);
    
    object_setClass(self, kClass); // 转换当前类从UIButton到新建的EventTracking_UIButton类
    
    const char *types   = method_getTypeEncoding(setterMethod);
    
    class_addMethod(kClass, setterSelector, (IMP)eventTracking_SendAction, types);
    
    objc_registerClassPair(kClass);
}

static void eventTracking_SendAction(id self, SEL _cmd, SEL action ,id target , UIEvent *event) {
    struct objc_super superclass = {
        .receiver    = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    void (*objc_msgSendSuperCasted)(const void *, SEL, SEL, id, UIEvent *) = (void *)objc_msgSendSuper;
    
    // to do event tracking...
    NSLog(@"Click event record: target = %@, action = %@, event = %ld", target, NSStringFromSelector(action), (long)event.type);
    
    objc_msgSendSuperCasted(&superclass, _cmd, action, target, event);
}

@end
