//  ZLPhotoPickerBrowserPhotoView.h
//  ZLAssetsPickerDemo
//
//  Created by LiXiangCheng on 14-11-14.
//  Copyright (c) 2014年 com.Ideal.www. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol ZLPhotoPickerBrowserPhotoViewDelegate;

@interface MLSelectPhotoPickerBrowserPhotoView : UIView {}

@property (nonatomic, weak) id <ZLPhotoPickerBrowserPhotoViewDelegate> tapDelegate;

@end

@protocol ZLPhotoPickerBrowserPhotoViewDelegate <NSObject>

@optional

- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch;

@end