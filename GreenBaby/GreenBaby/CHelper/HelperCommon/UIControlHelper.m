#import "UIControlHelper.h"

@implementation UIControl (Helper)

-(void)removeAllTargets
{
//	for ( id i_target in [self allTargets] )
//	{
//		[self removeTarget:i_target action:NULL forControlEvents:UIControlEventAllEvents];
//	}
    [self removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents]; 
}

@end
