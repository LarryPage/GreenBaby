//
//  MGGestureImageView.m
//  mango
//
//  Created by Duno iOS on 14-7-14.
//  Copyright (c) 2014年 cathaya iOS. All rights reserved.
//

#import "MGGestureImageView.h"
#include "UIImageView+WebCache.h"

//static CGFloat KImageViewIconSize = 16.0f;

//static CGFloat KImageViewIconSize_DeleteBtn = 24.0f;
//static CGFloat KImageViewIconSize_PlayBtn = 30.0f;

@interface MGGestureImageView()
@property (nonatomic, assign) CGRect currentFrame;
@property (nonatomic, strong) UITapGestureRecognizer  *tapGuesture;
@property (nonatomic, strong) UILongPressGestureRecognizer  *longGuesture;

- (void)tapGuesture:(UIGestureRecognizer *)sender;
- (void)longPressGuesture:(UIGestureRecognizer *)sender;

- (void)cancelBtnClicked:(UIButton *)cancelBtn;
- (void)playBtnClicked:(UIButton *)playBtn;

- (void)showBigImage;
- (void)hideImage:(UITapGestureRecognizer*)tap;
@end

@implementation MGGestureImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (nil == _iconImageView) {
            // Initialization code
            /*
            CGRect iconFrame = CGRectMake(frame.size.width-KImageViewIconSize, CGPointZero.y, KImageViewIconSize, KImageViewIconSize);
            _iconImageView = [[UIImageView alloc] initWithFrame:iconFrame];
            _iconImageView.hidden = YES;
            [self addSubview:_iconImageView];
            
            CGRect cancelBtnFrame = CGRectMake(frame.size.width-20, CGPointZero.y-3, KImageViewIconSize_DeleteBtn, KImageViewIconSize_DeleteBtn);
            _cancelBtn = [[UIButton alloc] initWithFrame:cancelBtnFrame];
            [_cancelBtn setImage:[UIImage imageNamed:@"Common_Delete.png"] forState:UIControlStateNormal];
            [_cancelBtn addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            _cancelBtn.hidden = YES;
            [self addSubview:_cancelBtn];
            
            CGRect playBtnFrame = CGRectMake((frame.size.width-KImageViewIconSize_PlayBtn)/2, (frame.size.height-KImageViewIconSize_PlayBtn)/2, KImageViewIconSize_PlayBtn, KImageViewIconSize_PlayBtn);
            _playBtn = [[UIButton alloc] initWithFrame:playBtnFrame];
            [_playBtn setImage:[UIImage imageNamed:@"Common_Media_Play.png"] forState:UIControlStateNormal];
            [_playBtn setImage:[UIImage imageNamed:@"Common_Media_Pause.png"] forState:UIControlStateSelected];
            [_playBtn addTarget:self action:@selector(playBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            _playBtn.hidden = YES;
            [self addSubview:_playBtn];
            
            CGRect labelFrame = CGRectMake(CGPointZero.x, frame.size.height - 20, frame.size.width, 20);
            _descriptionLabel = [[UILabel alloc] initWithFrame:labelFrame];
            _descriptionLabel.backgroundColor = [UIColor clearColor];
            _descriptionLabel.font = [UIFont systemFontOfSize:13];
            _descriptionLabel.adjustsFontSizeToFitWidth = YES;
            _descriptionLabel.hidden = YES;
            [self addSubview:_descriptionLabel];
            */
            _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            _activity.hidesWhenStopped = YES;
            _activity.frame = CGRectMake((self.frame.size.width-_activity.frame.size.width)/2, (self.frame.size.height-_activity.frame.size.height)/2, _activity.frame.size.width, _activity.frame.size.height);
            [self addSubview:_activity];
        }
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    if (nil == _iconImageView) {
        /*
        // Initialization code
        CGRect iconFrame = CGRectMake(self.frame.size.width-KImageViewIconSize, CGPointZero.y, KImageViewIconSize, KImageViewIconSize);
        _iconImageView = [[UIImageView alloc] initWithFrame:iconFrame];
        _iconImageView.hidden = YES;
        [self addSubview:_iconImageView];
        
        CGRect cancelBtnFrame = CGRectMake(self.frame.size.width-20, CGPointZero.y-3, KImageViewIconSize_DeleteBtn, KImageViewIconSize_DeleteBtn);
        _cancelBtn = [[UIButton alloc] initWithFrame:cancelBtnFrame];
        [_cancelBtn setImage:[UIImage imageNamed:@"Common_Delete.png"] forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _cancelBtn.hidden = YES;
        [self addSubview:_cancelBtn];
        
        CGRect playBtnFrame = CGRectMake((self.frame.size.width-KImageViewIconSize_PlayBtn)/2, (self.frame.size.height-KImageViewIconSize_PlayBtn)/2, KImageViewIconSize_PlayBtn, KImageViewIconSize_PlayBtn);
        _playBtn = [[UIButton alloc] initWithFrame:playBtnFrame];
        [_playBtn setImage:[UIImage imageNamed:@"Common_Media_Play.png"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"Common_Media_Pause.png"] forState:UIControlStateSelected];
        [_playBtn addTarget:self action:@selector(playBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _playBtn.hidden = YES;
        [self addSubview:_playBtn];
        
        CGRect labelFrame = CGRectMake(CGPointZero.x, self.frame.size.height - 20, self.frame.size.width, 20);
        _descriptionLabel = [[UILabel alloc] initWithFrame:labelFrame];
        _descriptionLabel.backgroundColor = [UIColor clearColor];
        _descriptionLabel.font = [UIFont systemFontOfSize:13];
        _descriptionLabel.adjustsFontSizeToFitWidth = YES;
        _descriptionLabel.hidden = YES;
        [self addSubview:_descriptionLabel];
        */
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activity.hidesWhenStopped = YES;
        _activity.frame = CGRectMake((self.frame.size.width-_activity.frame.size.width)/2, (self.frame.size.height-_activity.frame.size.height)/2, _activity.frame.size.width, _activity.frame.size.height);
        [self addSubview:_activity];
    }

}

- (void)addTapGesture:(BOOL)needTap longPressGesture:(BOOL)needLongPress
{
    self.userInteractionEnabled = YES;
    if (needTap && nil == _tapGuesture) {
        _tapGuesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGuesture:)];
        [self addGestureRecognizer:_tapGuesture];
    }
    if (needLongPress && nil == _longGuesture) {
        _longGuesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGuesture:)];
        //_longGuesture.minimumPressDuration = 1.0f;
        [self addGestureRecognizer:_longGuesture];
    }
}

- (void)loadImage:(NSString *)url placeHolderImageNamed:(NSString *)imageNamed
{
    [_activity startAnimating];
    self.backgroundColor = MKRGBA(226,226,226,255);
    self.contentMode = UIViewContentModeScaleAspectFit;
    [self sd_setImageWithURL:[NSURL URLWithString:url]  placeholderImage:[UIImage imageNamed:imageNamed]  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
        [_activity stopAnimating];
        if (!error) {
            self.contentMode = UIViewContentModeScaleAspectFill;
            self.backgroundColor = [UIColor clearColor];
            self.image = image;
        }
    }];
}

- (void)loadImage:(NSString *)url placeHolderImage:(UIImage *)image
{
    [_activity startAnimating];
    self.contentMode = UIViewContentModeScaleAspectFill;
    [self sd_setImageWithURL:[NSURL URLWithString:url]  placeholderImage:image  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
        [_activity stopAnimating];
        if (!error) {
            self.image = image;
        }
    }];
}

- (void)tapGuesture:(UIGestureRecognizer *)sender
{
    if (self.activity.isAnimating) {  //图片没有加载完成
        return;
    }
    if (nil == self.image || (self.iconImageView.image != nil && self.iconImageView.hidden == YES)) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(tapImageView:)]) {
        [self.delegate tapImageView:self];
    }
    if (_type == ShowBigImageType_Tap) {
        [self showBigImage];
    }
}

- (void)longPressGuesture:(UIGestureRecognizer *)sender
{
    if (self.activity.isAnimating) {  //图片没有加载完成
        return;
    }
    if (nil == self.image || (self.iconImageView.image != nil && self.iconImageView.hidden == YES)) {
        return;
    }
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (_type == ShowBigImageType_LongPress) {
            [self showBigImage];
        }
        if ([self.delegate respondsToSelector:@selector(longPressImageView:gesture:)]) {
            [self.delegate longPressImageView:self gesture:sender];
        }
    }
}

- (void)cancelBtnClicked:(UIButton *)cancelBtn
{
    if ([_delegate respondsToSelector:@selector(imageViewCancelBtnClicked:)]) {
        [_delegate imageViewCancelBtnClicked:self];
    }
}

- (void)playBtnClicked:(UIButton *)playBtn
{
    if ([_delegate respondsToSelector:@selector(gestureImageView:playBtnClicked:)]) {
        [_delegate gestureImageView:self playBtnClicked:!playBtn.selected];
    }
    playBtn.selected = !playBtn.selected;
}

- (void)showBigImage
{
    if (_type == ShowBigImageType_Tap) {
        [self removeGestureRecognizer:_tapGuesture];
    } else if (_type == ShowBigImageType_LongPress) {
        [self removeGestureRecognizer:_longGuesture];
    }
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    UIView *backgroundView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    _currentFrame = [self convertRect:self.bounds toView:window];
    backgroundView.backgroundColor=[UIColor blackColor];
    backgroundView.alpha = 0;
    UIImageView *imageView=[[UIImageView alloc]initWithFrame:_currentFrame];
    imageView.image=self.image;
    imageView.tag = 1;
    [backgroundView addSubview:imageView];
    [window addSubview:backgroundView];
    
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer:tap];
    
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame=CGRectMake(0,([UIScreen mainScreen].bounds.size.height-self.image.size.height*[UIScreen mainScreen].bounds.size.width/self.image.size.width)/2, [UIScreen mainScreen].bounds.size.width, self.image.size.height*[UIScreen mainScreen].bounds.size.width/self.image.size.width);
        backgroundView.alpha=1;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)hideImage:(UITapGestureRecognizer*)tap
{
    UIView *backgroundView=tap.view;
    UIImageView *imageView=(UIImageView*)[tap.view viewWithTag:1];
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame = _currentFrame;
        backgroundView.alpha=0;
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
        if (_type == ShowBigImageType_Tap) {
            [self addGestureRecognizer:_tapGuesture];
        } else if (_type == ShowBigImageType_LongPress) {
            [self addGestureRecognizer:_longGuesture];
        }
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
