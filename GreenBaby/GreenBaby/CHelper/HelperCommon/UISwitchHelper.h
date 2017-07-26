#import <UIKit/UIKit.h>

@interface UISwitch (Helper)

// 设置左右文字来初始化UISwitch
+(UISwitch*)allocSwitchWithLeftText:(NSString*)yesText andRight:(NSString*)noText;

@property (nonatomic, readonly)	UILabel* label1;
@property (nonatomic, readonly)	UILabel* label2;

@end