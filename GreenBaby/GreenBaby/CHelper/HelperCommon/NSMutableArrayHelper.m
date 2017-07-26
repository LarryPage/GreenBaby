//
//  NSMutableArrayHelper.m
//  CardBump
//
//  Created by sbtjfdn on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSMutableArrayHelper.h"

@implementation NSMutableArray (randomized)
- (NSArray *) randomizedArray {  
    NSMutableArray *results = [NSMutableArray arrayWithArray:self];  
    
    NSUInteger i = [results count];
    while(--i > 0) {  
        int j = rand() % (i+1);  
        [results exchangeObjectAtIndex:i withObjectAtIndex:j];  
    }  
    
    return results;  
}
@end

@implementation NSMutableArray (AddALAsset)
- (void)addALAsset:(ALAsset *)newAsset
{
    if (self.count == 0) {
        [self addObject:newAsset];
    } else {
        BOOL insertSuccess = FALSE;
        for (NSInteger i = 0; i < self.count; ++i) {
            NSDate *current = (NSDate *)[[self objectAtIndex:i] valueForProperty:ALAssetPropertyDate];
            NSDate *new = (NSDate *)[newAsset valueForProperty:ALAssetPropertyDate];
            if ([new compare:current] == NSOrderedDescending) {
                insertSuccess = TRUE;
                [self insertObject:newAsset atIndex:i];
                break;
            }
        }
        if (!insertSuccess) {
            [self insertObject:newAsset atIndex:self.count];
        }
    }
}
@end
