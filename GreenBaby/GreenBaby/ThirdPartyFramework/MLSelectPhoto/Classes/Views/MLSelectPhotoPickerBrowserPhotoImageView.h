//  ZLPhotoPickerBrowserPhotoImageView.h
//  ZLAssetsPickerDemo
//
//  Created by LiXiangCheng on 14-11-14.
//  Copyright (c) 2014年 com.Ideal.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ZLPhotoPickerBrowserPhotoImageViewDelegate;

@interface MLSelectPhotoPickerBrowserPhotoImageView : UIImageView {}

@property (nonatomic, weak) id <ZLPhotoPickerBrowserPhotoImageViewDelegate> tapDelegate;
@property (assign,nonatomic) CGFloat progress;

@end

@protocol ZLPhotoPickerBrowserPhotoImageViewDelegate <NSObject>

@optional

- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch;

@end