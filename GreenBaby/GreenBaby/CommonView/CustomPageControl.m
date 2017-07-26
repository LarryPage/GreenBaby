//
//  CustomPageControl.m
//  CardBump
//
//  Created by 香成 李 on 12-2-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CustomPageControl.h"

@interface CustomPageControl()
- (void)updateDots;
@end

@implementation CustomPageControl

#pragma mark init

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    return self;
}

// 设置正常状态点按钮的图片
- (void)setImagePageStateNormal:(UIImage *)image {
    _imagePageStateNormal=nil;
    _imagePageStateNormal = image;
    [self updateDots];
}

// 设置高亮状态点按钮图片
- (void)setImagePageStateHighlighted:(UIImage *)image {
    _imagePageStateHighlighted=nil;
    _imagePageStateHighlighted = image;
    [self updateDots];
}

//重写 setCurrentPage方法
- (void)setCurrentPage:(NSInteger)currentPage{
    [super setCurrentPage:currentPage];
    [self updateDots];
}

// 更新显示所有的点按钮
- (void)updateDots {
    if (_imagePageStateNormal || _imagePageStateHighlighted)
    {
        NSArray *subview = self.subviews;  // 获取所有子视图
        for (NSInteger i = 0; i < [subview count]; i++)
        {
            UIImageView *dot = [subview objectAtIndex:i];
            if (i == self.currentPage) {
                
                if ( [dot isKindOfClass:UIImageView.class] ) {
                    
                    ((UIImageView *) dot).image = _imagePageStateHighlighted;
                }
                else {
                    
                    dot.backgroundColor = [UIColor colorWithPatternImage:_imagePageStateHighlighted];
                }
            }
            else {
                
                if ( [dot isKindOfClass:UIImageView.class] ) {
                    
                    ((UIImageView *) dot).image = _imagePageStateNormal;
                }
                else {
                    
                    dot.backgroundColor = [UIColor colorWithPatternImage:_imagePageStateNormal];
                }
            }
        }
    }
}

@end
