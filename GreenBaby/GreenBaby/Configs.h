//
//  Configs.h
//  BBPush
//
//  Created by Li XiangCheng on 13-3-10.
//  Copyright (c) 2013年 Li XiangCheng. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *FileServer;

extern NSString *baiduMobStatAPPKey;
extern NSString *baiduMobStatChannelID;

extern NSString *weixinAppID;
extern NSString *weixinAppKey;

extern NSString *SINA_APP_KEY;
extern NSString *SINA_APP_SECRET;

extern NSString *Tencent_APP_KEY;
extern NSString *Tencent_APP_SECRET;

extern NSString *TencentOpen_APP_KEY;
extern NSString *TencentOpen_APP_SECRET;

extern NSString *LinkedIn_APP_KEY;
extern NSString *LinkedIn_APP_SECRET;

extern NSString *Rerren_APP_KEY;
extern NSString *Rerren_APP_SECRET;

extern NSString *ShareSDK_APP_KEY;

/*
 Qiniu app key id & Bucket Name
 https://portal.qiniu.com 七牛账号
 sbtjfdn@gmail.com
 565923
 */
extern NSString *QiniuAccessKey;
extern NSString *QiniuSecretKey;
extern NSString *QiniuBucketNameImg;

// AppMacro
//0-develop版本:http://dev.api.huijiame.com
//1-sit版本:http://sit.api.huijiame.com
//2-product版本:http://api.huijiame.com
#define kAPIList [NSArray arrayWithObjects:@"http://dev.api.huijiame.com",@"http://sit.api.huijiame.com",@"http://api.huijiame.com",nil]
#define kGender [NSArray arrayWithObjects:@"女",@"男",@"保密",nil]
#define kShareImageNames [NSArray arrayWithObjects:@"weixin",@"pengyouquan",@"qq",@"qqspace",@"qqweibo",@"weibo",@"douban",@"renren",@"kaixin",@"qqpengyou",nil]
#define kShareTitles [NSArray arrayWithObjects:@"微信好友",@"微信朋友圈",@"QQ",@"QQ空间",@"腾讯微博",@"新浪微博",@"豆瓣",@"人人网",@"开心网",@"腾讯朋友",nil]

// NotificationMacro
#define MessageReceiveCount @"MessageReceiveCount"//收到消息数
#define MessageDidReceive   @"MessageDidReceive"//对话消息
#define UpdateOrder         @"UpdateOrder"  //更改订单状态

#define KNOTIFICATION_WECHAT_LOGIN_AUTHRESP  @"Wechat_Login_authresp"//微信认证通知
#define KNOTIFICATION_WXPAY @"WxPayResult"//WX支付通知
#define KNOTIFICATION_ALIPAY @"AliPayResult"//Ali支付通知
#define KNOTIFICATION_LOGINCHANGE @"loginStateChange"//环信通知


@interface Configs : NSObject

+ (NSLocale*) CurrentLocale;
+ (NSString*) LocalizedString:(NSString*)key;

+ (NSString*) documentPath;
+ (NSString*) PathForBundleResource:(NSString*) relativePath;
+ (NSString*) PathForDocumentsResource:(NSString*) relativePath;

+ (NSDictionary *)faceMap;//表情字典

#pragma mark - memoryDB and files
+ (NSString*)DeviceModelCurRecordPlistPath;
+ (NSString*)UserModelCurRecordPlistPath;
+ (NSString*)CityModelRecordPlistPath;
+ (NSString*)RegionModelRecordPlistPath;
+ (NSString*)MessageModelRecordPlistPath;

#pragma mark - memoryDB and sqlite3
+ (NSString*)dbPath;

+ (NSString*)DeviceModelCurRecordTableName;
+ (NSString*)UserModelCurRecordTableName;
+ (NSString*)CityModelRecordTableName;
+ (NSString*)RegionModelRecordTableName;
+ (NSString*)MessageModelRecordTableName;

@end
