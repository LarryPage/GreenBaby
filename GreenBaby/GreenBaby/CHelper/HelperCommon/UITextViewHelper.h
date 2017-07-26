


#import <UIKit/UIKit.h>

@interface UITextView (Helper)
// 自动调整大小
-(void)resizeToFit;
-(void)resizeToFitWithPadding:(float)padding minimumHeight:(float)minimumHeight maximumHeight:(float)maximumHeight;

@end
