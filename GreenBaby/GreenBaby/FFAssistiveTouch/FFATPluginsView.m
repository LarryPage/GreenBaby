//
//  FFATPluginsView.m
//  BrcIot
//
//  Created by LiXiangCheng on 2018/10/29.
//  Copyright © 2018年 BRC. All rights reserved.
//

#import "FFATPluginsView.h"

@implementation FFATPluginsView

+ (instancetype)itemWithType:(FFATPluginViewType)type customImg:(NSString *)imageName {
    CALayer *layer = nil;
    switch (type) {
        case FFATPluginViewTypeSystem:
            layer = [self createLayerSystemType];
            break;
        case FFATPluginViewTypeNone:
            layer = [self createLayerWithNoneType];
            break;
        case FFATPluginViewTypeBack:
            layer = [self createLayerBackType];
            break;
        case FFATPluginViewTypeStar:
            layer = [self createLayerStarType];
            break;
        case FFATPluginViewTypeCustom:
            layer = [self itemWithImage:[UIImage imageNamed:imageName]];
            break;
        default: {
            if (type >= FFATPluginViewTypeCount) {
                NSInteger count = type - FFATPluginViewTypeCount;
                layer = [self createLayerWithCount:count];
            }
            break;
        }
    }
    FFATPluginsView *item = [[self alloc] initWithLayer:layer];
    if (type == FFATPluginViewTypeSystem) {
        item.bounds = CGRectMake(0, 0, [FFATLayoutAttributes itemImageWidth], [FFATLayoutAttributes itemImageWidth]);
        item.layer.zPosition = FLT_MAX;
    }
    return item;
}

+ (instancetype)itemWithLayer:(CALayer *)layer {
    return [[self alloc] initWithLayer:layer];
}

+ (instancetype)itemWithImage:(UIImage *)image {
    CGSize size = CGSizeMake(MIN(image.size.width, [FFATLayoutAttributes itemWidth]), MIN(image.size.height, [FFATLayoutAttributes itemWidth]));
    CALayer *layer = [CALayer layer];
    layer.contents = (__bridge id)image.CGImage;
    layer.bounds = CGRectMake(0, 0, size.width, size.height);
    return [[self alloc] initWithLayer:layer];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithLayer:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithLayer:nil];
}

- (instancetype)initWithLayer:(nullable CALayer *)layer {
    self = [super initWithFrame:CGRectMake(0, 0, [FFATLayoutAttributes itemWidth], [FFATLayoutAttributes itemWidth])];
    if (self) {
        if (layer) {
            layer.contentsScale = [UIScreen mainScreen].scale;
            if (CGRectEqualToRect(layer.bounds, CGRectZero)) {
                layer.bounds = CGRectMake(0, 0, [FFATLayoutAttributes itemImageWidth], [FFATLayoutAttributes itemImageWidth]);
            }
            if (CGPointEqualToPoint(layer.position, CGPointZero)) {
                layer.position = CGPointMake([FFATLayoutAttributes itemWidth] / 2,
                                             [FFATLayoutAttributes itemWidth] / 2);
            }
            [self.layer addSublayer:layer];
        }
        _nameLbl=[[UILabel alloc] initWithFrame:CGRectMake(layer.frame.origin.x, layer.frame.origin.y+layer.frame.size.height+2, layer.frame.size.width, 21)];
        _nameLbl.textColor=[UIColor whiteColor];
        _nameLbl.font=[UIFont systemFontOfSize:13];
        _nameLbl.textAlignment=NSTextAlignmentCenter;
        [self addSubview:_nameLbl];
        
    }
    return self;
}

#pragma mark - CreateLayer

+ (CALayer *)createLayerWithNoneType {
    return [CALayer layer];
}

+ (CALayer *)createLayerSystemType {
    CALayer *layer = [CALayer layer];
    [layer addSublayer:[[self class] createInnerCircle:FFATInnerCircleLarge]];
    [layer addSublayer:[[self class] createInnerCircle:FFATInnerCircleMiddle]];
    [layer addSublayer:[[self class] createInnerCircle:FFATInnerCircleSmall]];
    layer.position = CGPointMake([FFATLayoutAttributes itemImageWidth] / 2, [FFATLayoutAttributes itemImageWidth] / 2);
    return layer;
}

+ (CALayer *)createLayerBackType {
    CAShapeLayer *layer = [CAShapeLayer layer];
    CGSize size = CGSizeMake(22, 22);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, size.height / 2)];
    [path addLineToPoint:CGPointMake(size.width / 2, 8.5 + size.height / 2)];
    [path addLineToPoint:CGPointMake(size.width / 2, 3.5 + size.height / 2)];
    [path addLineToPoint:CGPointMake(size.width, 3.5 + size.height / 2)];
    [path addLineToPoint:CGPointMake(size.width, -3.5 + size.height / 2)];
    [path addLineToPoint:CGPointMake(size.width / 2, -3.5 + size.height / 2)];
    [path addLineToPoint:CGPointMake(size.width / 2, -8.5 + size.height / 2)];
    [path closePath];
    layer.path = path.CGPath;
    layer.lineWidth = 2;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor whiteColor].CGColor;
    layer.bounds = CGRectMake(0, 0, size.width, size.height);
    return layer;
}

+ (CALayer *)createLayerStarType {
    CAShapeLayer *layer = [CAShapeLayer layer];
    CGSize size = CGSizeMake([FFATLayoutAttributes itemImageWidth], [FFATLayoutAttributes itemImageWidth]);
    CGFloat numberOfPoints = 5;
    CGFloat starRatio = 0.5;
    CGFloat steps = numberOfPoints * 2;
    CGFloat outerRadius = MIN(size.height, size.width) / 2;
    CGFloat innerRadius = outerRadius * starRatio;
    CGFloat stepAngle = 2 * M_PI / steps;
    CGPoint center = CGPointMake(size.width / 2, size.height / 2);
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (int i = 0; i < steps; i++) {
        CGFloat radius = i % 2 == 0 ? outerRadius : innerRadius;
        CGFloat angle = i * stepAngle - M_PI_2;
        CGFloat x = radius * cos(angle) + center.x;
        CGFloat y = radius * sin(angle) + center.y;
        if (i == 0) {
            [path moveToPoint:CGPointMake(x, y)];
        } else {
            [path addLineToPoint:CGPointMake(x, y)];
        }
    }
    [path closePath];
    layer.path = path.CGPath;
    layer.fillColor = [UIColor whiteColor].CGColor;
    return layer;
}

+ (CALayer *)createLayerWithCount:(NSInteger)count {
    CAShapeLayer *layer = [CAShapeLayer layer];
    CGRect bounds = CGRectMake(0, 0, [FFATLayoutAttributes itemImageWidth], [FFATLayoutAttributes itemImageWidth]);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:bounds];
    [path appendPath:[[UIBezierPath bezierPathWithOvalInRect:CGRectInset(bounds, 5, 5)] bezierPathByReversingPath]];
    layer.path = path.CGPath;
    layer.fillColor = [UIColor whiteColor].CGColor;
    layer.bounds = bounds;
    
    CATextLayer *textLayer = [CATextLayer layer];
    if (count >= 10 || count < 0) {
        textLayer.string = @"!";
    } else {
        textLayer.string = [NSString stringWithFormat:@"%@", @(count)];
    }
    textLayer.fontSize = 48;
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.bounds = bounds;
    textLayer.position = CGPointMake(CGRectGetMidX(layer.bounds), CGRectGetMidY(layer.bounds));
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    [layer addSublayer:textLayer];
    
    return layer;
}

+ (CAShapeLayer *)createInnerCircle:(FFATInnerCircle)circleType {
    
    // iPad   width 390 itemWidth 76 margin 2 corner:14  48-41-33
    // iPhone width 295 itemWidth 60 margin 2 corner:14  44-38-30
    
    CGFloat circleAlpha = 0;
    CGFloat radius = 0;
    CGFloat borderAlpha = 0;
    switch (circleType) {
        case FFATInnerCircleSmall: {
            circleAlpha = 1;
            radius = IS_IPAD? 16: 14.5;
            borderAlpha = 0.3;
            break;
        } case FFATInnerCircleMiddle: {
            circleAlpha = 0.4;
            radius = IS_IPAD? 20: 18.5;
            borderAlpha = 0.15;
            break;
        } case FFATInnerCircleLarge: {
            circleAlpha = 0.2;
            radius = IS_IPAD? 24: 22;
            borderAlpha = 0;
            break;
        } default: {
            break;
        }
    }
    CAShapeLayer *layer = [CAShapeLayer layer];
    CGPoint position = CGPointMake([FFATLayoutAttributes itemImageWidth] / 2, [FFATLayoutAttributes itemImageWidth] / 2);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:position radius:radius startAngle:0 endAngle:2 * M_PI clockwise:YES];
    layer.path = path.CGPath;
    layer.lineWidth = 1;
    layer.fillColor = [UIColor colorWithWhite:1 alpha:circleAlpha].CGColor;
    layer.strokeColor = [UIColor colorWithWhite:0 alpha:borderAlpha].CGColor;
    layer.bounds = CGRectMake(0, 0, [FFATLayoutAttributes itemImageWidth], [FFATLayoutAttributes itemImageWidth]);
    layer.position = CGPointMake(position.x, position.y);
    layer.contentsScale = [UIScreen mainScreen].scale;
    return layer;
}

@end
