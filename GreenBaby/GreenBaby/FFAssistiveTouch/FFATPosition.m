//
//  FFATPosition.m
//  BrcIot
//
//  Created by LiXiangCheng on 2018/10/29.
//  Copyright © 2018年 BRC. All rights reserved.
//

#import "FFATPosition.h"
#import "FFATLayoutAttributes.h"

@implementation FFATPosition

+ (instancetype)positionWithCount:(NSInteger)count index:(NSInteger)index {
    return [[self alloc] initWithCount:count index:index];
}

- (instancetype)init {
    return [self initWithCount:0 index:0];
}

- (instancetype)initWithCount:(NSInteger)count index:(NSInteger)index {
    self = [super init];
    if (self) {
        _count = count < 0? 0: count;
        _count = _count > [FFATLayoutAttributes maxCount]? [FFATLayoutAttributes maxCount]: _count;
        _index = index < 0? 0: index;
        _index = _index > _count? [FFATLayoutAttributes maxCount]: _index;
        _center = [self getCenter];
        _frame = [self getFrame];
    }
    return self;
}

- (CGPoint)getCenter {
    //If count is zero ,make contentItem spread to (1,1)
    NSInteger count = _count;
    NSInteger index = _index;
    if (!_count) {
        count = 1;
        index = 1;
    }
    CGFloat angle = 5 * M_PI_2 - M_PI * 2 / count * index;
    CGFloat k = tan(angle);
    CGFloat x = 0;
    CGFloat y = 0;
    if (M_PI_4 * 9 < angle || angle <= M_PI_4 * 3) {
        y = [FFATLayoutAttributes itemWidth];
        if (angle == M_PI_2 * 5 || angle == M_PI_2 * 3) {
            x = 0;
        } else {
            x = y / k;
        }
    } else if (M_PI_4 * 7 < angle && angle <= M_PI_4 * 9) {
        x = [FFATLayoutAttributes itemWidth];
        y = k * x;
    } else if (M_PI_4 * 5 < angle && angle <= M_PI_4 * 7) {
        y = -[FFATLayoutAttributes itemWidth];
        if (angle == M_PI_2 * 5 || angle == M_PI_2 * 3) {
            x = 0;
        } else {
            x = y / k;
        }
    } else if (M_PI_4 * 3 < angle && angle <= M_PI_4 * 5) {
        x = -[FFATLayoutAttributes itemWidth];
        y = k * x;
    }
    CGPoint center = [self coordinatesTransform:CGPointMake(x, y)];
    return center;
}

- (CGRect)getFrame {
    CGPoint center = self.center;
    CGRect frame = CGRectMake(center.x - [FFATLayoutAttributes itemWidth] / 2,
                              center.y - [FFATLayoutAttributes itemWidth] / 2,
                              [FFATLayoutAttributes itemWidth],
                              [FFATLayoutAttributes itemWidth]);
    return frame;
}

- (CGPoint)coordinatesTransform:(CGPoint)point {
    CGRect rect = [UIScreen mainScreen].bounds;
    CGPoint screenCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    point.y = -point.y;
    CGPoint transformPoint = CGPointMake(screenCenter.x + point.x,
                                         screenCenter.y + point.y);
    return transformPoint;
}

@end
