//
//  TimeHeaderView.h
//  CardBump
//
//  Created by 香成 李 on 12-5-2８.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#define TIME_HEADER_HEIGHT 30

@interface TimeHeaderView : UIView

- (void)showTime:(NSTimeInterval)time;
- (void)showDate:(NSString *)date;

@end
