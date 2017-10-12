//
//  UIAlertControllerHelper.h
//  GreenBaby
//
//  Created by LiXiangCheng on 2017/10/12.
//  Copyright © 2017年 LiXiangCheng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^alertActionHandler)(UIAlertAction *action);

@interface UIAlertController (Helper)
/*
 * 方便快捷的方法抛出一个警告用户
 * bTitle_ 为空默认"Cancel"
 */
+ (void)alert:(NSString *)message_ title:(NSString *)title_ bTitle:(NSString *)bTitle_;

/**
 * @brief 便利方法，可以把点击按钮的触发事件卸载block里
 UIAlertActionStyleCancel:对按钮应用取消样式，即取消操作
 UIAlertActionStyleDefault:对按钮应用标准样式:确定
 UIAlertActionStyleDestructive:对按钮应用警示性样式，提示用户这样做可能会删除或者改变某些数据
 */
+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
    cancelButtonTitle:(NSString *)cancelButtonTitle
    defultButtonTitle:(NSString *)defultButtonTitle
destructiveButtonTitle:(NSString *)destructiveButtonTitle
             onCancel:(alertActionHandler)cancelHander
             onDefult:(alertActionHandler)defaultHander
        onDestructive:(alertActionHandler)destructiveHander;

/**
 * @brief 是否已存在UIAlertController
 */
- (BOOL)isExistAlertController;
@end
