//
//  BaseViewController.h
//  Hunt
//
//  Created by LiXiangCheng on 14/12/1.
//  Copyright (c) 2014年 LiXiangCheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"

typedef void (^BaseCompletion)(void);

/**
 *  所有NavigationController控制下的ViewContoller的父类，用来提供导航栏Title和导航栏上的返回按钮。
 *
 */
@interface BaseViewController : UIViewController

@property (nonatomic, readwrite) BOOL statusBarHidden;
@property (nonatomic,assign) UIStatusBarStyle statusBarStyle;

@property (nonatomic, strong) UIButton* backBtn;//Default Hidden is NO
@property (nonatomic, strong) UIButton *rightBtn;//Default Hidden is YES

@property (nonatomic, strong) UIView *navBarView;
@property (nonatomic, strong) UIImageView *navBarBgIV;
@property (nonatomic, strong) UIButton *navBarLeftBtn;
@property (nonatomic, strong) UILabel *navBarTitleLbl;
@property (nonatomic, strong) UIButton *navBarRightBtn;

- (void)setTitle:(NSString *)title;//override
- (void)back;
- (void)rightBtn:(UIButton *)sender;

- (void)updateStatusBar;
- (void)setNavBar;
- (void)setNavigationBarAttribute:(UINavigationBar *)navigationBar;//设置navigationBar的属性
- (void)setNavigationBar1Attribute:(UINavigationBar *)navigationBar;//发sms设置navigationBar的属性

- (void)pageviewStart;
- (void)pageviewEnd;

- (BOOL)authorityExecute:(BaseCompletion)completion;
@end
