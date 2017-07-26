//
//  ProgressStatusView.m
//  SuperResume
//
//  Created by Li XiangCheng on 13-10-29.
//  Copyright (c) 2013年 Li XiangCheng. All rights reserved.
//

#import "ProgressStatusView.h"
#import "HZActivityIndicatorView.h"

@interface ProgressStatusView ()
@property (nonatomic, strong) UIImageView *successImageView;
@property (nonatomic, strong) UIImageView *failImageView;
@property (nonatomic, strong) HZActivityIndicatorView *activityIndicatorView;
@end

@implementation ProgressStatusView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.successImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.successImageView.image = [UIImage imageNamed:@"indicator_finish.png"];
    self.successImageView.hidden = YES;
    [self addSubview:self.successImageView];
    
    self.failImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.failImageView.image = [UIImage imageNamed:@"indicator_fail.png"];
    self.failImageView.hidden = YES;
    [self addSubview:self.failImageView];
    
    self.activityIndicatorView = [[HZActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activityIndicatorView.frame = self.bounds;
    self.activityIndicatorView.hidesWhenStopped = YES;
    self.activityIndicatorView.hidden = YES;
    [self addSubview:self.activityIndicatorView];
}

- (void)setStatus:(ProgressStatus)status {
    switch (status) {
        case ProgressStatusSuccess:
            self.successImageView.hidden = NO;
            self.failImageView.hidden = YES;
            [self.activityIndicatorView stopAnimating];
            break;
        case ProgressStatusFail:
            self.successImageView.hidden = YES;
            self.failImageView.hidden = NO;
            [self.activityIndicatorView stopAnimating];
            break;
        case ProgressStatusLoading:
            self.successImageView.hidden = YES;
            self.failImageView.hidden = YES;
            [self.activityIndicatorView startAnimating];
            break;
            
        default:
            break;
    }
}

- (void)reset {
    self.successImageView.hidden = YES;
    self.failImageView.hidden = YES;
    self.activityIndicatorView.hidden = YES;
}

@end
