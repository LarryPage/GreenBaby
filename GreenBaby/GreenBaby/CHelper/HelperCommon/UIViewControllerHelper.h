//
//  UIViewControllerHelper.h
//  CardBump
//
//  Created by 香成 李 on 11-12-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#define TEXTFIELDCELLTAG 0x10
#define SUCCESSALERT_TAG 0x20

@interface UIViewController(Helper) <UIAlertViewDelegate>

- (void)successAlertView;
- (void)showAlertView:(NSString*)title msg:(NSString*)msg;
- (void)queryAlertView:(NSString*)title msg:(NSString*)msg;
- (void)queryAlertView:(NSString*)title msg:(NSString*)msg withTag:(NSInteger)tag;

- (void)setBackBtnWithModal:(BOOL)isModal;
- (UIBarButtonItem *)backButtonWithTarget:(id)target action:(SEL)action;

@end


@interface UIViewController (child_parent)

@property(nonatomic,retain)UIViewController* childController;
@property(nonatomic,assign)UIViewController* parentController;

@end

@interface UIViewController (Transition)<CAAnimationDelegate>

-(void)removeAllView;
-(void)performTopTransition:(UIView *)containerView setTag:(NSInteger)tag;//push 随机效果
-(void)performTopTransition:(UIView *)containerView setTag:(NSInteger)tag type:(NSString *)type subtype:(NSString *)subtype;
-(void)performTransition:(UIView *)containerView;//back 随机效果
-(void)performTransition:(UIView *)containerView type:(NSString *)type subtype:(NSString *)subtype;

@end

@interface UIViewController (HUD)
- (void)showHudInView:(UIView *)view hint:(NSString *)hint;
- (void)hideHud;
- (void)showHint:(NSString *)hint;

// 从默认(showHint:)显示的位置再往上(下)yOffset
- (void)showHint:(NSString *)hint yOffset:(float)yOffset;
@end

