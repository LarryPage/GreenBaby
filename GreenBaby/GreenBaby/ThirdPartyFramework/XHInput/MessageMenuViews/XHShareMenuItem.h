//
//  XHShareMenuItem.h
//  MessageDisplayExample
//
//  Created by LiXiangCheng on 14-5-1.
//  Copyright (c) LiXiangCheng. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kXHShareMenuItemWidth 60
#define KXHShareMenuItemHeight 80

@interface XHShareMenuItem : NSObject

/**
 *  正常显示图片
 */
@property (nonatomic, strong) UIImage *normalIconImage;

/**
 *  第三方按钮的标题
 */
@property (nonatomic, copy) NSString *title;

/**
 *  根据正常图片和标题初始化一个Model对象
 *
 *  @param normalIconImage 正常图片
 *  @param title           标题
 *
 *  @return 返回一个Model对象
 */
- (instancetype)initWithNormalIconImage:(UIImage *)normalIconImage
                                  title:(NSString *)title;

@end
