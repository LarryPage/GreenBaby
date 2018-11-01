//
//  FFATLayoutAttributes.h
//  BrcIot
//
//  Created by LiXiangCheng on 2018/10/29.
//  Copyright © 2018年 BRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFATLayoutAttributes : NSObject

+ (CGRect)contentViewSpreadFrame;
+ (CGPoint)cotentViewDefaultPoint;
+ (CGFloat)itemWidth;
+ (CGFloat)itemImageWidth;
+ (CGFloat)cornerRadius;
+ (CGFloat)margin;
+ (NSUInteger)maxCount;

+ (CGFloat)inactiveAlpha;
+ (CGFloat)animationDuration;
+ (CGFloat)activeDuration;

@end
