//
//  CLogger.h
//  BrcIot
//
//  Created by LiXiangCheng on 2018/10/29.
//  Copyright © 2018年 BRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLogModel.h"

@interface CLogger : NSObject

@property (nonatomic,strong) NSMutableArray <CLogModel *>*logList;//日志列表

SINGLETON_DEF(CLogger)

-(void)addLog:(CLogModel *)log;
-(void)addLogMsg:(NSString *)msg
            file:(NSString *)file
        function:(NSString *)function
            line:(NSUInteger)line;

@end
