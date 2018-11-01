//
//  FFATPosition.h
//  BrcIot
//
//  Created by LiXiangCheng on 2018/10/29.
//  Copyright © 2018年 BRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFATPosition : NSObject

+ (instancetype)positionWithCount:(NSInteger)count index:(NSInteger)index;
- (instancetype)initWithCount:(NSInteger)count index:(NSInteger)index NS_DESIGNATED_INITIALIZER;

@property (nonatomic, assign, readonly) NSInteger count;
@property (nonatomic, assign, readonly) NSInteger index;
@property (nonatomic, assign) CGPoint center;
@property (nonatomic, assign) CGRect frame;

@end
