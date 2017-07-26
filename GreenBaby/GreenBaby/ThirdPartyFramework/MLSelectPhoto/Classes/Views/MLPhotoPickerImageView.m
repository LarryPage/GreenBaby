//  PickerImageView.m
//
//  Created by LiXiangCheng on 14-11-11.
//  Copyright (c) 2014年 com.Ideal.www. All rights reserved.
//

#import "MLPhotoPickerImageView.h"
#import "MLSelectPhotoCommon.h"

@interface MLPhotoPickerImageView ()

@property (nonatomic , weak) UIView *maskView;
@property (nonatomic , weak) UIImageView *tickImageView;
@property (nonatomic , weak) UIImageView *videoView;
@end

@implementation MLPhotoPickerImageView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
        self.userInteractionEnabled=YES;
    }
    return self;
}

- (UIView *)maskView{
    if (!_maskView) {
        UIView *maskView = [[UIView alloc] init];
        maskView.frame = self.bounds;
        maskView.backgroundColor = [UIColor whiteColor];
        maskView.hidden = YES;
        [self addSubview:maskView];
        self.maskView = maskView;
    }
    return _maskView;
}

- (UIImageView *)videoView{
    if (!_videoView) {
        UIImageView *videoView = [[UIImageView alloc] initWithFrame:CGRectMake(10, self.bounds.size.height - 40, 30, 30)];
        videoView.image = [UIImage imageNamed:MLSelectPhotoSrcName(@"video")];
        videoView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:videoView];
        self.videoView = videoView;
    }
    return _videoView;
}

- (UIImageView *)tickImageView{
    if (!_tickImageView) {
        UIImageView *tickImageView = [[UIImageView alloc] init];
        tickImageView.frame = CGRectMake(self.bounds.size.width-3-23, 3, 23, 23);
        tickImageView.image = [UIImage imageNamed:MLSelectPhotoSrcName(@"AssetsPickerCheck")];
        [self addSubview:tickImageView];
        self.tickImageView = tickImageView;
        
    }
    return _tickImageView;
}

//modify by lxc
- (UIButton *)previewBtn{
    if (!_previewBtn) {
        UIButton *previewBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        previewBtn.frame=CGRectMake(0, 30, self.bounds.size.width, self.bounds.size.height-30);
        previewBtn.backgroundColor=[UIColor clearColor];
        [self addSubview:previewBtn];
        self.previewBtn = previewBtn;
    }
    return _previewBtn;
}

- (void)setIsVideoType:(BOOL)isVideoType{
    _isVideoType = isVideoType;
    
    self.videoView.hidden = !(isVideoType);
}

- (void)setMaskViewFlag:(BOOL)maskViewFlag{
    _maskViewFlag = maskViewFlag;
    
    self.animationRightTick = maskViewFlag;
}

- (void)setAnimationRightTick:(BOOL)animationRightTick{
    _animationRightTick = animationRightTick;
    self.tickImageView.image = [UIImage imageNamed:MLSelectPhotoSrcName(animationRightTick?@"AssetsPickerChecked":@"AssetsPickerCheck")];
    
    CAKeyframeAnimation *scaoleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaoleAnimation.duration = 0.25;
    scaoleAnimation.autoreverses = YES;
    scaoleAnimation.values = @[[NSNumber numberWithFloat:1.0],[NSNumber numberWithFloat:1.2],[NSNumber numberWithFloat:1.0]];
    scaoleAnimation.fillMode = kCAFillModeForwards;
    
    if (animationRightTick) {
        if (self.isVideoType) {
            [self.videoView.layer removeAllAnimations];
            [self.videoView.layer addAnimation:scaoleAnimation forKey:@"transform.rotate"];
        }else{
            [self.tickImageView.layer removeAllAnimations];
            [self.tickImageView.layer addAnimation:scaoleAnimation forKey:@"transform.rotate"];
        }
    }
}
@end
