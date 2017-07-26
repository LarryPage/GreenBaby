

#import "UIToolbarHelper.h"


@implementation UIToolbar (Helper)

- (void)setItemTitle:(NSString*)title forTag:(NSInteger)tag {
	UIBarButtonItem* item = [self itemWithTag:tag];
	if(!item) return;
	item.title = title ? title : @"";
}

- (UIBarButtonItem*)itemWithTag:(NSInteger)tag {
	for(UIBarButtonItem* item in self.items) {
		if(item.tag == tag) {
			return item;
		}
	}
	
	return nil;
}


@end
