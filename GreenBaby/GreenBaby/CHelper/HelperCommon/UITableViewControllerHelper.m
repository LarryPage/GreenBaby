

#if TARGET_OS_IPHONE
#import "UITableViewControllerHelper.h"

@implementation UITableViewController (Helper)

- (CGFloat)cellHeightWithText:(NSString*)text padding:(float)padding {
	return [self cellHeightWithText:text padding:padding minimumHeight:0.0f maximumHeight:0.0f];
}
- (CGFloat)cellHeightWithText:(NSString*)text padding:(float)padding  fontSize:(float)fontSize{
	return [self cellHeightWithText:text padding:padding minimumHeight:0.0f maximumHeight:0.0f  fontSize:fontSize];
}

- (CGFloat)cellHeightWithText:(NSString*)text padding:(float)padding minimumHeight:(float)minimumHeight {
	return [self cellHeightWithText:text padding:padding minimumHeight:minimumHeight maximumHeight:0.0f];
}
- (CGFloat)cellHeightWithText:(NSString*)text padding:(float)padding minimumHeight:(float)minimumHeight  fontSize:(float)fontSize{
	return [self cellHeightWithText:text padding:padding minimumHeight:minimumHeight maximumHeight:0.0f  fontSize:fontSize];
}

- (CGFloat)cellHeightWithText:(NSString*)text padding:(float)padding maximumHeight:(float)maximumHeight {
	return [self cellHeightWithText:text padding:padding minimumHeight:0.0f maximumHeight:maximumHeight];
}
- (CGFloat)cellHeightWithText:(NSString*)text padding:(float)padding maximumHeight:(float)maximumHeight  fontSize:(float)fontSize{
	return [self cellHeightWithText:text padding:padding minimumHeight:0.0f maximumHeight:maximumHeight  fontSize:fontSize];
}
- (CGFloat)cellHeightWithText:(NSString*)text padding:(float)padding minimumHeight:(float)minimumHeight maximumHeight:(float)maximumHeight {
	return [self cellHeightWithText:text padding:padding minimumHeight:0.0f maximumHeight:maximumHeight  fontSize:14.0f];
}
- (CGFloat)cellHeightWithText:(NSString*)text padding:(float)padding minimumHeight:(float)minimumHeight maximumHeight:(float)maximumHeight  fontSize:(float)fontSize {
//	CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(300.0f, MAXFLOAT) lineBreakMode:UILineBreakModeWordWrap];
    //modify by lxc for ios7
    CGSize size = [text adjustSizeWithFont:[UIFont systemFontOfSize:fontSize] constrainedToSize:CGSizeMake(300.0f, MAXFLOAT)];
    
	float height = size.height + padding;
	if(minimumHeight > 0.0f && height < minimumHeight) {
		height = minimumHeight;
	}
	
	if(maximumHeight > 0.0f && height > maximumHeight) {
		height = maximumHeight;
	}
	
	return height;
}

- (NSArray*)indexPathsFromRow:(NSUInteger)fromRow toRow:(NSUInteger)toRow inSection:(NSUInteger)inSection {
	NSMutableArray* indexPaths = [NSMutableArray arrayWithCapacity:toRow-fromRow];
	NSUInteger x;
	for(x=fromRow;x<=toRow;x++) {
		[indexPaths addObject:[NSIndexPath indexPathForRow:x inSection:inSection]];
	}
	
	return indexPaths;
}

- (NSArray*)indexPathsForRow:(NSUInteger)forRow inSection:(NSUInteger)inSection {
	return [NSArray arrayWithObject:[NSIndexPath indexPathForRow:forRow inSection:inSection]];
}

@end
#endif