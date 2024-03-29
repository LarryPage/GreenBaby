//
//  LNNotification.h
//  LNNotificationsUI
//
//  Created by LiXiangCheng on 14/12/1.
//  Copyright (c) 2014年 LiXiangCheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface LNNotification : NSObject <NSCopying, NSSecureCoding>

+ (instancetype)notificationWithMessage:(NSString*)message;
+ (instancetype)notificationWithTitle:(NSString*)title message:(NSString*)message;
+ (instancetype)notificationWithTitle:(NSString*)title message:(NSString*)message icon:(UIImage*)icon date:(NSDate*)date;

- (instancetype)initWithMessage:(NSString*)message;
- (instancetype)initWithTitle:(NSString*)title message:(NSString*)message;
- (instancetype)initWithTitle:(NSString*)title message:(NSString*)message icon:(UIImage*)icon date:(NSDate*)date NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_DESIGNATED_INITIALIZER;

@property (nonatomic, copy) NSString* title;
@property (nonatomic, copy) NSString* message;
@property (nonatomic, strong) UIImage* icon;
@property (nonatomic, copy) NSDate* date;
@property (nonatomic) BOOL displaysWithRelativeDateFormatting;

@property (nonatomic, copy) NSString* alertAction NS_UNAVAILABLE;

@end
