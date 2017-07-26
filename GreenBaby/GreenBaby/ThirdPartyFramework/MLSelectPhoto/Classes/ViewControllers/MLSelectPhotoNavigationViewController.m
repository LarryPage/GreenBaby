//  MLNavigationViewController.m
//  MLSelectPhoto
//
//  Created by LiXiangCheng on 15/4/22.
//  Copyright (c) 2015年 com.Ideal.www. All rights reserved.
//

#import "MLSelectPhotoNavigationViewController.h"
#import "MLSelectPhotoCommon.h"

@interface MLSelectPhotoNavigationViewController ()

@end

@implementation MLSelectPhotoNavigationViewController


- (void)viewDidLoad{
    [super viewDidLoad];
    
    UINavigationController *rootVc = (UINavigationController *)[[UIApplication sharedApplication].keyWindow rootViewController];
    
    if ([rootVc isKindOfClass:[UINavigationController class]]) {
        self.navigationBar.barTintColor=[rootVc.navigationBar valueForKeyPath:@"barTintColor"];
        self.navigationBar.tintColor=rootVc.navigationBar.tintColor;
        [self.navigationBar setTitleTextAttributes:rootVc.navigationBar.titleTextAttributes];
        
    }else{
        self.navigationBar.barTintColor=DefaultNavbarTintColor;
        [self.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:DefaultNavTitleColor, NSForegroundColorAttributeName, DefaultNavTitleFont, NSFontAttributeName, nil]];
        self.navigationBar.tintColor=DefaultNavTintColor;
        UIBarButtonItem * barItemInNavigationBarAppearanceProxy = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil];
        [barItemInNavigationBarAppearanceProxy setTitleTextAttributes:[NSDictionary
                                                                       dictionaryWithObjectsAndKeys:DefaultNavBarButtonFont, NSFontAttributeName,nil] forState:UIControlStateNormal];
    }
    
    self.navigationBar.translucent = YES; //7,0 default Yes
    
    self.view.backgroundColor = [UIColor blackColor];
}

//不要调用我自己(就是UINavigationController)的preferredStatusBarStyle方法，而是去调用navigationController.topViewController的preferredStatusBarStyle方法
- (UIViewController *)childViewControllerForStatusBarStyle{
    return self.topViewController;
}

@end
