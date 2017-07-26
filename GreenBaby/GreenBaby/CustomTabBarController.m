//
//  CustomTabBarController.m
//  BBPush
//
//  Created by Li XiangCheng on 13-3-10.
//  Copyright (c) 2013年 Li XiangCheng. All rights reserved.
//

#import "CustomTabBarController.h"

@implementation CustomTabBarController

#pragma mark - View lifecycle

-(id)init
{
    if (self=[super init]) {
        //
    }
    return self;
}

- (void)dealloc{
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        // Change the tab bar background
        // this will generate a color tab bar
        self.tabBar.barTintColor =DefaultTabbarTintColor;
        //self.tabBar.barTintColor = [[[UIColor alloc] initWithCGColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"tabBarBg.png"]] CGColor]];
        //self.tabBar.selectionIndicatorImage=[UIImage createImageWithColor:MKRGBA(31,41,51,255) withSize:CGSizeMake(self.tabBar.frame.size.width/4, 49)];
        //self.tabBar.selectionIndicatorImage=[UIImage imageNamed:@"tabBarBg.png"];
        
        // this will give selected icons and text your apps tint color
        self.tabBar.tintColor = DefaultTabTintColor;
        // Change the title color of tab bar items
        [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           DefaultTabTitleColor_N, NSForegroundColorAttributeName,DefaultTabTitleFont_N, NSFontAttributeName,
                                                           nil] forState:UIControlStateNormal];
        [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           DefaultTabTitleColor_S, NSForegroundColorAttributeName,DefaultTabTitleFont_S, NSFontAttributeName,
                                                           nil] forState:UIControlStateSelected];
        
        self.tabBar.translucent=YES;//7.0  default Yes
    }
    else{
        //self.view.backgroundColor = [UIColor clearColor];
        //self.tabBar.backgroundImage=[UIImage imageNamed:@"tabBarBgImage.png"];
        //UIImage *tabBarBgImage=[UIImage imageNamed:@"tabBarBgImage.png"];
        //UIImage *tabBarBgImage=[UIImage imageNamed:@"tabBarBg.png"];
        UIImage *tabBarBgImage=[UIImage createImageWithColor:DefaultTabbarTintColor];
        UITabBar *tabBar = [self tabBar];
        if ([tabBar respondsToSelector:@selector(setBackgroundImage:)])
        {
            // ios 5 code here
            [tabBar setBackgroundImage:tabBarBgImage];
        }
        else
        {
            // ios 4 code here
            CGRect frame = CGRectMake(0, 0, 320, 49);
            UIView *tabbg_view = [[UIView alloc] initWithFrame:frame];
            UIImage *tabbag_image = tabBarBgImage;
            UIColor *tabbg_color = [[UIColor alloc] initWithPatternImage:tabbag_image];
            tabbg_view.backgroundColor = tabbg_color;
            [tabBar insertSubview:tabbg_view atIndex:0];
        }
    }
    
    
    UIViewController *vc1 = [[BaseViewController alloc] init];
    UINavigationController* nc1 = [[NavRootViewController alloc]initWithRootViewController:vc1];
    nc1.tabBarItem.image = [[UIImage imageNamed:@"TabBar1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nc1.tabBarItem.selectedImage = [[UIImage imageNamed:@"TabBar1_hl"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];//ios7.0
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 5.0) {//5,0 default Yes
        [nc1.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -3)];
    }
    [nc1 setTitle:@"猎头圈"];
    //int offset = 6;
    //UIEdgeInsets imageInset = UIEdgeInsetsMake(offset, 0, -offset, 0);
    //nc1.tabBarItem.imageInsets = imageInset;
    nc1.navigationBar.translucent = NO; //7,0 default Yes
    //nc1.tabBarItem.badgeValue=@"1";
    
    UIViewController *vc2 = [[BaseViewController alloc] init];
    UINavigationController* nc2 = [[NavRootViewController alloc]initWithRootViewController:vc2];
    nc2.tabBarItem.image = [[UIImage imageNamed:@"TabBar2"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nc2.tabBarItem.selectedImage = [[UIImage imageNamed:@"TabBar2_hl"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];//ios7.0
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 5.0) {//5,0 default Yes
        [nc2.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -3)];
    }
    [nc2 setTitle:@"消息"];
    //nc2.tabBarItem.imageInsets = imageInset;
    nc2.navigationBar.translucent = NO; //7,0 default Yes
    
    UIViewController *vc3 = [[BaseViewController alloc] init];
    UINavigationController* nc3 = [[NavRootViewController alloc]initWithRootViewController:vc3];
    nc3.tabBarItem.image = [[UIImage imageNamed:@"TabBar3"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nc3.tabBarItem.selectedImage = [[UIImage imageNamed:@"TabBar3_hl"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];//ios7.0
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 5.0) {//5,0 default Yes
        [nc3.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -3)];
    }
    [nc3 setTitle:@"发现"];
    //nc3.tabBarItem.imageInsets = imageInset;
    nc3.navigationBar.translucent = NO; //7,0 default Yes
    
    UIViewController *vc4 = [[BaseViewController alloc] init];
    UINavigationController* nc4 = [[NavRootViewController alloc]initWithRootViewController:vc4];
    nc4.tabBarItem.image = [[UIImage imageNamed:@"TabBar4"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nc4.tabBarItem.selectedImage = [[UIImage imageNamed:@"TabBar4_hl"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];//ios7.0
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 5.0) {//5,0 default Yes
        [nc4.tabBarItem setTitlePositionAdjustment:UIOffsetMake(0, -3)];
    }
    [nc4 setTitle:@"我"];
    //nc4.tabBarItem.imageInsets = imageInset;
    nc4.navigationBar.translucent = NO; //7,0 default Yes
    
    self.viewControllers = [NSArray arrayWithObjects:nc1,nc2,nc3,nc4,nil];
    
    self.delegate=self;
    
    //添加tabbar中有消息的小红点.需要注意的是坐标x，y一定要是整数，否则会有模糊。
    if (IS_IPAD) {
        NSUInteger left=164;
        NSUInteger tabBarItemWidth=110;
        for (int i = 0; i< 4; i++) {
            UIImageView *dotIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dot"]];
            dotIV.tag = RED_DOT_TAG+i;
            CGFloat x = ceilf(left+i*tabBarItemWidth+tabBarItemWidth/2+24/2);
            CGFloat y = ceilf((49-24)/2-4);
            dotIV.frame = CGRectMake(x, y, 8, 8);
            dotIV.hidden = YES;
            [self.tabBar addSubview:dotIV];
        }
    }
    else{
        NSUInteger tabBarItemWidth=self.tabBar.frame.size.width/4;
        for (int i = 0; i< 4; i++) {
            UIImageView *dotIV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dot"]];
            dotIV.tag = RED_DOT_TAG+i;
            CGFloat x = ceilf(i*tabBarItemWidth+tabBarItemWidth/2+24/2);
            CGFloat y = ceilf((49-24)/2-5);
            dotIV.frame = CGRectMake(x, y, 8, 8);
            dotIV.hidden = YES;
            [self.tabBar addSubview:dotIV];
        }
    }
    
    //[self addTabBarBadge:0];
    self.selectedIndex=0;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self addCenterButtonWithImage:[UIImage imageNamed:@"cameraTabBarItem"] highlightImage:nil];
}

#pragma mark UITabBarControllerDelegate methods

// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    //viewController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",0];
    //viewController.tabBarItem.badgeValue = nil;
    switch (self.selectedIndex) {
        case 0:
        {
            if (_selectedIdx == self.selectedIndex) {//当前页刷新
//                BaseViewController *vc=(BaseViewController *)[[AppDelegate sharedAppDelegate].window topViewController];
//                [vc ViewFrashData];
            }
        }
            break;
        case 1:
            [[BaiduMobStat defaultStat] logEvent:@"msg_home_5.0" eventLabel:@"消息页面"];
            break;
        case 2:
            break;
        case 3:
            break;
        default:
            break;
    }
    _selectedIdx=self.selectedIndex;
//    for (int tabIndex=0; tabIndex<=3; tabIndex++) {
//        ((UITabBarItem *)[self.tabBar.items objectAtIndex:tabIndex]).image=[[UIImage imageNamed:[NSString stringWithFormat:@"TabBar%d",tabIndex+1]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        ((UITabBarItem *)[self.tabBar.items objectAtIndex:tabIndex]).selectedImage=[[UIImage imageNamed:[NSString stringWithFormat:@"TabBar%d_hl",tabIndex+1]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];//7,0 default Yes
//    }
}

/*
 // Optional UITabBarControllerDelegate method.
 - (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
 }
 */

#pragma mark - TabBarAnimation

- (void)addTabBarBadge:(NSString *)badge tabIndex:(NSUInteger)tabIndex{
    ((UITabBarItem *)[self.tabBar.items objectAtIndex:tabIndex]).badgeValue=badge;
}

- (void)showTabbarReddots:(NSUInteger)tabIndex{
//    ((UITabBarItem *)[self.tabBar.items objectAtIndex:tabIndex]).image=[[UIImage imageNamed:[NSString stringWithFormat:@"TabBar%@_badge",@(tabIndex+1)]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    ((UITabBarItem *)[self.tabBar.items objectAtIndex:tabIndex]).selectedImage=[[UIImage imageNamed:[NSString stringWithFormat:@"TabBar%@_badge_hl",@(tabIndex+1)]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];//7,0 default Yes
    
    UIImageView *dotIV=(UIImageView *)[self.tabBar viewWithTag:RED_DOT_TAG+tabIndex];
    dotIV.hidden = NO;
}

- (void)hideTabbarReddots:(NSUInteger)tabIndex{
    UIImageView *dotIV=(UIImageView *)[self.tabBar viewWithTag:RED_DOT_TAG+tabIndex];
    dotIV.hidden = YES;
}

// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(centerBtn:) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    
    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
    if (heightDifference < 0)
        button.frame = CGRectMake((self.tabBar.frame.size.width-buttonImage.size.width)/2, (self.tabBar.frame.size.height-buttonImage.size.height)/2, buttonImage.size.width, buttonImage.size.height);
    else
        button.frame = CGRectMake((self.tabBar.frame.size.width-buttonImage.size.width)/2, (self.tabBar.frame.size.height-buttonImage.size.height)/2-heightDifference/2.0, buttonImage.size.width, buttonImage.size.height);
    
    [self.tabBar addSubview:button];
}

-(void)centerBtn:(id)sender{
    self.selectedIndex=1;
}

@end