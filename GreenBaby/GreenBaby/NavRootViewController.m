//
//  NavRootViewController.m
//  MobileResume
//
//  Created by LiXiangCheng on 14-6-6.
//  Copyright (c) 2014年 人人猎头. All rights reserved.
//

#import "NavRootViewController.h"
#import "ScanViewController.h"

@implementation NavRootViewController

-(id)initWithRootViewController:(UIViewController *)rootViewController
{
    NavRootViewController* nvc = [super initWithRootViewController:rootViewController];
    //在iOS7中，如果使用了UINavigationController，那么系统自带的附加了一个从屏幕左边缘开始滑动可以实现pop的手势。但是，如果自定义了navigationItem的leftBarButtonItem，那么这个手势就会失效，如果要在某个页面禁止/开启，看下面UINavigationControllerDelegate
    /*
     UIViewController *vc=[self.navigationController.viewControllers objectAtIndex:(self.navigationController.viewControllers.count-2)];
     if ([vc isKindOfClass:[AddActivityViewController class]]) {
     NSMutableArray *navigationArray = [NSMutableArray array];
     [navigationArray addObject:self.navigationController.viewControllers[0]];
     [navigationArray addObject:self.navigationController.viewControllers[self.navigationController.viewControllers.count-1]];
     self.navigationController.viewControllers = navigationArray;
     }
     */
    if ([[UIDevice getSystemVersion] floatValue] >= 7.0) {
        self.interactivePopGestureRecognizer.delegate = self;
    }
    nvc.delegate = self;
    return nvc;
}

//不要调用我自己(就是UINavigationController)的preferredStatusBarStyle方法，而是去调用navigationController.topViewController的preferredStatusBarStyle方法
- (UIViewController *)childViewControllerForStatusBarStyle{
    return self.topViewController;
}

#pragma mark UINavigationControllerDelegate

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
}

-(void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (navigationController.viewControllers.count == 1)
        self.currentShowVC = Nil;
    else{
        if ([viewController isKindOfClass:[ScanViewController class]]) {
            self.currentShowVC =Nil;
        }
        else{
            self.currentShowVC = viewController;
        }
    }
    
}
#pragma mark UIGestureRecognizerDelegate

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        return (self.currentShowVC == self.topViewController);
    }
    return YES;
}

@end
