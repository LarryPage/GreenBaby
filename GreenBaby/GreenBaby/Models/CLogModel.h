//
//  CLogModel.h
//  BrcIot
//
//  Created by LiXiangCheng on 2018/10/30.
//  Copyright © 2018年 BRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@JSONInterface(CLogModel) : NSObject

@property (nonatomic, strong) NSDate *time;
@property (nonatomic, strong) NSString *msg;
@property (nonatomic, strong) NSString *file;//__FILE__
@property (nonatomic, strong) NSString *function;//__PRETTY_FUNCTION__
@property (nonatomic, assign) NSUInteger line;//__LINE__
@property (nonatomic, strong) NSString *fileName;

@property (nonatomic, assign) BOOL bExpand;

@end
