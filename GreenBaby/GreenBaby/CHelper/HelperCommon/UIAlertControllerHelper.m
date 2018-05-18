//
//  UIAlertControllerHelper.m
//  BrcIot
//
//  Created by LiXiangCheng on 2017/10/12.
//  Copyright © 2018年 BRC. All rights reserved.
//

#import "UIAlertControllerHelper.h"

@implementation UIAlertController (Helper)

- (BOOL)isExistAlertController{
    for (UIWindow* window in [UIApplication sharedApplication].windows) {
        for (UIView* view in window.subviews) {
            BOOL alert = [view isKindOfClass:[UIAlertController class]];
            if (alert)
                return YES;
        }
    }
    return NO;
}

@end

@implementation UIAlertController (UIAlertView)

+ (void)alert:(NSString *)message_ title:(NSString *)title_ bTitle:(NSString *)bTitle_
{
    if (bTitle_ == nil) {
        bTitle_ =  NSLocalizedString(@"确定",nil);
    }
    
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:title_ message:message_ preferredStyle:UIAlertControllerStyleAlert];
    //取消
    UIAlertAction *cancel=[UIAlertAction actionWithTitle:bTitle_ style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
    }];
    [alert addAction:cancel];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
    cancelButtonTitle:(NSString *)cancelButtonTitle
    defultButtonTitle:(NSString *)defultButtonTitle
destructiveButtonTitle:(NSString *)destructiveButtonTitle
             onCancel:(alertActionHandler)cancelHander
             onDefult:(alertActionHandler)defaultHander
        onDestructive:(alertActionHandler)destructiveHander
{
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (cancelButtonTitle && cancelButtonTitle.length) {
        //UIAlertActionStyleCancel:对按钮应用取消样式，即取消操作
        UIAlertAction *cancel=[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            cancelHander(action);
        }];
        [alert addAction:cancel];
    }
    
    //defaultButton可多个
    if (defultButtonTitle && defultButtonTitle.length) {
        //UIAlertActionStyleDefault:对按钮应用标准样式:确定
        UIAlertAction *defult = [UIAlertAction actionWithTitle:defultButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            defaultHander(action);
        }];
        [alert addAction:defult];
    }
    
    if (destructiveButtonTitle && destructiveButtonTitle.length) {
        //UIAlertActionStyleDestructive:对按钮应用警示性样式，提示用户这样做可能会删除或者改变某些数据
        UIAlertAction *destructive = [UIAlertAction actionWithTitle:destructiveButtonTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
            destructiveHander(action);
        }];
        [alert addAction:destructive];
    }
    
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

@end

@implementation UIAlertController (UIActionSheet)

+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
    cancelButtonTitle:(NSString *)cancelButtonTitle
   defultButton1Title:(NSString *)defultButton1Title
   defultButton2Title:(NSString *)defultButton2Title
destructiveButtonTitle:(NSString *)destructiveButtonTitle
             onCancel:(alertActionHandler)cancelHander
            onDefult1:(alertActionHandler)default1Hander
            onDefult2:(alertActionHandler)default2Hander
        onDestructive:(alertActionHandler)destructiveHander
           sourceView:(UIView *)sourceView;{
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (cancelButtonTitle && cancelButtonTitle.length) {
        //UIAlertActionStyleCancel:对按钮应用取消样式，即取消操作
        UIAlertAction *cancel=[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            cancelHander(action);
        }];
        [alert addAction:cancel];
    }
    
    //defaultButton可多个
    if (defultButton1Title && defultButton1Title.length) {
        //UIAlertActionStyleDefault:对按钮应用标准样式:确定
        UIAlertAction *defult1 = [UIAlertAction actionWithTitle:defultButton1Title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            default1Hander(action);
        }];
        [alert addAction:defult1];
    }
    if (defultButton2Title && defultButton2Title.length) {
        //UIAlertActionStyleDefault:对按钮应用标准样式:确定
        UIAlertAction *defult2 = [UIAlertAction actionWithTitle:defultButton2Title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            default2Hander(action);
        }];
        [alert addAction:defult2];
    }
    
    if (destructiveButtonTitle && destructiveButtonTitle.length) {
        //UIAlertActionStyleDestructive:对按钮应用警示性样式，提示用户这样做可能会删除或者改变某些数据
        UIAlertAction *destructive = [UIAlertAction actionWithTitle:destructiveButtonTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action){
            destructiveHander(action);
        }];
        [alert addAction:destructive];
    }
    
    [alert setModalPresentationStyle:UIModalPresentationPopover];
    
    UIPopoverPresentationController *popover = [alert popoverPresentationController];
    popover.sourceView = sourceView;
    popover.sourceRect = sourceView.bounds;
    popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

@end
