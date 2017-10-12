//
//  UIWindowHelper.m
//  FFHelper
//
//  Created by 李 香成 on 10-12-30.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UIWindowHelper.h"

@implementation UIWindow (Helper)


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BOOL) isKeyboardVisible{
	// 假设上进行操作键盘可见当且仅当有一个第一
	// Operates on the assumption that the keyboard is visible if and only if there is a first
	// responder; i.e. a control responding to key events
    //来自three20的代码，看看当前的窗口是否存在一个responder，从而判别iPhone的键盘是否打开了
    //隐藏键盘
//    if ([UIWindow isKeyboardVisible]) {
//        [[[UIApplication sharedApplication].keyWindow findFirstResponder] resignFirstResponder];
//    }
	UIWindow* window = [UIApplication sharedApplication].keyWindow;//多个UIWindow中显示的哪个，一般数组中只有一个UIWindow,可多个
    CLog(@"window.tag=%@",@(window.tag));
	return !![window findFirstResponder];
}
- (UIView*)findFirstResponder {
	return [self findFirstResponderInView:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIView*)findFirstResponderInView:(UIView*)topView {
	if ([topView isFirstResponder]) {
		return topView;
	}
	
	for (UIView* subView in topView.subviews) {
		if ([subView isFirstResponder]) {
			return subView;
		}
		
		UIView* firstResponderCheck = [self findFirstResponderInView:subView];
		if (nil != firstResponderCheck) {
			return firstResponderCheck;
		}
	}
	return nil;
}

@end

@implementation UIWindow (Extensions)

- (UIViewController*)topViewController {
    //return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
    
    //避免UIAlertController没完全消失时
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(window in windows) {
            if (window.windowLevel == UIWindowLevelNormal) {
                break;
            }
        }
    }
    return [self topViewControllerWithRootViewController:window.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

@end
