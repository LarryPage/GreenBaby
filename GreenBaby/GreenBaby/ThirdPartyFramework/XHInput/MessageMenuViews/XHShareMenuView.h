//
//  XHShareMenuView.h
//  MessageDisplayExample
//
//  Created by LiXiangCheng on 14-5-1.
//  Copyright (c) 2014年 LiXiangCheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XHShareMenuItem.h"

#define kXHShareMenuPageControlHeight 30
// 每行有4个
#define kXHShareMenuPerRowItemCount (IS_IPAD ? 10 : 4)
#define kXHShareMenuPerColum 2

@protocol XHShareMenuViewDelegate <NSObject>

@optional
/**
 *  点击第三方功能回调方法
 *
 *  @param shareMenuItem 被点击的第三方Model对象，可以在这里做一些特殊的定制
 *  @param index         被点击的位置
 */
- (void)didSelecteShareMenuItem:(XHShareMenuItem *)shareMenuItem atIndex:(NSInteger)index;

@end


@interface XHShareMenuView : UIView

/**
 *  第三方功能Models
 */
@property (nonatomic, strong) NSArray *shareMenuItems;

@property (nonatomic, weak) id <XHShareMenuViewDelegate> delegate;

/**
 *  根据数据源刷新第三方功能按钮的布局
 */
- (void)reloadData;

@end
