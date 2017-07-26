//  UIView+Extension.h
//
//  Created by LiXiangCheng on 14-11-14.
//  Copyright (c) 2014年 com.Ideal.www. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface UIView (Extension)

@property (nonatomic,assign) CGFloat ml_x;
@property (nonatomic,assign) CGFloat ml_y;
@property (nonatomic,assign) CGFloat ml_centerX;
@property (nonatomic,assign) CGFloat ml_centerY;
@property (nonatomic,assign) CGFloat ml_width;
@property (nonatomic,assign) CGFloat ml_height;
@property (nonatomic,assign) CGSize ml_size;

- (void)showMessageWithText:(NSString *)text;
@end
