//
//  LSImageListScrollView.m
//  mmy
//
//  Created by Duno iOS on 14-4-22.
//  Copyright (c) 2014年 Duno iOS. All rights reserved.
//

#import "LSImageListScrollView.h"

static CGFloat kAutoScrollTime = 3.0f;

@interface LSImageListScrollView ()<UIScrollViewDelegate,GestureImageViewDelegate>
@property (strong,nonatomic) NSArray *imageItems;

@property (strong,nonatomic) NSTimer *picAutoScrollTimer;
@end

@implementation LSImageListScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isPagingEnabled = YES;
        self.isCurcularEnabled = YES;
        self.isShowPageControl = YES;
        self.isCircleImageView = NO;
//        [self createSubView];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.isPagingEnabled = YES;
    self.isCurcularEnabled = YES;
    self.isShowPageControl = YES;
    self.isCircleImageView = NO;
    self.signalPicSwipeEffeict = NO;
//    [self createSubView];
}

- (void)createSubView
{
    if (nil == self.scrollView) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(CGPointZero.x, CGPointZero.y, self.frame.size.width, self.frame.size.height)];
        self.scrollView.backgroundColor = [UIColor clearColor];
        self.scrollView.pagingEnabled = YES;
        self.scrollView.bounces = YES;
        self.scrollView.userInteractionEnabled = YES;
        self.scrollView.alwaysBounceVertical = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.contentSize = self.scrollView.frame.size;
        self.scrollView.contentOffset = CGPointZero;
        [self addSubview:self.scrollView];
        
        self.maskIV=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mask_page"]];
        self.maskIV.frame=CGRectMake(0,self.frame.size.height - 50,self.frame.size.width,50);
        [self addSubview:self.maskIV];
        
        self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake((self.scrollView.frame.size.width-70)/2,self.frame.size.height - 20,70,18)]; // 初始化
        [self.pageControl setCurrentPageIndicatorTintColor:MKRGBA(255,255,255,255)];
        [self.pageControl setPageIndicatorTintColor:MKRGBA(255,255,255,255*0.5)];
        self.pageControl.currentPage = 0;
        [self addSubview:self.pageControl];
    }
}

- (void)addAutoScroll
{
    if (_isCurcularEnabled && nil == _picAutoScrollTimer && _imageItems.count > 1) {
        _picAutoScrollTimer = [NSTimer scheduledTimerWithTimeInterval:kAutoScrollTime
                                                               target:self
                                                             selector:@selector(autoScroll)
                                                             userInfo:nil
                                                              repeats:YES];
    }
}

- (void)removeAutoScroll
{
    if (nil != _picAutoScrollTimer) {
        [_picAutoScrollTimer invalidate];
        _picAutoScrollTimer = nil;
    }
}

- (void)createSubImageViewIndex:(int)index frame:(CGRect)frame
{
    LSImageItem *imageItem = [self.imageItems objectAtIndex:index];
    MGGestureImageView *imageView = [[MGGestureImageView alloc] initWithFrame:frame];
    imageView.delegate = self;
    imageView.tag = index;
    [imageView addTapGesture:_isTag longPressGesture:_isLongPress];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    if (self.isCircleImageView) {
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = imageView.frame.size.width / 2;
    }
    [self.scrollView addSubview:imageView];
    [imageView loadImage:imageItem.imageURL placeHolderImageNamed:imageItem.imageNamed];
}

- (void)showSlideImageView:(NSArray *)imageItems
             imageViewSize:(CGSize)imageViewSize
          imageViewGapSize:(CGSize)imageViewGapSize
{
    if (nil == self.scrollView) {
        [self createSubView];
    } else {
        for (UIView *subView in self.scrollView.subviews) {
            [subView removeFromSuperview];
        }
    }
    self.pageControl.hidden = !self.isShowPageControl;
    self.scrollView.pagingEnabled = self.isPagingEnabled;
    self.scrollView.delegate = self;
    if (nil == imageItems || imageItems.count < 1) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.scrollView.frame];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = [UIImage imageNamed:self.defaultImageName];
        [self.scrollView addSubview:imageView];
        return;
    }
    
    self.imageItems = imageItems;
    self.pageControl.numberOfPages = [imageItems count];
    if (imageItems.count == 1) {
        self.scrollView.contentOffset = CGPointZero;
        if (self.signalPicSwipeEffeict) {
            self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width+1, self.scrollView.frame.size.height);
        } else {
            self.scrollView.contentSize = self.scrollView.frame.size;
        }
        [self createSubImageViewIndex:0
                                frame:CGRectMake(imageViewGapSize.width, imageViewGapSize.height, imageViewSize.width, imageViewSize.height)];
        return;
    }
    
    //超过2张
    if (self.isCurcularEnabled) {
        self.scrollView.contentSize = CGSizeMake((self.frame.size.width + imageViewGapSize.width) * (imageItems.count + 2), imageViewSize.height);
        self.scrollView.contentOffset = CGPointMake((self.frame.size.width + imageViewGapSize.width), CGPointZero.y);
        // 取数组最后一张图片 放在第0页
        [self createSubImageViewIndex:(int)(imageItems.count-1)
                                frame:CGRectMake(imageViewGapSize.width, imageViewGapSize.height, imageViewSize.width, imageViewSize.height)];
        // 取数组第一张图片 放在最后1页
        [self createSubImageViewIndex:0
                                frame:CGRectMake((self.frame.size.width + imageViewGapSize.width) * (imageItems.count + 1), imageViewGapSize.height, imageViewSize.width, imageViewSize.height)];
        
        // 创建中间图片图片 imageview
        for (int i = 0; i<imageItems.count; i++) {
            [self createSubImageViewIndex:i
                                    frame:CGRectMake((self.frame.size.width + imageViewGapSize.width) * (i + 1),imageViewGapSize.height, imageViewSize.width, imageViewSize.height)];
        }
    } else {
        self.scrollView.contentSize = CGSizeMake((self.frame.size.width + imageViewGapSize.width) * imageItems.count, imageViewSize.height);
        self.scrollView.contentOffset = CGPointZero;
        for (int i = 0; i<imageItems.count; i++) {
            [self createSubImageViewIndex:i
                                    frame:CGRectMake((self.frame.size.width + imageViewGapSize.width) * i,imageViewGapSize.height, imageViewSize.width, imageViewSize.height)];
        }
    }
    if (_isAutoScroll) {
        [self addAutoScroll];
    }
}

#pragma mark - GestureImageViewDelegate methods

- (void)tapImageView:(MGGestureImageView *)imageView
{
    NSInteger currentIndex = imageView.tag;
    if (currentIndex > -1 && currentIndex < self.imageItems.count
        && [self.delegate respondsToSelector:@selector(imageListScrollView:currentSelectedIndex:)]) {
        [self.delegate imageListScrollView:self currentSelectedIndex:currentIndex];
    }
}

- (void)longPressImageView:(MGGestureImageView *)imageView gesture:(UIGestureRecognizer *)gesture
{
    NSInteger currentIndex = imageView.tag;
    if (currentIndex > -1 && currentIndex < self.imageItems.count
        && [self.delegate respondsToSelector:@selector(imageListScrollView:currentLongPressIndex:)]) {
        [self.delegate imageListScrollView:self currentLongPressIndex:currentIndex];
    }
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pagewidth = self.scrollView.frame.size.width;
    
    int page = 0;
    if (self.isCurcularEnabled) {
        page = floor((self.scrollView.contentOffset.x - pagewidth/self.imageItems.count+2)/pagewidth)+1;
        page --;  // 默认从第二页开始
    } else {
        page = floor(self.scrollView.contentOffset.x / pagewidth);
    }
    
    self.pageControl.currentPage = page;
    
    if (self.pageControl.currentPage > -1 && self.pageControl.currentPage < self.imageItems.count
        && [self.delegate respondsToSelector:@selector(imageListScrollView:currentScrollIndex:)]) {
        [self.delegate imageListScrollView:self
                        currentScrollIndex:(int)self.pageControl.currentPage];
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.isCurcularEnabled) {
        CGFloat pagewidth = self.scrollView.frame.size.width;
        int currentPage = floor((self.scrollView.contentOffset.x - pagewidth/self.imageItems.count+2) / pagewidth) + 1;
        if (currentPage==0) {
            [self.scrollView setContentOffset:CGPointMake(self.frame.size.width * self.imageItems.count, CGPointZero.y)];
        } else if (currentPage==(self.imageItems.count+1)) {
            [self.scrollView setContentOffset:CGPointMake(self.frame.size.width, CGPointZero.y)]; // 最后+1,循环第1页
        }
    }
}

- (void)autoScroll
{
    BOOL isLastest = (self.pageControl.currentPage == (self.pageControl.numberOfPages - 1));
    NSInteger newPage = isLastest ? 0 : (++ self.pageControl.currentPage);
    self.pageControl.currentPage = newPage;
    CGFloat offsetX = self.scrollView.frame.size.width * (newPage + 1);
    
    CATransition *myTransition = [CATransition animation];
    myTransition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    myTransition.duration = 0.4f;
    myTransition.type = kCATransitionReveal;
    myTransition.subtype = kCATransitionFromRight;
    [self.scrollView.layer removeAllAnimations];
    [self.scrollView.layer addAnimation:myTransition forKey:kCATransition];
    [self.scrollView setContentOffset:CGPointMake(offsetX, CGPointZero.y) animated:NO];
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
