//
//  XHMessageInputView.m
//  MessageDisplayExample
//
//  Created by LiXiangCheng on 14-4-24.
//  Copyright (c) 2014年 LiXiangCheng. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "XHMessageInputView.h"

@interface XHMessageInputView () <UITextViewDelegate>

@property (nonatomic, weak, readwrite) XHMessageTextView *inputTextView;

@property (nonatomic, weak, readwrite) UIButton *faceSendButton;

@property (nonatomic, weak, readwrite) UIButton *multiMediaSendButton;

/**
 *  输入框内的所有按钮，点击事件所触发的方法
 *
 *  @param sender 被点击的按钮对象
 */
- (void)messageStyleButtonClicked:(UIButton *)sender;

#pragma mark - layout subViews UI
/**
 *  根据正常显示和高亮状态创建一个按钮对象
 *
 *  @param image   正常显示图
 *  @param hlImage 高亮显示图
 *
 *  @return 返回按钮对象
 */
- (UIButton *)createButtonWithImage:(UIImage *)image HLImage:(UIImage *)hlImage ;

/**
 *  根据输入框的样式类型配置输入框的样式和UI布局
 *
 *  @param style 输入框样式类型
 */
- (void)setupMessageInputViewBarWithStyle:(XHMessageInputViewStyle)style ;

/**
 *  配置默认参数
 */
- (void)setup ;

#pragma mark - Message input view
/**
 *  动态改变textView的高度
 *
 *  @param changeInHeight 动态的高度
 */
- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight;

@end

@implementation XHMessageInputView

#pragma mark - Action

- (void)messageStyleButtonClicked:(UIButton *)sender {
    NSInteger index = sender.tag;
    switch (index) {
        case 0: {//第三方表情按钮
            sender.selected = !sender.selected;
            self.multiMediaSendButton.selected = NO;
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.inputTextView.alpha = 1.0;
            } completion:^(BOOL finished) {
                
            }];
            
            if ([self.delegate respondsToSelector:@selector(didSendFaceAction:)]) {
                [self.delegate didSendFaceAction:sender.selected];
            }
            break;
        }
        case 1: {//+号按钮
            sender.selected = !sender.selected;
            self.faceSendButton.selected = NO;
            
            if ([self.delegate respondsToSelector:@selector(didSelectedMultipleMediaAction)]) {
                [self.delegate didSelectedMultipleMediaAction];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - layout subViews UI

- (UIButton *)createButtonWithImage:(UIImage *)image HLImage:(UIImage *)hlImage {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [XHMessageInputView textViewLineHeight], [XHMessageInputView textViewLineHeight])];
    if (image)
        [button setImage:image forState:UIControlStateNormal];
    if (hlImage)
        [button setImage:hlImage forState:UIControlStateHighlighted];
    
    return button;
}

- (void)setupMessageInputViewBarWithStyle:(XHMessageInputViewStyle)style {
    // 配置输入工具条的样式和布局
    
    // 需要显示按钮的总宽度，包括间隔在内
    CGFloat allButtonWidth = 0.0;
    
    // 水平间隔
    CGFloat horizontalPadding = 8;
    
    // 垂直间隔
    CGFloat verticalPadding = 5;
    
    // 输入框
    CGFloat textViewLeftMargin = ((style == XHMessageInputViewStyleFlat) ? 6.0 : 4.0);
    
    // 每个按钮统一使用的frame变量
    CGRect buttonFrame;
    
    // 按钮对象消息
    UIButton *button;
    
    // 允许发送表情
    if (self.allowsSendFace) {
        button = [self createButtonWithImage:[UIImage imageNamed:@"face"] HLImage:[UIImage imageNamed:@"face_HL"]];
        [button addTarget:self action:@selector(messageStyleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 0;
        [button setImage:[UIImage imageNamed:@"keyborad"] forState:UIControlStateSelected];
        buttonFrame = button.frame;
        buttonFrame.origin = CGPointMake(horizontalPadding, verticalPadding);
        button.frame = buttonFrame;
        [self addSubview:button];
        allButtonWidth += CGRectGetMaxX(buttonFrame);
        textViewLeftMargin += CGRectGetMaxX(buttonFrame);
        
        self.faceSendButton = button;
    }
    
    // 允许发送多媒体消息，为什么不是先放表情按钮呢？因为布局的需要！
    if (self.allowsSendMultiMedia) {
        button = [self createButtonWithImage:[UIImage imageNamed:@"multiMedia"] HLImage:[UIImage imageNamed:@"multiMedia_HL"]];
        [button setImage:[UIImage imageNamed:@"keyborad"] forState:UIControlStateSelected];
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [button addTarget:self action:@selector(messageStyleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 1;
        buttonFrame = button.frame;
        buttonFrame.origin = CGPointMake(CGRectGetWidth(self.bounds) - horizontalPadding - CGRectGetWidth(buttonFrame), verticalPadding);
        button.frame = buttonFrame;
        [self addSubview:button];
        allButtonWidth += CGRectGetWidth(buttonFrame) + horizontalPadding * 2.5;
        
        self.multiMediaSendButton = button;
    }
    
    // 输入框的高度和宽度
    CGFloat width = CGRectGetWidth(self.bounds) - (self.allowsSendMultiMedia ? allButtonWidth : (textViewLeftMargin + horizontalPadding));
    CGFloat height = [XHMessageInputView textViewLineHeight];
    
    // 初始化输入框
    XHMessageTextView *textView = [[XHMessageTextView  alloc] initWithFrame:CGRectZero];
    
    // 这个是仿微信的一个细节体验
    textView.returnKeyType = UIReturnKeySend;
    textView.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
    
    textView.placeHolder = @"发送新消息";
    textView.delegate = self;
    
    [self addSubview:textView];
	_inputTextView = textView;
    
    // 配置不同iOS SDK版本的样式
    switch (style) {
        case XHMessageInputViewStyleQuasiphysical: {
            _inputTextView.frame = CGRectMake(textViewLeftMargin, 3.0f, width, height);
            _inputTextView.backgroundColor = [UIColor whiteColor];
            
            self.image = [[UIImage imageNamed:@"input-bar-background"] resizableImageWithCapInsets:UIEdgeInsetsMake(19.0f, 3.0f, 19.0f, 3.0f)
                                                                                      resizingMode:UIImageResizingModeStretch];
            
            UIImageView *inputFieldBack = [[UIImageView alloc] initWithFrame:CGRectMake(_inputTextView.frame.origin.x - 1.0f,
                                                                                        0.0f,
                                                                                        _inputTextView.frame.size.width + 2.0f,
                                                                                        self.frame.size.height)];
            inputFieldBack.image = [[UIImage imageNamed:@"input-field-cover"] resizableImageWithCapInsets:UIEdgeInsetsMake(20.0f, 12.0f, 18.0f, 18.0f)];
            inputFieldBack.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
            inputFieldBack.backgroundColor = [UIColor clearColor];
            [self addSubview:inputFieldBack];
            break;
        }
        case XHMessageInputViewStyleFlat: {
            _inputTextView.frame = CGRectMake(textViewLeftMargin, 4.5f, width, height);
            _inputTextView.backgroundColor = [UIColor clearColor];
            _inputTextView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
            _inputTextView.layer.borderWidth = 0.65f;
            _inputTextView.layer.cornerRadius = 6.0f;
            self.backgroundColor = [UIColor whiteColor];
            self.image = [[UIImage imageNamed:@"input-bar-flat"] resizableImageWithCapInsets:UIEdgeInsetsMake(2.0f, 0.0f, 0.0f, 0.0f)
                                                                                 resizingMode:UIImageResizingModeTile];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Life cycle

- (void)setup {
    // 配置自适应
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.opaque = YES;
    // 由于继承UIImageView，所以需要这个属性设置
    self.userInteractionEnabled = YES;
    
    // 默认设置
    _allowsSendFace = YES;
    _allowsSendMultiMedia = YES;
    
    _messageInputViewStyle = XHMessageInputViewStyleFlat;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setup];
    }
    return self;
}

- (void)dealloc {
    //_inputTextView.delegate = nil;
    _inputTextView = nil;
    
    _faceSendButton = nil;
    _multiMediaSendButton = nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    // 当别的地方需要add的时候，就会调用这里
    if (newSuperview) {
        [self setupMessageInputViewBarWithStyle:self.messageInputViewStyle];
    }
}

#pragma mark - Message input view

- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight {
    // 动态改变自身的高度和输入框的高度
    CGRect prevFrame = self.inputTextView.frame;
    
    NSUInteger numLines = MAX([self.inputTextView numberOfLinesOfText],
                              [[self.inputTextView.text componentsSeparatedByString:@"\n"] count] + 1);
    
    self.inputTextView.frame = CGRectMake(prevFrame.origin.x,
                                     prevFrame.origin.y,
                                     prevFrame.size.width,
                                     prevFrame.size.height + changeInHeight);
    
    
    self.inputTextView.contentInset = UIEdgeInsetsMake((numLines >= 6 ? 4.0f : 0.0f),
                                                  0.0f,
                                                  (numLines >= 6 ? 4.0f : 0.0f),
                                                  0.0f);
    
    // from iOS 7, the content size will be accurate only if the scrolling is enabled.
    self.inputTextView.scrollEnabled = YES;
    
    if (numLines >= 6) {
        CGPoint bottomOffset = CGPointMake(0.0f, self.inputTextView.contentSize.height - self.inputTextView.bounds.size.height);
        [self.inputTextView setContentOffset:bottomOffset animated:YES];
        [self.inputTextView scrollRangeToVisible:NSMakeRange(self.inputTextView.text.length - 2, 1)];
    }
}

+ (CGFloat)textViewLineHeight {
    return 36.0f; // for fontSize 16.0f
}

+ (CGFloat)maxLines {
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) ? 3.0f : 8.0f;
}

+ (CGFloat)maxHeight {
    return ([XHMessageInputView maxLines] + 1.0f) * [XHMessageInputView textViewLineHeight];
}

#pragma mark - Text view delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(inputTextViewWillBeginEditing:)]) {
        [self.delegate inputTextViewWillBeginEditing:self.inputTextView];
    }
    self.faceSendButton.selected = NO;
    return YES;
}

//- (void)textViewDidBeginEditing:(UITextView *)textView {
//    [textView becomeFirstResponder];
//    if ([self.delegate respondsToSelector:@selector(inputTextViewDidBeginEditing:)]) {
//        [self.delegate inputTextViewDidBeginEditing:self.inputTextView];
//    }
//}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(didSendTextAction:)]) {
            [self.delegate didSendTextAction:textView.text];
        }
        return NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(inputTextView:shouldChangeTextInRange:replacementText:)]) {
        return [self.delegate inputTextView:self.inputTextView shouldChangeTextInRange:range replacementText:text];
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(textViewDidChange:)]) {
        [self.delegate textViewDidChange:self.inputTextView];
    }
}

@end
