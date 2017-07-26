//
//  XHFaceManagerView.m
//  Hunt
//
//  Created by LiXiangCheng on 14/12/22.
//  Copyright (c) 2014年 LiXiangCheng. All rights reserved.
//

#import "XHFaceManagerView.h"

#define FaceSize  44//表情按纽大小（正方形）
// 每行有4个
#define kXHFaceManagerPerRowItemCount (int)floor(CGRectGetWidth(self.bounds) / FaceSize)
#define kXHFaceManagerPerColum 3

@interface XHFaceManagerView () <UIScrollViewDelegate>

/**
 *  这是背景滚动视图
 */
@property (nonatomic, weak) UIScrollView *faceScrollView;

/**
 *  显示页码的视图
 */
@property (nonatomic, weak) UIPageControl *facePageControl;

/**
 *  第三方表情按钮点击的事件
 *
 *  @param sender 第三方按钮对象
 */
- (void)faceItemButtonClicked:(UIButton *)sender;

/**
 *  配置默认控件
 */
- (void)setup;

@end

@implementation XHFaceManagerView

- (void)faceItemButtonClicked:(UIButton *)sender {
    if (sender.tag ==0)
        return;
    
    NSString *imgstr = [NSString stringWithFormat:@"Expression_%@@2x.png",@(sender.tag)];
    NSString *faceName;
//    for (int i = 0; i<[[_faceMap allKeys]count]-1; i++)
//    {
//        if ([[_faceMap objectForKey:[[_faceMap allKeys] objectAtIndex:i]]
//             isEqualToString:imgstr])
//        {
//            faceName = [[_faceMap allKeys]objectAtIndex:i];
//            break;
//        }
//    }
    NSUInteger idx=[[_faceMap allValues] indexOfObject:imgstr];
    if (idx!=NSNotFound) {
        faceName = [[_faceMap allKeys] objectAtIndex:idx];
    }
    
    if ([self.delegate respondsToSelector:@selector(didSelecteFace:)]) {
        [self.delegate didSelecteFace:faceName];
    }
}

- (void)deleteButtonClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(deleteFace)]) {
        [self.delegate deleteFace];
    }
}

- (void)sendButtonClicked:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(didSend)]) {
        [self.delegate didSend];
    }
}

- (void)reloadData {
    if (!_faceMap.count)
        return;
    
    [self.faceScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSUInteger faceCount=_faceMap.count;
    NSUInteger pageCount = 1;//动态计算表情总页数
    CGFloat x = 0;
    CGFloat y = 0;
    bool isBestrid=false;//是否正好布满
    for (NSUInteger i = 0; i<faceCount; i++){
        if(x+FaceSize==(pageCount-1) * CGRectGetWidth(self.bounds)+kXHFaceManagerPerRowItemCount*FaceSize && y+FaceSize==kXHFaceManagerPerColum*FaceSize) {//删除按纽
           UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
            deleteButton.frame = CGRectMake( x, y, FaceSize, FaceSize);
            deleteButton.tag = 0;
            [deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [deleteButton setImage:[UIImage imageNamed:@"deleteFace"] forState:UIControlStateNormal];
            [self.faceScrollView addSubview:deleteButton];
            
            pageCount+=1;
            x=(pageCount-1) * CGRectGetWidth(self.bounds);
            y=0;
        }
        else if (x+FaceSize>(pageCount-1) * CGRectGetWidth(self.bounds)+kXHFaceManagerPerRowItemCount*FaceSize) {
            x=(pageCount-1) * CGRectGetWidth(self.bounds);
            y+=FaceSize;
        }
        
        UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        faceButton.frame = CGRectMake( x, y, FaceSize, FaceSize);
        faceButton.tag = i+1;
        [faceButton addTarget:self action:@selector(faceItemButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [faceButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"Expression_%@",@(i+1)]] forState:UIControlStateNormal];
        [self.faceScrollView addSubview:faceButton];
        
        x+=FaceSize;
    }
    
    //添加最后一页的删除按纽
    x=(pageCount-1) * CGRectGetWidth(self.bounds)+kXHFaceManagerPerRowItemCount*FaceSize-FaceSize;
    y=kXHFaceManagerPerColum*FaceSize-FaceSize;
    
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.frame = CGRectMake( x, y, FaceSize, FaceSize);
    deleteButton.tag = 0;
    [deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [deleteButton setImage:[UIImage imageNamed:@"deleteFace"] forState:UIControlStateNormal];
    [self.faceScrollView addSubview:deleteButton];
    
    self.facePageControl.numberOfPages = pageCount;
    self.facePageControl.currentPage = 0;
    [self.faceScrollView setContentSize:CGSizeMake(pageCount * CGRectGetWidth(self.bounds), CGRectGetHeight(self.faceScrollView.bounds))];
}

#pragma mark - Life cycle

- (void)setup {
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    if (!_faceScrollView) {
        UIScrollView *faceScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - kXHFacePageControlHeight-kXHFaceBottomSectionHeight)];
        faceScrollView.delegate = self;
        faceScrollView.canCancelContentTouches = NO;
        faceScrollView.delaysContentTouches = YES;
        faceScrollView.backgroundColor = self.backgroundColor;
        faceScrollView.showsHorizontalScrollIndicator = NO;
        faceScrollView.showsVerticalScrollIndicator = NO;
        [faceScrollView setScrollsToTop:NO];
        faceScrollView.pagingEnabled = YES;
        [self addSubview:faceScrollView];
        
        self.faceScrollView = faceScrollView;
    }
    
    if (!_facePageControl) {
        UIPageControl *facePageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.faceScrollView.frame), CGRectGetWidth(self.bounds), kXHFacePageControlHeight)];
        facePageControl.currentPageIndicatorTintColor = [UIColor colorWithWhite:0.471 alpha:1.000];
        facePageControl.pageIndicatorTintColor = [UIColor colorWithWhite:0.678 alpha:1.000];
        facePageControl.backgroundColor = self.backgroundColor;
        facePageControl.hidesForSinglePage = YES;
        facePageControl.defersCurrentPageDisplay = YES;
        [facePageControl addTarget:self action:@selector(pageChange:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:facePageControl];
        
        self.facePageControl = facePageControl;
    }
    
    if (!_sendBtn) {
        UIView *bottomIV=[[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.facePageControl.frame), CGRectGetWidth(self.bounds), kXHFaceBottomSectionHeight)];
        bottomIV.backgroundColor=[UIColor darkGrayColor];
        
        UIButton *sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds)-10-60, (kXHFaceBottomSectionHeight-(kXHFaceBottomSectionHeight-6))/2, 60, kXHFaceBottomSectionHeight-6)];
        
        sendBtn.backgroundColor=MKRGBA(0,133,228,255);
        [sendBtn setBackgroundImage:[UIImage createImageWithColor:MKRGBA(0,133,228,255)] forState:UIControlStateNormal];
        [sendBtn setBackgroundImage:[UIImage createImageWithColor:MKRGBA(0,117,199,255)] forState:UIControlStateHighlighted];
        [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sendBtn setTitleColor:MKRGBA(146,146,146,255) forState:UIControlStateDisabled];
        [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [sendBtn setTitle:@"发送" forState:UIControlStateHighlighted];
        [sendBtn addTarget:self action:@selector(sendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        //设置Button为圆角
        sendBtn.layer.masksToBounds=YES; //设置为yes，就可以使用圆角
        sendBtn.layer.cornerRadius = 2.0;//设置它的圆角大小
        sendBtn.layer.borderWidth = 1.0;//视图的边框宽度
        //sendBtn.layer.backgroundColor =MKRGBA(240,240,240,255).CGColor;
        sendBtn.layer.borderColor = MKRGBA(0,133,228,255).CGColor;//视图的边框颜色
        sendBtn.enabled=NO;
        
        [bottomIV addSubview:sendBtn];
        [self addSubview:bottomIV];
        
        self.sendBtn = sendBtn;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)dealloc {
    self.faceMap = nil;
    //self.faceScrollView.delegate = self;
    self.faceScrollView = nil;
    self.facePageControl = nil;
    self.sendBtn=nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview) {
        [self reloadData];
    }
}

#pragma mark - UIPageControl

- (void)pageChange:(id)sender {
    [self.faceScrollView setContentOffset:CGPointMake(self.facePageControl.currentPage*self.faceScrollView.frame.size.width,0) animated:YES];
    [self.facePageControl setCurrentPage:self.facePageControl.currentPage];
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //每页宽度
    CGFloat pageWidth = scrollView.frame.size.width;
    //根据当前的坐标与页宽计算当前页码
    NSInteger currentPage = floor((scrollView.contentOffset.x - pageWidth/2)/pageWidth)+1;
    [self.facePageControl setCurrentPage:currentPage];
}

@end
