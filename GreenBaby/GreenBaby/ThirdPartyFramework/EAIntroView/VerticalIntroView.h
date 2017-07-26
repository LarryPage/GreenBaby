//
//  VerticalIntroView.h
//  MobileResume
//
//  Created by LiXiangCheng on 14-1-14.
//  Copyright (c) 2014年 人人猎头. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VerticalIntroDelegate
@optional
- (void)verticalIntroDidFinish;
@end

@interface VerticalIntroView : UIView <UIScrollViewDelegate>

@property (nonatomic, assign) id<VerticalIntroDelegate> delegate;
@property (nonatomic, retain) UIScrollView *scrollView;

- (id)initWithFrame:(CGRect)frame;

- (void)showInView:(UIView *)view animateDuration:(CGFloat)duration;
- (void)hideWithFadeOutDuration:(CGFloat)duration;
- (void)hideWithFadeOutDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion;

@end
