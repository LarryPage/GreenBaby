//
//  NetworkCenter.h
//  RRLT
//
//  Created by LiXiangCheng on 15/4/9.
//  Copyright (c) 2015年 MeiLin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceModel.h"
#import "UserModel.h"
#import <AudioToolbox/AudioToolbox.h>

#import "CityModel.h"
#import "RegionModel.h"

@interface NetworkCenter : NSObject

@property (nonatomic, assign) Boolean bUploading;//是否正在上传

SINGLETON_DEF(NetworkCenter)

-(NSString *)getRequestUserAgent;//获取请求代理
-(NSString *)getSessionid;//获取每次启动sessionid

- (void)appActive;//app启动后台要执行的进程
- (void)getPublicData;//所有枚举类型
- (void)getMessageCount;//获取各种消息数
- (void)setSearchableIndex;//设置搜索

- (void)startUploadQueue;

@end
