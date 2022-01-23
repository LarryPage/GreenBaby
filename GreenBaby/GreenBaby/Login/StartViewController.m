//
//  StartViewController.m
//  GreenBaby
//
//  Created by LiXiangCheng on 15/7/30.
//  Copyright (c) 2015年 LiXiangCheng. All rights reserved.
//

#import "StartViewController.h"
#import "CitySelectViewController.h"

@interface StartViewController ()

@end

@implementation StartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title=@"登录";
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back {
//    CitySelectViewController *vc=[[CitySelectViewController alloc] init];
//    vc.curSelectId=@"123";
//    WEAKSELF
//    vc.selectCompletion=^(NSString *selectId){
//        [weakSelf showHudInView:self.view hint:@"请稍等..."];
//    };
//    [self.navigationController pushViewController:vc animated:YES];
    [FFRouteManager routeURL:[NSURL URLWithString:@"greenbaby://huijiame.com/common/web?url=https://brcagent.lybrc.com.cn/h5/activity/lifeHome/index.html?phone=13012345678#/"]];
}

@end
