//
//  FFATLayoutAttributes.m
//  BrcIot
//
//  Created by LiXiangCheng on 2018/10/29.
//  Copyright © 2018年 BRC. All rights reserved.
//

#import "FFATLayoutAttributes.h"

@implementation FFATLayoutAttributes

+ (CGRect)contentViewSpreadFrame {
    CGFloat spreadWidth = IS_IPAD? 390: 295;
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    CGRect frame = CGRectMake((CGRectGetWidth(screenFrame) - spreadWidth) / 2,
                              (CGRectGetHeight(screenFrame) - spreadWidth) / 2,
                              spreadWidth, spreadWidth);
    return frame;
}

+ (CGPoint)cotentViewDefaultPoint {
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    CGPoint point = CGPointMake(CGRectGetWidth(screenFrame)
                                - [self itemImageWidth] / 2
                                - [self margin],
                                CGRectGetMidY(screenFrame));
    return point;
}

+ (CGFloat)itemWidth {
    return CGRectGetWidth([self contentViewSpreadFrame]) / 3.0;
}

+ (CGFloat)itemImageWidth {
    return IS_IPAD? 76: 60;
}

+ (CGFloat)cornerRadius {
    return 14;
}

+ (CGFloat)margin {
    return 2;
}

+ (NSUInteger)maxCount {
    return 8;
}

+ (CGFloat)inactiveAlpha {
    return 0.4;
}

+ (CGFloat)animationDuration {
    return 0.25;
}

+ (CGFloat)activeDuration {
    return 4;
}

@end
