//
//  XHFaceManagerView.h
//  Hunt
//
//  Created by LiXiangCheng on 14/12/22.
//  Copyright (c) 2014年 LiXiangCheng. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kXHFacePageControlHeight 38
#define kXHFaceBottomSectionHeight 36

@protocol XHFaceManagerViewDelegate <NSObject>

@optional
/**
 *  第三方表情被点击的回调事件
 *
 *  @param faceName   被点击的第三方表情对应的名称,表情集索引中的key
 */
- (void)didSelecteFace:(NSString *)faceName;

/**
 *  删除按纽被点击的回调事件
 */
- (void)deleteFace;

/**
 *  发送按纽被点击的回调事件

 */
- (void)didSend;

@end

@interface XHFaceManagerView : UIView

/**
 *  第三方表情集（NSDictionary)
 */
@property (nonatomic, strong) NSDictionary *faceMap;

@property (nonatomic, weak) id <XHFaceManagerViewDelegate> delegate;

/**
 *  显示底部发送按纽
 */
@property (nonatomic, weak) UIButton *sendBtn;

/**
 *  根据数据源刷新第三方功能按钮的布局
 */
- (void)reloadData;

@end
