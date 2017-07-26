//
//  LNNotificationView.h
//  LNNotificationsUI
//
//  Created by LiXiangCheng on 14/12/1.
//  Copyright (c) 2014年 LiXiangCheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LNNotification;

@interface LNNotificationView : UIView

#ifdef __IPHONE_8_0
@property (nonatomic, strong, readonly) UIVisualEffectView* backgroundView;
#else
@property (nonatomic, strong, readonly) UIView* backgroundView;
#endif
@property (nonatomic, strong, readonly) UIView* notificationContentView;

- (void)configureForNotification:(LNNotification*)notification;

@property (nonatomic, strong, readonly) LNNotification* currentNotification;

@end
