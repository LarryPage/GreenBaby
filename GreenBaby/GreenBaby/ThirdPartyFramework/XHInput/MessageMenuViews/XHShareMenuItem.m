//
//  XHShareMenuItem.m
//  MessageDisplayExample
//
//  Created by LiXiangCheng on 14-5-1.
//  Copyright (c) 2014年 LiXiangCheng. All rights reserved.
//

#import "XHShareMenuItem.h"

@implementation XHShareMenuItem

- (instancetype)initWithNormalIconImage:(UIImage *)normalIconImage
                                  title:(NSString *)title {
    self = [super init];
    if (self) {
        self.normalIconImage = normalIconImage;
        self.title = title;
    }
    return self;
}

- (void)dealloc {
    self.normalIconImage = nil;
    self.title = nil;
}

@end
