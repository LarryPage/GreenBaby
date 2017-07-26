//
//  CustomTabBarController.h
//  BBPush
//
//  Created by Li XiangCheng on 13-3-10.
//  Copyright (c) 2013年 Li XiangCheng. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RED_DOT_TAG 100

@interface CustomTabBarController : UITabBarController<UITabBarControllerDelegate>{
    NSUInteger _selectedIdx;//当前选择的tabIndex
}

- (void)addTabBarBadge:(NSString *)badge tabIndex:(NSUInteger)tabIndex;
- (void)showTabbarReddots:(NSUInteger)tabIndex;
- (void)hideTabbarReddots:(NSUInteger)tabIndex;

// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage;

@end
