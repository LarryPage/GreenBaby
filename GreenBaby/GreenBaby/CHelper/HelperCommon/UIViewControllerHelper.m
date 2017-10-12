//
//  UIViewControllerHelper.m
//  CardBump
//
//  Created by 香成 李 on 11-12-30.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "UIViewControllerHelper.h"
#import "UIImageHelper.h"

@implementation UIViewController(Helper)

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	NSLog(@"base alert view");
}

-(void)successAlertController{
    [UIAlertController showWithTitle:@"成功"
                             message:@"操作已成功!"
                   cancelButtonTitle:nil
                   defultButtonTitle:@"确认"
              destructiveButtonTitle:nil
                            onCancel:nil
                            onDefult:nil
                       onDestructive:nil];
}

-(void)showAlertController:(NSString*)title msg:(NSString*)msg{
    [UIAlertController showWithTitle:title
                             message:msg
                   cancelButtonTitle:nil
                   defultButtonTitle:@"确认"
              destructiveButtonTitle:nil
                            onCancel:nil
                            onDefult:nil
                       onDestructive:nil];
}

-(void)queryAlertController:(NSString*)title msg:(NSString*)msg{
    [UIAlertController showWithTitle:title
                             message:msg
                   cancelButtonTitle:NSLocalizedString(@"取消", nil)
                   defultButtonTitle:NSLocalizedString(@"确定",nil)
              destructiveButtonTitle:nil
                            onCancel:^(UIAlertAction *action) {
                                NSLog(@"base alert view");
                            }
                            onDefult:^(UIAlertAction *action) {
                                NSLog(@"base alert view");
                            }
                       onDestructive:nil];
}

- (UIBarButtonItem *)backButtonWithTarget:(id)target action:(SEL)action {
	UIButton *badgeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	badgeButton.frame = CGRectMake(0, 0, 21, 22);
	[badgeButton setImage:[UIImage imageNamed:@"BarBackBtnUnClicked.png"] forState:UIControlStateNormal];
	[badgeButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];    
	return [[UIBarButtonItem alloc] initWithCustomView:badgeButton];
}

- (void)setBackBtnWithModal:(BOOL)isModal{
    if (isModal) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BarBackBtnUnClicked.png"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissViewController)];
	} else {
		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"BarBackBtnUnClicked.png"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewController)];
	}
}

#pragma mark BtnClicked
- (void)dismissViewController{
    [self dismissViewControllerAnimated:YES completion:nil];//6.0
}

- (void)popViewController {
	[self.navigationController popViewControllerAnimated:YES];//动画需要时间，最好从viewDidLoad转移到viewDidAppear中执行
}

@end

#import <objc/runtime.h>
@implementation UIViewController (child_parent)

static char defaultChildHashKey;
static char defaultParentHashKey;

-(void)setChildController:(UIViewController *)childController
{
    objc_setAssociatedObject(self, &defaultChildHashKey, childController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
-(UIViewController*)childController
{
    return objc_getAssociatedObject(self, &defaultChildHashKey);
}
-(void)setParentController:(UIViewController *)parentController
{
    objc_setAssociatedObject(self, &defaultParentHashKey, parentController, OBJC_ASSOCIATION_ASSIGN);
}
-(UIViewController*)parentController
{
    return objc_getAssociatedObject(self, &defaultParentHashKey);
}

@end

@implementation UIViewController (Transition)

#pragma mark Transition

-(void)removeAllView{  
	for(NSInteger i=0;i<[self.view.subviews count];i++){  
		[[self.view.subviews objectAtIndex:i] removeFromSuperview];  
	}  
}

-(void)performTopTransition:(UIView *)containerView setTag:(NSInteger)tag{
    [self performTopTransition:containerView setTag:tag type:nil subtype:nil];
}


-(void)performTopTransition:(UIView *)containerView setTag:(NSInteger)tag type:(NSString *)type subtype:(NSString *)subtype
{
	// First create a CATransition object to describe the transition
	CATransition *transition = [CATransition animation];
	// Animate over 3/4 of a second
	transition.duration = 0.5;
	// using the ease in/out timing function
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	
	// Now to set the type of transition. Since we need to choose at random, we'll setup a couple of arrays to help us.
	NSString *types[4] = {kCATransitionMoveIn, kCATransitionPush, kCATransitionReveal, kCATransitionFade};
	NSString *subtypes[4] = {kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom};
	int rnd = random() % 4;
	transition.type = types[rnd];
    if(rnd < 3) // if we didn't pick the fade transition, then we need to set a subtype too
	{
		transition.subtype = subtypes[random() % 4];
	}
    
    if (type && type.length>0) {
        transition.type = type;
    }
    if (subtype && subtype.length>0) {
        transition.subtype = subtype;
    }
	
	// Finally, to avoid overlapping transitions we assign ourselves as the delegate for the animation and wait for the
	// -animationDidStop:finished: message. When it comes in, we will flag that we are no longer transitioning.
	
	transition.delegate = self;
	
	// Next add it to the containerView's layer. This will perform the transition based on how we change its contents.
	[[UIApplication sharedApplication].delegate.window.layer addAnimation:transition forKey:nil];
	[containerView setTag:tag];
	[[UIApplication sharedApplication].delegate.window addSubview:containerView];
	
}

//back
-(void)performTransition:(UIView *)containerView{
    [self performTransition:containerView type:nil subtype:nil];
}

-(void)performTransition:(UIView *)containerView type:(NSString *)type subtype:(NSString *)subtype
{
	// First create a CATransition object to describe the transition
	CATransition *transition = [CATransition animation];
	// Animate over 3/4 of a second
	transition.duration = 0.5;
	// using the ease in/out timing function
	transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	
	// Now to set the type of transition. Since we need to choose at random, we'll setup a couple of arrays to help us.
	NSString *types[4] = {kCATransitionMoveIn, kCATransitionPush, kCATransitionReveal, kCATransitionFade};
	NSString *subtypes[4] = {kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom};
	int rnd = random() % 4;
	transition.type = types[rnd];
	if(rnd < 3) // if we didn't pick the fade transition, then we need to set a subtype too
	{
		transition.subtype = subtypes[random() % 4];
	}
    
    if (type && type.length>0) {
        transition.type = type;
    }
    if (subtype && subtype.length>0) {
        transition.subtype = subtype;
    }
	
	// Finally, to avoid overlapping transitions we assign ourselves as the delegate for the animation and wait for the
	// -animationDidStop:finished: message. When it comes in, we will flag that we are no longer transitioning.
	
	transition.delegate = self;
	
	// Next add it to the containerView's layer. This will perform the transition based on how we change its contents.
	[containerView. superview.layer addAnimation:transition forKey:nil];
	[containerView removeFromSuperview];
}

@end

#import "MBProgressHUD.h"
#import <objc/runtime.h>

static const void *HttpRequestHUDKey = &HttpRequestHUDKey;

@implementation UIViewController (HUD)

- (MBProgressHUD *)HUD{
    return objc_getAssociatedObject(self, HttpRequestHUDKey);
}

- (void)setHUD:(MBProgressHUD *)HUD{
    objc_setAssociatedObject(self, HttpRequestHUDKey, HUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)showHudInView:(UIView *)view hint:(NSString *)hint{
    MBProgressHUD *HUD;
    if ([self HUD]) {
        HUD=[self HUD];
    }
    else{
        HUD = [[MBProgressHUD alloc] initWithView:view];
    }
    HUD.labelText = hint;
    [view addSubview:HUD];
    [HUD show:YES];
    [self setHUD:HUD];
}

- (void)showHint:(NSString *)hint
{
    //显示提示信息
    UIView *view = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = hint;
    hud.margin = 10.f;
    hud.yOffset = IS_IPHONE_5?200.f:150.f;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}

- (void)showHint:(NSString *)hint yOffset:(float)yOffset {
    //显示提示信息
    UIView *view = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    hud.labelText = hint;
    hud.margin = 10.f;
    hud.yOffset = IS_IPHONE_5?200.f:150.f;
    hud.yOffset += yOffset;
    hud.removeFromSuperViewOnHide = YES;
    [hud hide:YES afterDelay:2];
}

- (void)hideHud{
    [[self HUD] hide:YES];
}

@end
