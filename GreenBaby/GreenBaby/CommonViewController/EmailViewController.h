//
//  EmailViewController.h
//  CardBump
//
//  Created by 香成 李 on 12-01-29.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface EmailViewController : MFMailComposeViewController

+ (BOOL)canSendMail;

@end
