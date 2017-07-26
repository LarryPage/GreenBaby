

#import "UIAlertViewHelper.h"

static DismissBlock _dismissBlock;
static CancelBlock _cancelBlock;

@implementation UIAlertView (Helper)

+ (void)alert:(NSString *)message_ title:(NSString *)title_ bTitle:(NSString *)bTitle_
{	
	if (bTitle_ == nil) {
		bTitle_ =  NSLocalizedString(@"确定",nil);
	}
	
	UIAlertView *alertView;
	alertView = [[UIAlertView alloc] initWithTitle:title_
										   message:message_ 
										  delegate:nil 
								 cancelButtonTitle:bTitle_
								 otherButtonTitles:nil
				 ];
	[alertView show];
}

+ (UIAlertView *)showAlertViewWithTitle:(NSString *)title
                                message:(NSString *)message
                      cancelButtonTitle:(NSString *)cancelButtonTitle
                      otherButtonTitles:(NSArray *)otherButtons
                              onDismiss:(DismissBlock)dismissed
                               onCancel:(CancelBlock)cancelled
{
    _cancelBlock = cancelled;
    _dismissBlock = dismissed;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:nil];
    for (NSString *buttonTitle in otherButtons) {
        [alert addButtonWithTitle:buttonTitle];
    }
    [alert show];
    return alert;
}

+ (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [alertView cancelButtonIndex]) {
        if (_cancelBlock) {
            _cancelBlock();
        }
    } else {
        if (_dismissBlock) {
            _dismissBlock(buttonIndex - 1); // 取消按钮是0
        }
    }
}

- (BOOL)isExistAlertView{
    for (UIWindow* window in [UIApplication sharedApplication].windows) {
        for (UIView* view in window.subviews) {
            BOOL alert = [view isKindOfClass:[UIAlertView class]];
            if (alert)
                return YES;
        }
    }
    return NO;
}

@end
