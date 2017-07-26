//
//  NSMutableArrayHelper.h
//  CardBump
//
//  Created by sbtjfdn on 12-5-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (randomized)
- (NSMutableArray *) randomizedArray;//NSMutableArray随机排序
@end

#import <AssetsLibrary/AssetsLibrary.h>
@interface NSMutableArray (AddALAsset)
-(void)addALAsset:(ALAsset *)asset;
@end
