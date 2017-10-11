

#import <UIKit/UIKit.h>

typedef void (^DismissBlock)(NSInteger buttonIndex);
typedef void (^CancelBlock)(void);

@interface UIAlertView (Helper)
/*
 * 方便快捷的方法抛出一个警告用户
 * bTitle_ 为空默认"Cancel"
 */
+ (void)alert:(NSString *)message_ title:(NSString *)title_ bTitle:(NSString *)bTitle_;

/**
 * @brief 便利方法，可以把点击按钮的触发事件卸载block里
 */
+ (UIAlertView *)showAlertViewWithTitle:(NSString *)title
                                message:(NSString *)message
                      cancelButtonTitle:(NSString *)cancelButtonTitle
                      otherButtonTitles:(NSArray *)otherButtons
                              onDismiss:(DismissBlock)dismissed
                               onCancel:(CancelBlock)cancelled;

/**
 * @brief 是否已存在UIAlertView
 */
- (BOOL)isExistAlertView;
@end
