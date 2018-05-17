//
//  UIAlertControllerHelper.m
//  BrcIot
//
//  Created by LiXiangCheng on 2017/10/12.
//  Copyright © 2018年 BRC. All rights reserved.
//

#import "UIAlertControllerHelper.h"

@implementation UIAlertController (Helper)

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
