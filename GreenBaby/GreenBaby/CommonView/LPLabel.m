//
//  LPLabel.m
//  EHome
//
//  Created by LiXiangCheng on 15/7/20.
//  Copyright (c) 2015年 MeiLin. All rights reserved.
//

#import "LPLabel.h"

@implementation LPLabel

- (void)drawTextInRect:(CGRect)rect
{
    [super drawTextInRect:rect];
    
    CGSize textSize = [[self text] adjustSizeWithFont:[self font] constrainedToSize:CGSizeMake(MAXFLOAT,MAXFLOAT)];
    
    CGFloat strikeWidth = textSize.width;
    
    CGRect lineRect;
    
    if ([self textAlignment] == NSTextAlignmentRight)
    {
        // 画线居中
        lineRect = CGRectMake(rect.size.width - strikeWidth, rect.size.height/2, strikeWidth, 1);
        
        // 画线居下
        //lineRect = CGRectMake(rect.size.width - strikeWidth, rect.size.height/2 + textSize.height/2, strikeWidth, 1);
    }
    else if ([self textAlignment] == NSTextAlignmentCenter)
    {
        // 画线居中
        lineRect = CGRectMake(rect.size.width/2 - strikeWidth/2, rect.size.height/2, strikeWidth, 1);
        
        // 画线居下
        //lineRect = CGRectMake(rect.size.width/2 - strikeWidth/2, rect.size.height/2 + textSize.height/2, strikeWidth, 1);
    }
    else
    {
        // 画线居中
        lineRect = CGRectMake(0, rect.size.height/2, strikeWidth, 1);
        
        // 画线居下
        //lineRect = CGRectMake(0, rect.size.height/2 + textSize.height/2, strikeWidth, 1);
    }
    
    if (self.strikeThroughEnabled)
    {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, [self strikeThroughColor].CGColor);
        
        CGContextFillRect(context, lineRect);
    }
}

@end
