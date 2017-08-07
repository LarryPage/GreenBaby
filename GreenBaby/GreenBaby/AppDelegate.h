//
//  AppDelegate.h
//  Hunt
//
//  Created by LiXiangCheng on 14/12/1.
//  Copyright (c) 2014年 LiXiangCheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

//Share SDK V3.1.4
//lxc 修改/zbar-146b857ff41a/zbar/symbol.c，注解，原因，ShareSDK 分享到手机QQ的framework也有些方法
//＝＝＝＝＝＝＝＝＝＝ShareSDK＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
//以下是ShareSDK必须添加的依赖库：
//1、libicucore.dylib
//2、libz.dylib
//3、libstdc++.dylib
//4、JavaScriptCore.framework

//腾讯开放平台（对应QQ和QQ空间）SDK头文件
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
//以下是腾讯SDK的依赖库：
//libsqlite3.dylib

//微信SDK头文件
#import "WXApi.h"
//以下是微信SDK的依赖库：
//libsqlite3.dylib

//新浪微博SDK头文件
#import "WeiboSDK.h"
//新浪微博SDK需要在项目Build Settings中的Other Linker Flags添加"-ObjC"
//以下是新浪微博SDK的依赖库：
//ImageIO.framework
//libsqlite3.dylib
//AdSupport.framework

//人人SDK头文件
#import <RennSDK/RennSDK.h>

#import <MOBFoundation/MOBFoundation.h>
//＝＝＝＝＝＝＝＝＝＝ShareSDK＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝

#import "SystemInfo.h"
#import "UserInfo.h"
#import "WelcomeViewController.h"
#import "StartViewController.h"
#import "CustomTabBarController.h"
#import "WebViewController.h"
#import "FFCommonRouteImp.h"

#define PushRegistNotification      @"PushRegistNotification"//注册远程通知DeviceToken

@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate,UIAlertViewDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) NSMutableDictionary *pushPayload;// apple push notification payload

+ (AppDelegate *)sharedAppDelegate;

//记录每个页面
@property (nonatomic, strong) NSString *p_pid;//前一个页面ID
@property (nonatomic, strong) NSString *pid;//当前页面ID
@property (nonatomic, assign) long long timestamp;//进入页面时间

- (void)handlePushPayload;// 处理推送信息
- (void)handleUrl:(NSURL *)url title:(NSString *)title;// 处理url
- (void)killApp;
@end

