//
//  CustomPageControl.h
//  CardBump
//
//  Created by 香成 李 on 12-2-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CustomPageControl : UIPageControl

- (id)initWithFrame:(CGRect)frame;

@property (nonatomic, strong) UIImage *imagePageStateNormal;
@property (nonatomic, strong) UIImage *imagePageStateHighlighted;

@end

//调用:
//CustomPageControl *pageControl = [[CustomPageControl alloc] initWithFrame:CGRectMake(0,0, 200, 30)];
//pageControl.backgroundColor = [UIColor clearColor];
//pageControl.numberOfPages = 5;
//pageControl.currentPage = 0;
//[pageControl setImagePageStateNormal:[UIImage imageNamed:@"pageControlStateNormal.png"]];
//[pageControl setImagePageStateHighlighted:[UIImage imageNamed:@"pageControlStateHighlighted.png"]];
//[self.view addSubview:pageControl];
