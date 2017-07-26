//
//  UIWindowHelper.h
//  FFHelper
//
//  Created by 李 香成 on 10-12-30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIWindow (Helper)

///////////////////////////////////////////////////////////////////////////////////////////////////
// 判断键盘是否已经打开
+ (BOOL) isKeyboardVisible;

// 递归搜索视图层次的第一响应者，从window开始。
- (UIView*)findFirstResponder;
// 递归搜索视图层次的第一响应者，从输入的View中的topView开始
- (UIView*)findFirstResponderInView:(UIView*)topView;

@end

@interface UIWindow (Extensions)

- (UIViewController*)topViewController;

@end