//
//  XHMessageInputView.h
//  MessageDisplayExample
//
//  Created by LiXiangCheng on 14-4-24.
//  Copyright (c) 2014年 LiXiangCheng. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "XHMessageTextView.h"

typedef NS_ENUM(NSInteger, XHMessageInputViewStyle) {
    // 分两种,一种是iOS6样式的，一种是iOS7样式的
    XHMessageInputViewStyleQuasiphysical,
    XHMessageInputViewStyleFlat
};

@protocol XHMessageInputViewDelegate <NSObject>

@required

/**
 *  输入框将要开始编辑
 *
 *  @param messageInputTextView 输入框对象
 */
- (void)inputTextViewWillBeginEditing:(XHMessageTextView *)messageInputTextView;

/**
 *  输入框刚好开始编辑
 *
 *  @param messageInputTextView 输入框对象
 */
//- (void)inputTextViewDidBeginEditing:(XHMessageTextView *)messageInputTextView;

/**
 *  输入框内容改变时
 *
 *  @param messageInputTextView 输入框对象
 */
- (BOOL)inputTextView:(XHMessageTextView *)messageInputTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

- (void)textViewDidChange:(UITextView *)textView;

@optional

/**
 *  发送文本消息，包括系统的表情
 *
 *  @param text 目标文本消息
 */
- (void)didSendTextAction:(NSString *)text;

/**
 *  发送第三方表情Emoji
 *
 *  @param sendFace 是否在发送第三方表情状态
 */
- (void)didSendFaceAction:(BOOL)sendFace;

/**
 *  点击+号按钮Action
 */
- (void)didSelectedMultipleMediaAction;

@end

@interface XHMessageInputView : UIImageView

@property (nonatomic, weak) id <XHMessageInputViewDelegate> delegate;

/**
 *  用于输入文本消息的输入框
 */
@property (nonatomic, weak, readonly) XHMessageTextView *inputTextView;

/**
 *  当前输入工具条的样式
 */
@property (nonatomic, assign) XHMessageInputViewStyle messageInputViewStyle;  // default is XHMessageInputViewStyleFlat

/**
 *  是否支持发送表情
 */
@property (nonatomic, assign) BOOL allowsSendFace; // default is YES

/**
 *  是否允许发送多媒体
 */
@property (nonatomic, assign) BOOL allowsSendMultiMedia; // default is YES

/**
 *  第三方表情按钮
 */
@property (nonatomic, weak, readonly) UIButton *faceSendButton;

/**
 *  +号按钮
 */
@property (nonatomic, weak, readonly) UIButton *multiMediaSendButton;

#pragma mark - Message input view

/**
 *  动态改变高度
 *
 *  @param changeInHeight 目标变化的高度
 */
- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight;

/**
 *  获取输入框内容字体行高
 *
 *  @return 返回行高
 */
+ (CGFloat)textViewLineHeight;

/**
 *  获取最大行数
 *
 *  @return 返回最大行数
 */
+ (CGFloat)maxLines;

/**
 *  获取根据最大行数和每行高度计算出来的最大显示高度
 *
 *  @return 返回最大显示高度
 */
+ (CGFloat)maxHeight;


@end
