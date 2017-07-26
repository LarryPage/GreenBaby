//
//  UINavigationBarHelper.m
//  CardBump
//
//  Created by 香成 李 on 11-12-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "UINavigationBarHelper.h"

static UIImage *navigationBarBgImg=nil;

//全部注释，默认透明
@implementation UINavigationBar (CustomNavigationBar)

//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
//#else
- (UIImage *)barBackground
{
    //return nil;//默认毛玻璃效果
    if (navigationBarBgImg==nil) {
//        navigationBarBgImg=[UIImage imageNamed:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone?@"navigationBarBackgroundRetro.png":@"navigationBarBackgroundRetro-Portrait.png"];
        navigationBarBgImg=[UIImage createImageWithColor:DefaultNavbarTintColor];
        //渐变
        //NSArray *colorArray = @[MKRGBA(61,206,61,250),MKRGBA(70,212,255,250)];
        //navigationBarBgImg=[UIImage imageFromColors:colorArray ByGradientType:leftToRight ToSize:CGSizeMake([[UIScreen mainScreen] bounds].size.width, 64)];
    }
    return navigationBarBgImg;
}

//this doesn't work on iOS5 but is needed for iOS4 and earlier
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [[self barBackground] drawInRect:rect];
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0) {
        self.shadowImage = [[UIImage alloc] init];//shadow image to get rid of the line.
    }
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        self.tintColor=DefaultNavTintColor;//Cancel button text color
        self.barTintColor=DefaultNavbarTintColor;//the bar background
    }
    else{
        self.tintColor = DefaultNavbarTintColor;
    }
}

//iOS5 only
- (void)didMoveToSuperview
{
    if ([self respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    {
        [self setBackgroundImage:[self barBackground] forBarMetrics:UIBarMetricsDefault];
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0) {
            self.shadowImage = [[UIImage alloc] init];//shadow image to get rid of the line.
        }
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
            self.tintColor=DefaultNavTintColor;//Cancel button text color
            self.barTintColor=DefaultNavbarTintColor;//the bar background
        }
        else{
            self.tintColor = DefaultNavbarTintColor;
        }
    }
}
//#endif

@end

