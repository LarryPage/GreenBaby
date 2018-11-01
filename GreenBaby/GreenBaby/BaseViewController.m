//
//  BaseViewController.m
//  Hunt
//
//  Created by LiXiangCheng on 14/12/1.
//  Copyright (c) 2014年 LiXiangCheng. All rights reserved.
//

#import "BaseViewController.h"
//#import "LoginViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _statusBarStyle=DefaultStatusBarStyle;
    }
    return self;
}

- (void)dealloc{
    NSLog(@"%@: %@",NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] init]];
    
    // Create a custom back button
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.backBtn setTitleColor:DefaultNavTitleColor forState:UIControlStateNormal];
    [self.backBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
    self.backBtn.titleLabel.font = DefaultNavBarButtonFont;
    self.backBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.backBtn.frame = CGRectMake(0, 0, 44, 44);
    [_backBtn setImage:[UIImage imageNamed:@"Btn_Back"] forState:UIControlStateNormal];
    [_backBtn setImage:[UIImage imageNamed:@"Btn_Back_hl"] forState:UIControlStateHighlighted];
    [_backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:_backBtn];
    //UIBarButtonItem *leftBarItem = [UIBarButtonItem barButtonLeftWithTitle:@"左边" target:self action:@selector(leftBtn:)];
    
    UIBarButtonItem *leftSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    leftSeperator.width = -20;//此处修改到边界的距离，请自行测试
    [self.navigationItem setLeftBarButtonItems:@[leftSeperator,leftBarItem]];
    self.backBtn.hidden=NO;
    
    self.rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.rightBtn setTitleColor:DefaultNavTitleColor forState:UIControlStateNormal];
    [self.rightBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
    self.rightBtn.titleLabel.font = DefaultNavBarButtonFont;
    [self.rightBtn setImage:[UIImage imageNamed:@"Btn_Action"] forState:UIControlStateNormal];
    [self.rightBtn setImage:[UIImage imageNamed:@"Btn_Action_hl"] forState:UIControlStateHighlighted];
    self.rightBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.rightBtn.frame = CGRectMake(0, 0, 44, 44);
    [self.rightBtn addTarget:self action:@selector(rightBtn:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:self.rightBtn];
    UIBarButtonItem *rightSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    rightSeperator.width = -20;//此处修改到边界的距离，请自行测试
    [self.navigationItem setRightBarButtonItems:@[rightSeperator, rightBarItem]];
    self.rightBtn.hidden=YES;
    
    self.view.backgroundColor=DefaultVCViewBgColor;
}

//for ios7
- (UIStatusBarStyle)preferredStatusBarStyle{
    return self.statusBarStyle;
}

- (BOOL)prefersStatusBarHidden{
    return self.statusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation{
    return UIStatusBarAnimationFade;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        [self setNeedsStatusBarAppearanceUpdate];//ios7 刷新状态栏样式
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self pageviewStart];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self pageviewEnd];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
//8.0
- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator{
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context) {
        if (newCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
            //To Do: modify something for compact vertical size
        } else {
            //To Do: modify something for other vertical size
        }
        [self.view setNeedsLayout];
    } completion:nil];
}
 */

#pragma mark override

- (void)setTitle:(NSString *)title{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = DefaultNavTitleColor;
    titleLabel.font = DefaultNavTitleFont;
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;
}

#pragma mark Action

- (void)pageviewStart{
    /**
     *  标识某个页面访问的开始
     */
    [[BaiduMobStat defaultStat] pageviewStartWithName:NSStringFromClass([self class])];
    [AppDelegate sharedAppDelegate].pid=[NSString stringWithFormat:@"%@",@(self.view.tag)];
    [AppDelegate sharedAppDelegate].timestamp = [[NSDate date] timeIntervalSince1970];
    //[self logEventWithCat:@"0" action:@"100" type:nil val:nil ext:nil];
}

- (void)pageviewEnd{
    /**
     *  标识某个页面访问的结束，与pageviewStartWithName配对使用
     */
    [[BaiduMobStat defaultStat] pageviewEndWithName:NSStringFromClass([self class])];
    [AppDelegate sharedAppDelegate].p_pid=[NSString stringWithFormat:@"%@",@(self.view.tag)];
    double gapTime = [[NSDate date] timeIntervalSince1970] - [AppDelegate sharedAppDelegate].timestamp;
    NSLog(@"[%@]停留时长:%@",NSStringFromClass([self class]),@(gapTime));
    //[self logEventWithCat:@"0" action:@"101" type:@"102" val:@(gapTime).stringValue ext:nil];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)rightBtn:(id)sender{
}

- (void)updateStatusBar{
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self setNeedsStatusBarAppearanceUpdate];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:[self prefersStatusBarHidden] withAnimation:UIStatusBarAnimationNone];
    }
}

- (void)setNavBar{
    //布局
    //navBarView
    _navBarView = [[UIView alloc] initWithFrame:self.view.bounds];
    _navBarView.translatesAutoresizingMaskIntoConstraints = NO;
    _navBarView.backgroundColor=[UIColor clearColor];
    
    //navBarBgIV
    _navBarBgIV = [UIImageView new];
    _navBarBgIV.contentMode = UIViewContentModeScaleToFill;
    _navBarBgIV.translatesAutoresizingMaskIntoConstraints = NO;
    [_navBarView addSubview:_navBarBgIV];
    [_navBarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_navBarBgIV]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_navBarBgIV)]];
    [_navBarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_navBarBgIV]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_navBarBgIV)]];
    
    //navBarLeftBtn
    _navBarLeftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _navBarLeftBtn.titleLabel.font = DefaultNavBarButtonFont;
    [_navBarLeftBtn setImage:[UIImage imageNamed:@"Btn_Back"] forState:UIControlStateNormal];
    [_navBarLeftBtn setImage:[UIImage imageNamed:@"Btn_Back_hl"] forState:UIControlStateHighlighted];
    [_navBarLeftBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    _navBarLeftBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_navBarLeftBtn addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_navBarLeftBtn(44)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_navBarLeftBtn)]];
    [_navBarLeftBtn addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_navBarLeftBtn(44)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_navBarLeftBtn)]];
    [_navBarView addSubview:_navBarLeftBtn];
    [_navBarView addConstraint:[NSLayoutConstraint constraintWithItem:_navBarLeftBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_navBarView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
    //navBarTitleLbl
    _navBarTitleLbl = [UILabel new];
    _navBarTitleLbl.font = DefaultNavTitleFont;
    _navBarTitleLbl.textColor = DefaultNavTitleColor;
    _navBarTitleLbl.textAlignment=NSTextAlignmentCenter;
    _navBarTitleLbl.translatesAutoresizingMaskIntoConstraints = NO;
    [_navBarTitleLbl addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_navBarTitleLbl(44)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_navBarTitleLbl)]];
    [_navBarView addSubview:_navBarTitleLbl];
    [_navBarView addConstraint:[NSLayoutConstraint constraintWithItem:_navBarTitleLbl attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_navBarView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
    //navBarRightBtn
    _navBarRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _navBarRightBtn.titleLabel.font = DefaultNavBarButtonFont;
    [_navBarRightBtn setImage:[UIImage imageNamed:@"Btn_Action"] forState:UIControlStateNormal];
    [_navBarRightBtn setImage:[UIImage imageNamed:@"Btn_Action_hl"] forState:UIControlStateHighlighted];
    [_navBarRightBtn addTarget:self action:@selector(rightBtn:) forControlEvents:UIControlEventTouchUpInside];
    _navBarRightBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [_navBarRightBtn addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_navBarRightBtn(44)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_navBarRightBtn)]];
    [_navBarRightBtn addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_navBarRightBtn(44)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_navBarRightBtn)]];
    [_navBarView addSubview:_navBarRightBtn];
    [_navBarView addConstraint:[NSLayoutConstraint constraintWithItem:_navBarRightBtn attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_navBarView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    
    [_navBarView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(-5)-[_navBarLeftBtn]-6-[_navBarTitleLbl]-6-[_navBarRightBtn]-16-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_navBarLeftBtn,_navBarTitleLbl,_navBarRightBtn)]];
    
    [self.view addSubview:_navBarView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_navBarView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_navBarView)]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_navBarView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:_navBarView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:IS_IPHONE_X?88.0:64.0]];
    
    //初始值
    _navBarBgIV.image=[UIImage createImageWithColor:DefaultNavbarTintColor];
}

- (void)setNavigationBarAttribute:(UINavigationBar *)navigationBar{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        navigationBar.barTintColor=DefaultNavbarTintColor;//the bar background
        [navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:DefaultNavTitleColor, NSForegroundColorAttributeName, DefaultNavTitleFont, NSFontAttributeName, nil]];
        navigationBar.tintColor=DefaultNavTintColor;//Cancel button text color
    }
    //[navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];//默认毛玻璃效果
    [navigationBar setBackgroundImage:[UIImage createImageWithColor:DefaultNavbarTintColor] forBarMetrics:UIBarMetricsDefault];
    //NSArray *colorArray = @[MKRGBA(61,206,61,250),MKRGBA(70,212,255,250)];
    //UIImage *navigationBarBgImg=[UIImage imageFromColors:colorArray ByGradientType:leftToRight ToSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width, 64)];
}

- (void)setNavigationBar1Attribute:(UINavigationBar *)navigationBar{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        navigationBar.barTintColor=[UIColor whiteColor];//the bar background
        [navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor], NSForegroundColorAttributeName, [UIFont boldSystemFontOfSize:20], NSFontAttributeName, nil]];
        navigationBar.tintColor=[UIColor blackColor];//Cancel button text color
        
    }
    [navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
}

- (BOOL)authorityLogin:(BaseCompletion)completion
{
    UserModel *user = [UserModel loadCurRecord];
    BOOL isLogin = user && user.user_id>0;
    if (isLogin) {
        if (completion) { completion(); }
    }
    else {
        //UIViewController *vc = [[LoginViewController alloc] init];
        UIViewController *vc = [[BaseViewController alloc] init];
        NavRootViewController *nc = [[NavRootViewController alloc] initWithRootViewController:vc];
        nc.navigationBar.translucent = NO;
        [self presentViewController:nc animated:YES completion:nil];
    }
    return isLogin;
}

@end
