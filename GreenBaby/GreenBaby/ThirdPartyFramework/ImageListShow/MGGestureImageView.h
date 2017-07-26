//
//  MGGestureImageView.h
//  mango
//
//  Created by Duno iOS on 14-7-14.
//  Copyright (c) 2014年 cathaya iOS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    ShowBigImageType_Tap = 1,
    ShowBigImageType_LongPress = 2
}ShowBigImageType;

@protocol GestureImageViewDelegate;

@interface MGGestureImageView : UIImageView
@property (nonatomic, weak) id<GestureImageViewDelegate> delegate;

@property (nonatomic, strong) UIButton *playBtn;  //Default Hidden,Just for media including audio,video
@property (nonatomic, strong) UIButton *cancelBtn;  //Default Hidden
@property (nonatomic, strong) UIImageView *iconImageView;  //Default Hidden
@property (nonatomic, strong) UILabel *descriptionLabel; //Default Hidden
@property (nonatomic, strong) UIActivityIndicatorView *activity;

@property (nonatomic, assign) ShowBigImageType type; 
- (void)addTapGesture:(BOOL)needTap longPressGesture:(BOOL)needLongPress;
- (void)loadImage:(NSString *)url placeHolderImageNamed:(NSString *)imageNamed;

- (void)loadImage:(NSString *)url placeHolderImage:(UIImage *)image;
@end

@protocol GestureImageViewDelegate <NSObject>

@optional
- (void)tapImageView:(MGGestureImageView *)imageView;
- (void)longPressImageView:(MGGestureImageView *)imageView gesture:(UIGestureRecognizer *)gesture;

- (void)imageViewCancelBtnClicked:(MGGestureImageView *)imageView;

- (void)gestureImageView:(MGGestureImageView *)imageView playBtnClicked:(BOOL)isPlay;

@end
