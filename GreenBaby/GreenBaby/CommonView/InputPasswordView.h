//
//  InputPasswordView.h
//  PayPassword
//
//  Created by Joel on 15/8/20.
//  Copyright (c) 2015年 Joel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InputPasswordView : UIView

/**
 *  6位支付密码输入完成的回调
 */
@property (copy, nonatomic) void (^finishedInputBlock)(NSString *inputedPassword);


@end
