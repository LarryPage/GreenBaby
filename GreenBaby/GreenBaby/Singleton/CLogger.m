//
//  CLogger.m
//  BrcIot
//
//  Created by LiXiangCheng on 2018/10/29.
//  Copyright © 2018年 BRC. All rights reserved.
//

#import "CLogger.h"

@interface CLogger ()
@property (nonatomic, assign) NSUInteger maxLogCount;
@end

@implementation CLogger

SINGLETON_IMP(CLogger)

- (id)init{
    self = [super init];
    if (self) {
        // Initialization code here.
        self.maxLogCount=1000;
        self.logList=[NSMutableArray array];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Action

-(void)addLog:(CLogModel *)log{
    if(self.logList.count>=self.maxLogCount){
        [self.logList removeObjectAtIndex:self.maxLogCount];
    }
    else{
        [self.logList insertObject:log atIndex:0];
    }
}

-(void)addLogMsg:(NSString *)msg
            file:(NSString *)file
        function:(NSString *)function
            line:(NSUInteger)line{
    NSDate *time=[NSDate date];
    
    DeviceModel *device = [DeviceModel loadCurRecord];
    if (device.isShowAssistiveTouch) {
        CLogModel *log=[[CLogModel alloc] init];
        log.time=time;
        log.msg=msg;
        log.file=file;
        log.fileName=file.lastPathComponent;
        log.function=function;
        log.line=line;
        [self addLog:log];
    }
    
#ifdef DEBUG
    printf("[%s] %s [第%lu行] %s\n", [[time formattedDateWithFormatString:@"MM-dd HH:mm:ss.SSS"] UTF8String], [function UTF8String], (unsigned long)line, [msg UTF8String]);
#endif
}

@end
