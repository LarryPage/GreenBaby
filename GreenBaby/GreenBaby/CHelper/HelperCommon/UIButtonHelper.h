//
//  UIButtonHelper.h
//  CardBump
//
//  Created by sbtjfdn on 12-5-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define LEFT_BAR_BUTTON 100
#define RIGHT_BAR_BUTTON 101

@interface UIButton (custom)

@end

//https://mp.weixin.qq.com/s/iBELEyUfnShnLhS5xJh4mQ
//[button enableEventTracking];//自动埋点
@interface UIButton (Tracking)
- (void)enableEventTracking;
@end
