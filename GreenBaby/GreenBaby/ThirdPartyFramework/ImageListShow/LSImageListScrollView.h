//
//  LSImageListScrollView.h
//  mmy
//
//  Created by Duno iOS on 14-4-22.
//  Copyright (c) 2014年 Duno iOS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSImageItem.h"
#import "MGGestureImageView.h"

@protocol LSImageListScrollViewDelegate;

@interface LSImageListScrollView : UIView  // Must use initwithframe methods to create object
@property (nonatomic, weak) id<LSImageListScrollViewDelegate> delegate;

@property (strong,nonatomic) UIScrollView *scrollView;
@property (strong,nonatomic) UIImageView *maskIV;

@property (nonatomic, assign) BOOL isLongPress; //Default NO
@property (nonatomic, assign) BOOL isTag;  //Default NO
@property (nonatomic, assign) BOOL isPagingEnabled;  // default YES
@property (nonatomic, assign) BOOL isCurcularEnabled;  // default YES
@property (nonatomic, assign) BOOL isShowPageControl;  // default YES
@property (nonatomic, assign) BOOL isCircleImageView;  // default NO
@property (nonatomic, assign) BOOL isAutoScroll; //Default NO
@property (nonatomic, assign) BOOL signalPicSwipeEffeict;  // Default NO
@property (strong, nonatomic) NSString *defaultImageName;

@property (strong,nonatomic) UIPageControl *pageControl;
- (void)showSlideImageView:(NSArray *)imageItems
             imageViewSize:(CGSize)imageViewSize
          imageViewGapSize:(CGSize)imageViewGapSize;

- (void)addAutoScroll;
- (void)removeAutoScroll;

@end

@protocol LSImageListScrollViewDelegate <NSObject>
@optional
- (void)imageListScrollView:(LSImageListScrollView *)imageListView
         currentScrollIndex:(NSInteger)currentIndex;
- (void)imageListScrollView:(LSImageListScrollView *)imageListView
       currentSelectedIndex:(NSInteger)currentIndex;
- (void)imageListScrollView:(LSImageListScrollView *)imageListView
      currentLongPressIndex:(NSInteger)currentIndex;
@end
