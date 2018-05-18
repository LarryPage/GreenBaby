//
//  UIAlertControllerHelper.h
//  BrcIot
//
//  Created by LiXiangCheng on 2017/10/12.
//  Copyright © 2018年 BRC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^alertActionHandler)(UIAlertAction *action);

@interface UIAlertController (Helper)
/**
 * @brief 是否已存在UIAlertController
 */
- (BOOL)isExistAlertController;
@end

@interface UIAlertController (UIAlertView)
/*
 * 方便快捷的方法抛出一个警告用户
 * bTitle_ 为空默认"Cancel"
 */
+ (void)alert:(NSString *)message_ title:(NSString *)title_ bTitle:(NSString *)bTitle_;

/**
 * @brief 便利方法，可以把点击按钮的触发事件卸载block里
 UIAlertActionStyleCancel:对按钮应用取消样式，即取消操作
 UIAlertActionStyleDefault:对按钮应用标准样式:确定,可建多个
 UIAlertActionStyleDestructive:对按钮应用警示性样式，提示用户这样做可能会删除或者改变某些数据，会显示红色
 */
+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
    cancelButtonTitle:(NSString *)cancelButtonTitle
    defultButtonTitle:(NSString *)defultButtonTitle
destructiveButtonTitle:(NSString *)destructiveButtonTitle
             onCancel:(alertActionHandler)cancelHander
             onDefult:(alertActionHandler)defaultHander
        onDestructive:(alertActionHandler)destructiveHander;
@end

@interface UIAlertController (UIActionSheet)
/**
 * @brief 便利方法，可以把点击按钮的触发事件卸载block里
 UIAlertActionStyleCancel:对按钮应用取消样式，即取消操作
 UIAlertActionStyleDefault:对按钮应用标准样式:确定，可建多个
 UIAlertActionStyleDestructive:对按钮应用警示性样式，会显示红色
 sourceView:要在此视图显示的UIActionSheet
 */
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
           sourceView:(UIView *)sourceView;
@end
