//
//  UITextView.m
//  FFHelper
//
//  Created by Futao on 10-12-28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UITextViewHelper.h"
#import "UIViewHelper.h"
@implementation UITextView (Helper)

-(void)resizeToFit
{
	[self resizeToFitWithPadding:0.0f minimumHeight:0.0f maximumHeight:0.0f];
}
-(void)resizeToFitWithPadding:(float)padding minimumHeight:(float)minimumHeight maximumHeight:(float)maximumHeight
{
//	CGSize myStringSize = [self.text sizeWithFont:self.font 
//								constrainedToSize:CGSizeMake(self.bounds.size.width, MAXFLOAT)
//									lineBreakMode:NSLineBreakByWordWrapping];
    //modify by lxc for ios7
	CGSize myStringSize = [self.text adjustSizeWithFont:self.font  constrainedToSize:CGSizeMake(self.bounds.size.width, MAXFLOAT)];
    
	float height = myStringSize.height + padding;
	if(minimumHeight > 0.0f && height < minimumHeight) {
		height = minimumHeight;
	}
	
	if(maximumHeight > 0.0f && height > maximumHeight) {
		height = maximumHeight;
	}
    
    CGRect newFrame = self.frame;
    newFrame.size = CGSizeMake(self.bounds.size.width, (height));
    [self setFrame:newFrame];
}

@end
