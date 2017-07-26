//
//  LNViewController.m
//  EHome
//
//  Created by LiXiangCheng on 15/10/10.
//  Copyright © 2015年 MeiLin. All rights reserved.
//

#import "LNViewController.h"

@interface LNViewController ()

@end

@implementation LNViewController

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

//for ios7
- (UIStatusBarStyle)preferredStatusBarStyle{
    return DefaultStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden{
    return NO;
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
