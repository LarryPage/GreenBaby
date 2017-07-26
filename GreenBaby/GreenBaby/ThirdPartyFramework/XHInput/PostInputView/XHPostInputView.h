//
//  XHPostInputView.h
//  Hunt
//
//  Created by LiXiangCheng on 14/12/23.
//  Copyright (c) 2014年 LiXiangCheng. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kXHAtItemHeight 30
#define KXHInputItemHeight 45

typedef NS_ENUM(NSUInteger, XHPostInputViewType) {
    XHPostInputViewTypeNormal = 0,
    XHPostInputViewTypeText,
    XHPostInputViewTypeFace,
    XHPostInputViewTypeCamera,
    XHPostInputViewTypeAt,
};

@protocol XHPostInputViewDelegate <NSObject>

@required

/**
 *  发送第三方表情Emoji
 *
 *  @param sendFace 是否在发送第三方表情状态
 */
- (void)didSendFaceAction:(BOOL)sendFace;

@optional

/**
 *  点击拍照按钮Action
 */
- (void)didSelectedCameraAction;

/**
 *  点击@按钮Action
 */
- (void)didSelectedAtAction;

@end

@interface XHPostInputView : UIView

@property (nonatomic, weak) id <XHPostInputViewDelegate> delegate;

/**
 *  是否支持发送表情
 */
@property (nonatomic, assign) BOOL allowsSendFace; // default is YES

/**
 *  是否允许拍照
 */
@property (nonatomic, assign) BOOL allowsSendCamera; // default is YES

/**
 *  是否允许@
 */
@property (nonatomic, assign) BOOL allowsSendAt; // default is YES

/**
 *  at标签
 */
@property (nonatomic, weak, readwrite) UILabel *atLbl;

/**
 *  第三方表情按钮
 */
@property (nonatomic, weak, readonly) UIButton *faceSendButton;

/**
 *  拍照按钮
 */
@property (nonatomic, weak, readonly) UIButton *cameraSendButton;

@end
