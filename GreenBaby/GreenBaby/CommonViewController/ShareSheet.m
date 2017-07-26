//
//  ShareSheet.m
//  EHome
//
//  Created by 香成 李 on 12-1-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ShareSheet.h"

@interface ShareSheet ()
@property (nonatomic, strong) ShareCompletion completion;
@property (nonatomic, strong) NSArray *imageNames;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) IBOutlet UIView *lineView;
@property (nonatomic, strong) IBOutlet UIButton *cancelBtn;

- (IBAction)optionBtnClicked:(UIButton *)sender;
@end

@implementation ShareSheet

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    _tipLbl.font=CFont(14);
    _cancelBtn.titleLabel.font=CFont(14);
    
    CGRect frame=self.lineView.frame;
    frame.size.height=1/[[UIScreen mainScreen] scale];
    self.lineView.frame=frame;
}

+ (ShareSheet *)initImageNames:(NSArray *)imageNames titles:(NSArray *)titles completion:(ShareCompletion)completion{
    ShareSheet *shareSheet = [[[NSBundle mainBundle] loadNibNamed:@"ShareSheet" owner:nil options:nil] objectAtIndex:0];
    shareSheet.completion = completion;
    shareSheet.imageNames=imageNames;
    shareSheet.titles=titles;
    return shareSheet;
}

- (void)show
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *bgView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        bgView.backgroundColor = [UIColor clearColor];
        //[[AppDelegate sharedAppDelegate].window addSubview:bgView];
        [[AppDelegate sharedAppDelegate].window insertSubview:bgView aboveSubview:[AppDelegate sharedAppDelegate].window.rootViewController.view];
        
        UIView *translucentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        translucentView.backgroundColor = [UIColor blackColor];
        translucentView.alpha=0.5;
        [bgView addSubview:translucentView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewPressed:)];
        [translucentView addGestureRecognizer:tap];
        
        //每个分享间距计算,行间距30
        __block int x=0;
        __block int y=60;
        CGFloat width=50;
        CGFloat height=width;
        NSInteger count = MIN(_imageNames.count, _titles.count);
        //NSInteger rows=count;//一行所有分享,
        NSInteger rows = 5;//一行5个分享
        CGFloat hSpace=([[UIScreen mainScreen] bounds].size.width-width*rows)/(rows+1);
        CGFloat vSpace=30;
        x=hSpace;
        
        self.frame = CGRectMake(0,
                                CGRectGetHeight(bgView.frame),
                                CGRectGetWidth(bgView.frame),
                                CGRectGetHeight(self.frame)+(count<=rows?0:(vSpace+height)));
        
        [self.imageNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *imageName=(NSString *)obj;
            
            UIButton *iconBtn=[UIButton buttonWithType:UIButtonTypeCustom];
            iconBtn.frame=CGRectMake(x+(width+hSpace)*(idx % rows), y+(height+vSpace)*(idx / rows), width, height);
            iconBtn.tag=idx+1;
            [iconBtn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
            iconBtn.imageView.contentMode=UIViewContentModeScaleAspectFill;
            iconBtn.backgroundColor=[UIColor clearColor];
            [iconBtn addTarget:self action:@selector(optionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:iconBtn];
            
            UIButton *titleBtn=[UIButton buttonWithType:UIButtonTypeCustom];
            titleBtn.frame=CGRectMake(iconBtn.frame.origin.x-hSpace/2, iconBtn.frame.origin.y+iconBtn.frame.size.height+10, iconBtn.frame.size.width+hSpace, 20);
            titleBtn.tag=idx+1;
            titleBtn.titleLabel.font=CFont(14);
            [titleBtn setTitle:self.titles[idx] forState:UIControlStateNormal];
            [titleBtn setTitleColor:MKRGBA(66,66,66,255) forState:UIControlStateNormal];
            titleBtn.backgroundColor=[UIColor clearColor];
            [titleBtn addTarget:self action:@selector(optionBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:titleBtn];
        }];
        [bgView addSubview:self];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = CGRectMake(0,
                                    CGRectGetHeight(bgView.frame) - CGRectGetHeight(self.frame),
                                    CGRectGetWidth(bgView.frame),
                                    CGRectGetHeight(self.frame));
        }];
    });
}

- (IBAction)optionBtnClicked:(UIButton *)sender
{
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0,
                                CGRectGetHeight(self.superview.frame),
                                CGRectGetWidth(self.superview.frame),
                                CGRectGetHeight(self.frame));
    } completion:^(BOOL finished) {
        [self.superview removeFromSuperview];
    }];
    
    NSInteger index=sender.tag;
    if (_completion && index>=0) {
        WEAKSELF
        dispatch_async(dispatch_get_main_queue(), ^{
            _completion(sender.tag,weakSelf);
        });
    }
    
    if (sender.tag == 0) {
        [[BaiduMobStat defaultStat] logEvent:@"Share_wechat_1.6" eventLabel:@"分享到微信朋友"];
    } else if (sender.tag == 1) {
        [[BaiduMobStat defaultStat] logEvent:@"Share_friend_1.6" eventLabel:@"分享到朋友圈"];
    } else if (sender.tag == 2) {
    }
}

-(void)viewPressed:(id)sender{
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0,
                                CGRectGetHeight(self.superview.frame),
                                CGRectGetWidth(self.superview.frame),
                                CGRectGetHeight(self.frame));
    } completion:^(BOOL finished) {
        [self.superview removeFromSuperview];
    }];
}

@end
