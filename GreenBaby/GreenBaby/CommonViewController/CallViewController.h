//
//  CallViewController.h
//  CardBump
//
//  Created by 香成 李 on 12-1-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CallViewController : UIViewController

+ (BOOL)canCallPhone;
+ (void)CallPhone:(NSString *)phoneNum;

@end
