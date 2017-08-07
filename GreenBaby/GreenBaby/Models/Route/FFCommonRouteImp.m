//
//  FFCommonRouteImp.m
//  FFRouteManager
//
//  Created by LiXiangCheng on 16/10/14.
//  Copyright © 2016年 wanda. All rights reserved.
//

#import "FFCommonRouteImp.h"

@implementation FFCommonRouteImp

-(void) registerRoute
{
    //打开新的网页
    [FFRouteManager addRoute:COMMON_WEB handler:^id(NSDictionary *parameters) {
        BaseViewController *curVC=(BaseViewController *)[[AppDelegate sharedAppDelegate].window topViewController];
        
        NSURL *url = parameters[kFFRouteURLKey];
        CLog(@"%@:%@:%@",[url scheme],[url path],[url query]);
        //NSArray *paths=[[url path] componentsSeparatedByString:@"/"];
        //NSDictionary *params=[[url query] queryDictionaryUsingEncoding:NSUTF8StringEncoding];
        NSString *title = parameters[@"title"];
        
        WebViewController *vc = [[WebViewController alloc] initWithUrl:[url absoluteString] title:title];
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
