//
//  EmailViewController.m
//  CardBump
//
//  Created by 香成 李 on 12-01-29.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "EmailViewController.h"

@implementation EmailViewController

+ (BOOL)canSendMail {
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass && [mailClass canSendMail]) {
        return YES;
    }
    return NO;
}

@end
