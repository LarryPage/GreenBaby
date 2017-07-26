//
//  UIImage+MLTint.h
//  MLSelectPhoto
//
//  Created by LiXiangCheng on 15/4/23.
//  Copyright (c) 2015年 com.Ideal.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MLTint)
- (UIImage *) imageWithTintColor:(UIColor *)tintColor;
- (UIImage *) imageWithGradientTintColor:(UIColor *)tintColor;
@end
