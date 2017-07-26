//
//  NavRootViewController.h
//  MobileResume
//
//  Created by LiXiangCheng on 14-6-6.
//  Copyright (c) 2014年 人人猎头. All rights reserved.
//

#import <UIKit/UIKit.h>

//for ios7.0
@interface NavRootViewController : UINavigationController<UIGestureRecognizerDelegate,UINavigationControllerDelegate>

@property(nonatomic,assign) UIViewController* currentShowVC;

@end
