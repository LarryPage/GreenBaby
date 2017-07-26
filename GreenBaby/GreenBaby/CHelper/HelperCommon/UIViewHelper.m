

#import "UIViewHelper.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (Helper)


//-(void)setOrigin:(CGPoint)newOrigin
//{
//	CGPoint i_center = self.center;
//	CGSize i_size = self.bounds.size;
//	
//	i_center.x += newOrigin.x - ( i_center.x - (i_size.width / 2 ) );
//	i_center.y += newOrigin.y - ( i_center.y - (i_size.height / 2 ) );
//	
//	//	i_center.x = newOrigin.x + (i_size.width / 2 );
//	//	i_center.y = newOrigin.y + (i_size.height / 2 );
//	
//	[self setCenter:i_center];
//}
//
//-(void)setSize:(CGSize)heightWidth
//{
//	CGRect newFrame = self.frame;
//	newFrame.size = heightWidth;
//	[self setFrame:newFrame];
//}

-(void)centerInView:(UIView*)containingView
{
	[self centerInView:containingView xOffset:0.0f yOffset:0.0f];
}

-(void)centerInView:(UIView*)containingView xOffset:(CGFloat)x_offset yOffset:(CGFloat)y_offset
{
	CGFloat container_center_x = containingView.bounds.size.width / 2.0f;
	CGFloat container_center_y = containingView.bounds.size.height / 2.0f;
	
	CGFloat view_center_x = self.bounds.size.width / 2.0f;
	CGFloat view_center_y = self.bounds.size.height / 2.0f;
	
	CGFloat new_x = container_center_x - view_center_x;
	CGFloat new_y = container_center_y - view_center_y;
	
	CGRect new_frame = CGRectIntegral(CGRectMake(new_x + x_offset, new_y + y_offset, self.bounds.size.width, self.bounds.size.height));
	
	[self setFrame:new_frame];
}

-(UIImage*)dumpImage
{
	CGSize size = self.frame.size;
	
	UIGraphicsBeginImageContext(size);
	
	[self.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage* viewImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	// hopefully this wont go out of scope before we return.  if so we'll have to autorelease it
	return viewImage;
}

- (void)setClipsToBoundsRecursively:(BOOL)clips
{
	UIView *currentView = self;    
	do {
		currentView.clipsToBounds = clips;
    }
	while ((currentView = [currentView superview]));
}

- (void)dumpInfo:(NSInteger)inDepth
{
	char theSpaces[] = "..........";
	
	printf("%.*s%s %s (bgColor:%s, hidden:%d, opaque:%d, alpha:%g, clipsToBounds:%d)\n", (int)MIN(inDepth, strlen(theSpaces)), theSpaces, [[self description] UTF8String], [NSStringFromCGRect(self.frame) UTF8String], [[self.backgroundColor description] UTF8String], self.hidden, self.opaque, self.alpha, self.clipsToBounds);
	for (UIView *theView in self.subviews)
	{
		[theView dumpInfo:inDepth + 1];
	}
}

- (void)moveToSuperview:(UIView *)inSuperview
{
	if (inSuperview != self.superview)
	{
		CGRect theFrame = self.frame;
		theFrame = [inSuperview convertRect:theFrame fromView:self.superview];
		[self removeFromSuperview];
		[inSuperview addSubview:self];
		self.frame = theFrame;
	}
}

//通过UIView获取它的UIViewController
-(UIViewController*)getViewController{
    id nextResponder = [self nextResponder];
    while (nextResponder) {
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return nextResponder;
        }
        else{
            nextResponder = [nextResponder nextResponder];
        }
    }
    return nil;
}

#pragma mark - 便捷方法

- (CGFloat)x {
    return CGRectGetMinX(self.frame);
}

- (CGFloat)y {
    return CGRectGetMinY(self.frame);
}

- (CGFloat)width {
    return CGRectGetWidth(self.frame);
}

- (CGFloat)height {
    return CGRectGetHeight(self.frame);
}

@end
