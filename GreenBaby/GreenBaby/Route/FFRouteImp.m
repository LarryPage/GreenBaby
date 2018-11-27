//
//  FFRouteImp.m
//  GreenBaby
//
//  Created by LiXiangCheng on 2017/8/11.
//  Copyright © 2017年 LiXiangCheng. All rights reserved.
//

#import "FFRouteImp.h"

@implementation FFRouteImp

-(void) registerRoute
{
    //打开新的网页
    [FFRouteManager addRoute:COMMON_WEB handler:^id(NSDictionary *parameters) {
        BaseViewController *curVC=(BaseViewController *)[[AppDelegate sharedAppDelegate].window topViewController];
        
        NSURL *routeUrl = parameters[kFFRouteURLKey];
        NSLog(@"%@:%@:%@",[routeUrl scheme],[routeUrl path],[routeUrl query]);
        //NSArray *paths=[[routeUrl path] componentsSeparatedByString:@"/"];
        //NSDictionary *params=[[routeUrl query] queryDictionaryUsingEncoding:NSUTF8StringEncoding];
        NSString *url = parameters[@"url"];
        NSString *title = parameters[@"title"];
        BOOL navBarHidden = [parameters[@"navbarhidden"] integerValue];
        NSString *navBarBgColor = parameters[@"navbarbgcolor"];
        
        WebViewController *vc = [[WebViewController alloc] initWithUrl:url title:title];
        vc.navBarHidden=navBarHidden;
        vc.navBarBgColor=navBarBgColor;
        vc.hidesBottomBarWhenPushed=YES;
        [curVC.navigationController pushViewController:vc animated:YES];
        
        void (^completion)(id result) = parameters[kFFRouteCompleteBlockKey];
        if(completion)
        {
            completion(nil);
        }
        
        return nil;
    } impClass:[self class]];
    
}

@end
