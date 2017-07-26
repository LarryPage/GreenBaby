//
//  XHPostInputView.m
//  Hunt
//
//  Created by LiXiangCheng on 14/12/23.
//  Copyright (c) 2014年 LiXiangCheng. All rights reserved.
//

#import "XHPostInputView.h"

@interface XHPostInputView ()

@property (nonatomic, weak, readwrite) UIButton *faceSendButton;

@property (nonatomic, weak, readwrite) UIButton *cameraSendButton;

@property (nonatomic, weak, readwrite) UIButton *atSendButton;

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
- (void)setupMessageInputViewBar;

/**
 *  配置默认参数
 */
- (void)setup ;

@end

@implementation XHPostInputView

#pragma mark - Action

- (void)messageStyleButtonClicked:(UIButton *)sender {
    NSInteger index = sender.tag;
    switch (index) {
        case 0: {// 允许拍照
            self.faceSendButton.selected = NO;
            if ([self.delegate respondsToSelector:@selector(didSelectedCameraAction)]) {
                [self.delegate didSelectedCameraAction];
            }
            break;
        }
        case 1: {//第三方表情按钮
            sender.selected = !sender.selected;
            
            if ([self.delegate respondsToSelector:@selector(didSendFaceAction:)]) {
                [self.delegate didSendFaceAction:sender.selected];
            }
            break;
        }
        case 2: {// 允许@
            self.faceSendButton.selected = NO;
            if ([self.delegate respondsToSelector:@selector(didSelectedAtAction)]) {
                [self.delegate didSelectedAtAction];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - layout subViews UI

- (UIButton *)createButtonWithImage:(UIImage *)image HLImage:(UIImage *)hlImage {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    if (image)
        [button setImage:image forState:UIControlStateNormal];
    if (hlImage)
        [button setImage:hlImage forState:UIControlStateHighlighted];
    
    return button;
}

- (void)setupMessageInputViewBar{
    // 1.配置输入工具条的样式和布局
    
    // 水平间隔
    CGFloat horizontalPadding = 8;
    
    // 垂直间隔
    CGFloat verticalPadding = 5;
    
    // 按纽x坐标
    CGFloat x = horizontalPadding;
    
    // 按纽y坐标
    CGFloat y = 0;
    
    // 每个按钮统一使用的frame变量
    CGRect buttonFrame;
    
    // 按钮对象消息
    UIButton *button;
    
    //配置at
    if (self.allowsSendAt) {
        UILabel *lbl=[[UILabel alloc] initWithFrame:CGRectMake(x, y, CGRectGetWidth(self.bounds)-x, kXHAtItemHeight-10)];
        lbl.textAlignment = NSTextAlignmentLeft;
        lbl.backgroundColor = [UIColor clearColor];
        lbl.textColor = MKRGBA(66,66,66,255);
        lbl.font = [UIFont systemFontOfSize:16];
        [self addSubview:lbl];
        
        y=kXHAtItemHeight;
        
        self.atLbl=lbl;
    }
    
    //配置背景
    UIImageView *bgIV=[[UIImageView alloc] initWithFrame:CGRectMake(0, y, CGRectGetWidth(self.bounds), KXHInputItemHeight)];
    bgIV.image=[[UIImage imageNamed:@"input-bar-flat"] resizableImageWithCapInsets:UIEdgeInsetsMake(2.0f, 0.0f, 0.0f, 0.0f)
                                                                      resizingMode:UIImageResizingModeTile];
    [self addSubview:bgIV];
    
    x=horizontalPadding;
    y+=verticalPadding;
    // 允许拍照
    if (self.allowsSendCamera) {
        button = [self createButtonWithImage:[UIImage imageNamed:@"camera"] HLImage:[UIImage imageNamed:@"camera_HL"]];
        [button addTarget:self action:@selector(messageStyleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 0;
        buttonFrame = button.frame;
        buttonFrame.origin = CGPointMake(x, y);
        button.frame = buttonFrame;
        [self addSubview:button];
        x = CGRectGetMaxX(buttonFrame)+horizontalPadding;
        
        self.cameraSendButton = button;
    }
    
    // 允许发送表情
    if (self.allowsSendFace) {
        button = [self createButtonWithImage:[UIImage imageNamed:@"face"] HLImage:[UIImage imageNamed:@"face_HL"]];
        [button addTarget:self action:@selector(messageStyleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 1;
        [button setImage:[UIImage imageNamed:@"keyborad"] forState:UIControlStateSelected];
        buttonFrame = button.frame;
        buttonFrame.origin = CGPointMake(x, y);
        button.frame = buttonFrame;
        [self addSubview:button];
        x = CGRectGetMaxX(buttonFrame)+horizontalPadding;
        
        self.faceSendButton = button;
    }
    
    // 允许@
    if (self.allowsSendAt) {
        button = [self createButtonWithImage:[UIImage imageNamed:@"at"] HLImage:[UIImage imageNamed:@"at_HL"]];
        [button addTarget:self action:@selector(messageStyleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 2;
        buttonFrame = button.frame;
        buttonFrame.origin = CGPointMake(x, y);
        button.frame = buttonFrame;
        [self addSubview:button];
        x = CGRectGetMaxX(buttonFrame)+horizontalPadding;
        
        self.atSendButton = button;
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
    _allowsSendCamera = YES;
    _allowsSendAt = YES;
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
    _atLbl = nil;
    _faceSendButton = nil;
    _cameraSendButton = nil;
    _atSendButton = nil;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    // 当别的地方需要add的时候，就会调用这里
    if (newSuperview) {
        [self setupMessageInputViewBar];
    }
}

@end
