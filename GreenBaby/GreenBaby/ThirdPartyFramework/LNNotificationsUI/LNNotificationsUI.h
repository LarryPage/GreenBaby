//
//  LNNotificationsUI.h
//  LNNotificationsUI
//
//  Created by LiXiangCheng on 14/12/1.
//  Copyright (c) 2014年 LiXiangCheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LNNotification.h"
#import "LNNotificationCenter.h"

/*
 //使用说明
[[LNNotificationCenter defaultCenter] registerApplicationWithIdentifier:kBundleIdentifier name:kProductName icon:nil];

LNNotification* notification = [LNNotification notificationWithMessage:@"Welcome to LNNotificationsUI!"];
notification.title = @"Hello World!";
notification.date = [[NSDate date] dateByAddingTimeInterval:-60 * 60 * 24];

[[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:kBundleIdentifier];

[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWasTapped:) name:LNNotificationWasTappedNotification object:nil];

#pragma mark LNNotificationCenter

- (void)notificationWasTapped:(NSNotification*)notification{
    LNNotification* tappedNotification = notification.object;
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:tappedNotification.title message:tappedNotification.message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}
*/