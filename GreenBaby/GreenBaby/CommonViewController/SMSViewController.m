//
//  SMSViewController.m
//  CardBump
//
//  Created by 香成 李 on 12-01-29.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "SMSViewController.h"

@implementation SMSViewController

+ (BOOL)canSendText {
    Class messageClass = (NSClassFromString(@"MFMessageComposeViewController"));
    if(messageClass && [messageClass canSendText])
        return YES;
    return NO;
}

@end
