//
//  SMSViewController.h
//  CardBump
//
//  Created by 香成 李 on 12-01-29.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <MessageUI/MessageUI.h>

@interface SMSViewController : MFMessageComposeViewController

// 由于MFMessageComposeViewController只在iOS4.0及之后的系统中支持，因此该方法会检查是否可以使用该类，
// 有两种情况该方法会返回NO，一种是iOS系统小于4.0，另一种情况是系统不支持短信服务。
+ (BOOL)canSendText;

@end
