//
//  VerticalIntroView.m
//  MobileResume
//
//  Created by LiXiangCheng on 14-1-14.
//  Copyright (c) 2014年 人人猎头. All rights reserved.
//

#import "VerticalIntroView.h"

@implementation VerticalIntroView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self buildScrollViewWithFrame:frame];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)buildScrollViewWithFrame:(CGRect)frame {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    
    self.scrollView.bounces = NO;
    self.scrollView.bouncesZoom = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.delegate = self;
    
    NSInteger cy = 0;
    int totalGuid=3;
    {
        for (int i = 0; i < totalGuid; i++) {
            
            UIImageView *guideIV = [[UIImageView alloc] init];
            guideIV.image = [UIImage imageNamed:[NSString stringWithFormat:IS_IPHONE_5?@"guide%d-568h@2x.jpg":@"guide%d.jpg",i+1]];
            guideIV.contentMode = UIViewContentModeScaleAspectFit;
            //guideIV.frame = CGRectMake(74,156,172,260);
            
            CGRect frame = guideIV.frame;
            frame.size.width = self.scrollView.frame.size.width;
            frame.size.height = self.scrollView.frame.size.height;
            frame.origin.x = 0;
            frame.origin.y = cy;
            guideIV.frame = frame;
            
            [self.scrollView addSubview:guideIV];
            
            if (i==totalGuid-1) {
                //create startBtn btn
                NSInteger btnWidth=UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone?127:253;
                NSInteger btnHeight=UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone?34:65;
                NSInteger btnx=UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone?29:68;
                NSInteger btny=UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone?(IS_IPHONE_5?287:199):475;
                
                UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                startBtn.tag=100;
                startBtn.frame=CGRectMake(btnx,cy+btny,btnWidth,btnHeight);
                [startBtn setTitle:@"进入应用GO" forState:UIControlStateNormal];
                [startBtn setBackgroundImage:[UIImage createImageWithColor:MKRGBA(63,114,218,255) withSize:CGSizeMake(btnWidth, btnHeight)] forState:UIControlStateNormal];
                startBtn.layer.cornerRadius = 4.0;
                startBtn.layer.masksToBounds = YES;
                startBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
                [startBtn addTarget:self action:@selector(enter) forControlEvents:UIControlEventTouchUpInside];
                
                [self.scrollView addSubview:startBtn];
            }
            
            cy += self.scrollView.frame.size.height;
        }
    }
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height * totalGuid)];
    [self addSubview:self.scrollView];
}

- (void)showInView:(UIView *)view animateDuration:(CGFloat)duration {
    self.alpha = 0;
    [self.scrollView setContentOffset:CGPointZero];
    [view addSubview:self];
    
    [UIView animateWithDuration:duration animations:^{
        self.alpha = 1;
    }];
}

- (void)enter {
    if ([(id)self.delegate respondsToSelector:@selector(introDidFinish)]) {
        [self.delegate verticalIntroDidFinish];
    }
    
    [self hideWithFadeOutDuration:0.3];
}

- (void)hideWithFadeOutDuration:(CGFloat)duration {
    [UIView animateWithDuration:duration animations:^{
        self.alpha = 0;
    } completion:nil];
}

- (void)hideWithFadeOutDuration:(CGFloat)duration completion:(void (^)(BOOL finished))completion {
    [UIView animateWithDuration:duration animations:^{
        self.alpha = 0;
    } completion:completion];
}

#pragma mark UIScrollViewDelegate
//滚动中
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Switch the indicator when more than 50% of the previous/next page is visible
//    CGFloat pageHeight = self.scrollView.frame.size.height;
//    int curentScrollPage = floor((self.scrollView.contentOffset.y - pageHeight / 2) / pageHeight) + 1;
//    CLog(@"curentScrollPage:%d",curentScrollPage);
}

//滚动开始
// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}

//滚动结束
- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender{
    CGFloat pageHeight = self.scrollView.frame.size.height;
    int curentScrollPage = floor((self.scrollView.contentOffset.y - pageHeight / 2) / pageHeight) + 1;
    
    UIButton *startBtn=(UIButton *)[self.scrollView viewWithTag:100];
    CGRect frame=startBtn.frame;
    NSInteger btnWidth=frame.size.width;
    NSInteger btnHeight=frame.size.height;
    NSInteger btnx=frame.origin.x;
    NSInteger btny=frame.origin.y;
    if (curentScrollPage==2) {
        frame.origin.y=btny-btnHeight;
        startBtn.frame=frame;
        startBtn.alpha=0.0;
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             startBtn.frame=CGRectMake(btnx,btny,btnWidth,btnHeight);
                             startBtn.alpha=1.0;
                         }completion:^(BOOL finished) {
                         }];
    }
    else{
        startBtn.alpha=0.0;
    }
}

@end
