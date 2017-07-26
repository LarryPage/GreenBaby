

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>

@interface UITableViewController (Helper)
// 返回一个单元格的高度,给予所需属性，字体默认大小为14.0f（这可以是变化的）
- (CGFloat)cellHeightWithText:(NSString*)text padding:(float)padding;
- (CGFloat)cellHeightWithText:(NSString*)text padding:(float)padding fontSize:(float)fontSize;

- (CGFloat)cellHeightWithText:(NSString*)text padding:(float)padding minimumHeight:(float)minimumHeight;
- (CGFloat)cellHeightWithText:(NSString*)text padding:(float)padding minimumHeight:(float)minimumHeight fontSize:(float)fontSize;

- (CGFloat)cellHeightWithText:(NSString*)text padding:(float)padding maximumHeight:(float)maximumHeight;
- (CGFloat)cellHeightWithText:(NSString*)text padding:(float)padding maximumHeight:(float)maximumHeight fontSize:(float)fontSize;

- (CGFloat)cellHeightWithText:(NSString*)text padding:(float)padding minimumHeight:(float)minimumHeight maximumHeight:(float)maximumHeight;
- (CGFloat)cellHeightWithText:(NSString*)text padding:(float)padding minimumHeight:(float)minimumHeight maximumHeight:(float)maximumHeight fontSize:(float)fontSize;

// Returns an NSArray of generated NSIndexPaths based on parameters
- (NSArray*)indexPathsFromRow:(NSUInteger)fromRow toRow:(NSUInteger)toRow inSection:(NSUInteger)inSection;

// Returns an NSArray containing a single NSIndexPath
- (NSArray*)indexPathsForRow:(NSUInteger)forRow inSection:(NSUInteger)inSection;
@end
#endif