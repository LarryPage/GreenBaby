//
//  CallViewController.m
//  CardBump
//
//  Created by 香成 李 on 12-1-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CallViewController.h"

UIWebView *gPhoneCallWebView=nil;

@implementation CallViewController

+ (BOOL)canCallPhone {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]])
        return YES;
    return NO;
}

+(void)CallPhone:(NSString *)phoneNum{
    NSString *pureNumbers = [[phoneNum componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
    
    NSURL *phoneURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",pureNumbers]];
    if (!gPhoneCallWebView) {
        gPhoneCallWebView = [[UIWebView alloc] initWithFrame:CGRectZero];
        //这个webView只是一个后台的容易 不需要add到页面上来  这个方法是合法的
        
    }
    [gPhoneCallWebView loadRequest:[NSURLRequest requestWithURL:phoneURL]];
    
}

@end
