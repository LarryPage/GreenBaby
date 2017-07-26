//
//  FaceBoard.h
//
//  Created by blue on 12-9-26.
//  Copyright (c) 2012年 blue. All rights reserved.
//  Email - 360511404@qq.com
//  http://github.com/bluemood

#import <UIKit/UIKit.h>
#import "GrayPageControl.h"

@protocol FaceBoardDelegate <NSObject>
@optional
- (void)textViewDidChange:(UITextView *)textView;
@end

@interface FaceBoard : UIView
@property (nonatomic, weak) id<FaceBoardDelegate> delegate;
@property (nonatomic, strong) UITextField *inputTextField;
@property (nonatomic, strong) UITextView *inputTextView;
@end
