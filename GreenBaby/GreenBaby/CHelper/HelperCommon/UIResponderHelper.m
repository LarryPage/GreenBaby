//
//  UIResponderHelper.m
//  Hunt
//
//  Created by LiXiangCheng on 15/6/14.
//  Copyright (c) 2015年 LiXiangCheng. All rights reserved.
//

#import "UIResponderHelper.h"

@implementation UIResponder (Router)

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    [[self nextResponder] routerEventWithName:eventName userInfo:userInfo];
}

@end
