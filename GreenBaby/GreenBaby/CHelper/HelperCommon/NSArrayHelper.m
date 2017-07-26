

#import "NSArrayHelper.h"


@implementation NSArray (randomized)  
- (NSArray *) randomizedArray {  
    NSMutableArray *results = [NSMutableArray arrayWithArray:self];  
    
    NSUInteger i = [results count];
    while(--i > 0) {  
        int j = rand() % (i+1);  
        [results exchangeObjectAtIndex:i withObjectAtIndex:j];  
    }  
    
    return [NSArray arrayWithArray:results];  
}  
@end 
