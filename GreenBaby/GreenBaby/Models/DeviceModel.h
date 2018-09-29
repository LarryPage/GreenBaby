//
//  DeviceModel.h
//  EHome
//
//  Created by LiXiangCheng on 15/7/28.
//  Copyright (c) 2015年 LiXiangCheng. All rights reserved.
//

#import <Foundation/Foundation.h>

@JSONInterface(DeviceModel) : NSObject

@property (nonatomic, strong) NSString *vid; //visit id,访客Id(设备imei)
@property (nonatomic, strong) NSString *imei; //唯一识别id
@property (nonatomic, strong) NSString *pushToken;  //APNS推送的pushtoken
@property (nonatomic, assign) NSInteger push_status;//推送是否关闭
@property (nonatomic, assign) double lon;
@property (nonatomic, assign) double lat;
@property (nonatomic, assign) NSInteger isShowDebug;  //是否在系统设置中显示开发设置 默认 0
@property (nonatomic, assign) NSInteger apiEnv;  //api环境 0-develop 1-sit 2-product 默认 0 

@property (nonatomic, strong) NSString *welcome_img;  //欢迎图

@property (nonatomic, strong) NSString *my_order_url;  //我的订单链接
@property (nonatomic, strong) NSString *my_wallet_url;  //我的钱包链接

@end
