//
//  LNNotificationWindow.h
//  LNNotificationsUI
//
//  Created by LiXiangCheng on 14/12/1.
//  Copyright (c) 2014年 LiXiangCheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LNNotification.h"

@interface LNNotificationWindow : UIWindow

@property (nonatomic, readonly) BOOL isNotificationViewShown;

- (void)presentNotification:(LNNotification*)notification completionBlock:(void(^)(void))completionBlock;
- (void)dismissNotificationViewWithCompletionBlock:(void(^)(void))completionBlock;

@end
