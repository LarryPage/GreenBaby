//
//  AppDelegate.m
//  Hunt
//
//  Created by LiXiangCheng on 14/12/1.
//  Copyright (c) 2014年 LiXiangCheng. All rights reserved.
//

#import "AppDelegate.h"
#import <Bugly/Bugly.h>
#import "ContactManager.h"
#import "LocationManager.h"
#import "NetworkCenter.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

+ (AppDelegate *)sharedAppDelegate
{
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}

- (id)init {
    self = [super init];
    if (self) {
        // 创建contactManager
        [ContactManager sharedInstance];
        // 创建Location manager
        //[LocationManager sharedInstance];
        // 创建Network center
        [NetworkCenter sharedInstance];
        // 注册LNNotificationCenter
        [[LNNotificationCenter defaultCenter] registerApplicationWithIdentifier:kBundleIdentifier name:kProductName icon:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationWasTapped:) name:LNNotificationWasTappedNotification object:nil];
        //系统信息初始化
        DeviceModel *device = [DeviceModel loadCurRecord];
        if (!device) {
            device = [[DeviceModel alloc] init];
            device.pushToken = @"";
            device.vid = [UIDevice imei];
            device.imei = [UIDevice imei];
            [DeviceModel saveCurRecord:device];
        }
        [self registerAPNS];
        //[self setupShortcutItems];
        
        //自定义UIWebView User-Agent
        //每个 UIWebView 实例的创建都会去读这个 UserAgent 的设置
        UIWebView* webView = [[UIWebView alloc] initWithFrame:CGRectZero];
        NSString* oldAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];//Mozilla/5.0 (iPhone; CPU iPhone OS 9_1 like Mac OS X) AppleWebKit/601.1.46 (KHTML, like Gecko) Mobile/13B137
        if (![oldAgent hasPrefix:@"GreenBaby_ios"]) {
            NSString *newAgent = [NSString stringWithFormat:@"GreenBaby_ios %@ %@",kVersion,oldAgent];
            NSDictionary *dictionary = @{@"UserAgent": newAgent};
            [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
        }
    }
    return self;
}

- (void)registerAPNS{
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge
                                                                                         |UIUserNotificationTypeSound
                                                                                         |UIUserNotificationTypeAlert) categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    if (![[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PushRegistNotification object:nil];
    }
}

- (void)setupShortcutItems{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
        UIApplication *app = [UIApplication sharedApplication];
        NSArray *existingShortcutItems = [app shortcutItems];
        
        UIApplicationShortcutIcon * photoIcon = [UIApplicationShortcutIcon iconWithTemplateImageName: @"ChatsAction"]; // your customize icon
        UIApplicationShortcutItem *item0 = [[UIApplicationShortcutItem alloc]initWithType: @"new_chat" localizedTitle: @"ShortcutTitleNewChat" localizedSubtitle: nil icon: photoIcon userInfo: nil];
        
        app.shortcutItems = @[item0];
    }
}

//设置一个 C 函数，用来接收崩溃信息
void UncaughtExceptionHandler(NSException *exception){
    //可以通过 exception 对象获取一些崩溃信息进行解析的，symbols 数组就是我们的崩溃堆栈。
    NSString *name = [exception name];
    NSString *reason = [exception reason];
    NSArray *symbols = [exception callStackSymbols];
    CLog(@"Exception:\n%@\n%@\n%@",name,reason,symbols);
    
    NSMutableString *crash = [NSMutableString string];
    [exception.callStackSymbols enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [crash appendFormat:@"\r%@", obj];
    }];
    NSString *crashText = [NSString base64encode:crash];
    int64_t time = (int64_t)[[NSDate date] timeIntervalSince1970] * 1000; //in ms
    NSString *crashPath = [kCachesFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"crash_%@_%lld", [UIDevice imei],time]];
    NSError *error;
    [crashText writeToFile:crashPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
    }
}

#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UserModel *user = [UserModel loadCurRecord];
    
    BaiduMobStat* statTracker = [BaiduMobStat defaultStat];
    statTracker.enableExceptionLog = NO; // 是否允许截获并发送崩溃信息，请设置YES或者NO
    statTracker.channelId = baiduMobStatChannelID;//设置您的app的发布渠道
    statTracker.logStrategy = BaiduMobStatLogStrategyAppLaunch;//根据开发者设定的时间间隔接口发送 也可以使用启动时发送策略
    statTracker.logSendInterval = 1;  //为1时表示发送日志的时间间隔为1小时
    statTracker.logSendWifiOnly = YES; //是否仅在WIfi情况下发送日志数据
    statTracker.sessionResumeInterval = 35;//设置应用进入后台再回到前台为同一次session的间隔时间[0~600s],超过600s则设为600s，默认为30s,测试时使用1S可以用来测试日志的发送。
    statTracker.shortAppVersion  = kVersion; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
    statTracker.enableDebugOn = NO; //打开sdk调试接口，会有log打印
    [statTracker startWithAppId:baiduMobStatAPPKey];//设置您在mtj网站上添加的app的appkey
    
    //将下面 C 函数的函数地址当做参数
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
    //zip压缩日志并上传崩溃日志
    //[self uploadCrashData];
    //http://bugly.qq.com 账号(QQ)：158096757
    [Bugly startWithAppId:@"900017417"];
    
#ifdef __LP64__   // __LP64__是GCC预定义宏, 64位时long是64位
#ifndef _SYS_TYPES_H    // sys/types.h中定义了_SYS_TYPES_H
    typedef long         int64_t;
#endif
    typedef unsigned long    uint64_t;
#else
#ifndef _SYS_TYPES_H    // sys/types.h中定义了_SYS_TYPES_H
    typedef long long    int64_t;
#endif
    typedef unsigned long long   uint64_t;
#endif
    
    /**  ShareSDK
     *  设置ShareSDK的appKey，如果尚未在ShareSDK官网注册过App，请移步到http://mob.com/login 登录后台进行应用注册，
     *  在将生成的AppKey传入到此方法中。
     *  方法中的第二个参数用于指定要使用哪些社交平台，以数组形式传入。第三个参数为需要连接社交平台SDK时触发，
     *  在此事件中写入连接代码。第四个参数则为配置本地社交平台时触发，根据返回的平台类型来配置平台信息。
     *  如果您使用的时服务端托管平台信息时，第二、四项参数可以传入nil，第三项参数则根据服务端托管平台来决定要连接的社交SDK。
     */
    [ShareSDK registerApp:ShareSDK_APP_KEY
          activePlatforms:@[
                            @(SSDKPlatformTypeSinaWeibo),
                            @(SSDKPlatformTypeTencentWeibo),
                            @(SSDKPlatformTypeMail),
                            @(SSDKPlatformTypeSMS),
                            @(SSDKPlatformTypeCopy),
                            @(SSDKPlatformTypeWechat),
                            @(SSDKPlatformTypeQQ),
                            @(SSDKPlatformTypeDouBan),
                            @(SSDKPlatformTypeRenren),
                            @(SSDKPlatformTypeKaixin)
                            ]
                 onImport:^(SSDKPlatformType platformType) {
                     
                     switch (platformType)
                     {
                         case SSDKPlatformTypeWechat:
                             [ShareSDKConnector connectWeChat:[WXApi class] delegate:self];
                             break;
                         case SSDKPlatformTypeQQ:
                             [ShareSDKConnector connectQQ:[QQApiInterface class]
                                        tencentOAuthClass:[TencentOAuth class]];
                             break;
                         case SSDKPlatformTypeSinaWeibo:
                             [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                             break;
                         case SSDKPlatformTypeRenren:
                             [ShareSDKConnector connectRenren:[RennClient class]];
                             break;
                         default:
                             break;
                     }
                     
                 }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
              
              switch (platformType)
              {
                  case SSDKPlatformTypeSinaWeibo:
                      //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权,注册的app所使用的Bundle ID和现在程序中运行的Bundle ID,否则不能用sso登陆
                      [appInfo SSDKSetupSinaWeiboByAppKey:@"244948476"
                                                appSecret:@"edb3252033258d8187dcd340bba86faa"
                                              redirectUri:@"http://sns.whalecloud.com/sina2/callback"
                                                 authType:SSDKAuthTypeBoth];
                      break;
                  case SSDKPlatformTypeTencentWeibo:
                      //设置腾讯微博应用信息，其中authType设置为只用Web形式授权
                      [appInfo SSDKSetupTencentWeiboByAppKey:@"801307650"
                                                   appSecret:@"ae36f4ee3946e1cbb98d6965b0b2ff5c"
                                                 redirectUri:@"http://www.sharesdk.cn"];
                      break;
                  case SSDKPlatformTypeWechat:
                      [appInfo SSDKSetupWeChatByAppId:@"wx49bc895bdb3ae540"
                                            appSecret:@"5aaba490an90b451ca624byfbcgd82ye"];
                      break;
                  case SSDKPlatformTypeQQ:
                      [appInfo SSDKSetupQQByAppId:@"100839155"
                                           appKey:@"321079098cfd2e21ab1240a2ff871ee7"
                                         authType:SSDKAuthTypeBoth];
                      break;
                  case SSDKPlatformTypeDouBan:
                      [appInfo SSDKSetupDouBanByApiKey:@"02e2cbe5ca06de5908a863b15e149b0b"
                                                secret:@"9f1e7b4f71304f2f"
                                           redirectUri:@"http://www.sharesdk.cn"];
                      break;
                  case SSDKPlatformTypeRenren:
                      [appInfo SSDKSetupRenRenByAppId:@"226427"
                                               appKey:@"fc5b8aed373c4c27a05b712acba0f8c3"
                                            secretKey:@"f29df781abdd4f49beca5a2194676ca4"
                                             authType:SSDKAuthTypeBoth];
                      break;
                  case SSDKPlatformTypeKaixin:
                      [appInfo SSDKSetupKaiXinByApiKey:@"358443394194887cee81ff5890870c7c"
                                             secretKey:@"da32179d859c016169f66d90b6db2a23"
                                           redirectUri:@"http://www.sharesdk.cn/"];
                      break;
                  default:
                      break;
              }
          }];
    
    //for ios7
//    BaseViewController *vc=(BaseViewController*)[_window topViewController];
//    vc.statusBarHidden=YES;
//    [vc updateStatusBar];
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //CLog(@"height:%f",KUIScreeHeight);
    //INLog(@"LocalizedString:%@",[Configs LocalizedString:@"SaveSuccessTitle"]);
    [self.window setBackgroundColor:DefaultWindowBgColor];
    //[window setBackgroundColor:[[UIColor alloc] initWithCGColor:[[UIColor colorWithPatternImage:[UIImage imageNamed:@"global_bg.png"]] CGColor]];
    
    //定义导航title和颜色
    [UINavigationBar appearance].barTintColor=DefaultNavbarTintColor;//the bar background
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:DefaultNavTitleColor, NSForegroundColorAttributeName, DefaultNavTitleFont, NSFontAttributeName, nil]];
    [UINavigationBar appearance].tintColor=DefaultNavTintColor;//left and right button text color
    UIBarButtonItem * barItemInNavigationBarAppearanceProxy = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil];
    [barItemInNavigationBarAppearanceProxy setTitleTextAttributes:[NSDictionary
                                                                   dictionaryWithObjectsAndKeys:DefaultNavBarButtonFont, NSFontAttributeName,nil] forState:UIControlStateNormal];
    
    //显示每个新版本向导
    BOOL showedGuidInVersion=[[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"showedGuidInVersion%@",kVersion]];
    if (!showedGuidInVersion) {
        UIViewController *vc = [[WelcomeViewController alloc] init];
        //UINavigationController *nc = [[NavRootViewController alloc] initWithRootViewController:vc];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
        nc.navigationBar.translucent = NO;
        self.window.rootViewController = nc;
    }
    else{
        if (user && user.user_id) {
            CustomTabBarController *mtabBarController = [[CustomTabBarController alloc] init];
            self.window.rootViewController = mtabBarController;
        } else {//登录/注册
            UIViewController *vc = [[StartViewController alloc] init];
            UINavigationController *nc = [[NavRootViewController alloc] initWithRootViewController:vc];
            //UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
            nc.navigationBar.translucent = NO;
            self.window.rootViewController = nc;
        }
    }
    
    [self.window makeKeyAndVisible];
    
    // 1.configRouteIMP
    [FFRouteManager addRouteImps:@[[FFRouteImp new]]];
    
    // 2.Handle local notification 定时本地通知
    UILocalNotification *localNotif = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif) {
        CLog(@"Recieved Local Notification %@",localNotif);
        
        _pushPayload=nil;
        NSString *u=localNotif.userInfo[@"u"];
        NSString *pushStr=@"";
        if (u && u.length>0) {
            pushStr=[NSString stringWithFormat:@"{\"aps\" : {\"alert\" : \"%@\", \"badge\" : \"1\", \"sound\" : \"default\"}, \"u\" : \"%@\"}",localNotif.alertBody,u];
        }
        else{
            pushStr=[NSString stringWithFormat:@"{\"aps\" : {\"alert\" : \"%@\", \"badge\" : \"1\", \"sound\" : \"default\"}}",localNotif.alertBody];
        }
        _pushPayload=[NSMutableDictionary dictionaryWithDictionary:[pushStr JSONValue]];
        [_pushPayload setValue:@"OpenApp" forKey:@"mode"];
        CLog(@"receive load push:%@", _pushPayload);
        // it will be handled in applicationDidBecomeActive
    }
    
    // 3.apple push notification 远程通知
    NSDictionary *aps = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(aps) {
        _pushPayload=nil;
        _pushPayload = [NSMutableDictionary dictionaryWithDictionary:aps];
        [_pushPayload setValue:@"OpenApp" forKey:@"mode"];
        // it will be handled in applicationDidBecomeActive
    }
    
    //4.ShortcutItem
    UIApplicationShortcutItem *shortcutItem = [launchOptions objectForKey:UIApplicationLaunchOptionsShortcutItemKey];
    if(shortcutItem){
        [self handleShortCutItem:shortcutItem];
    }
    
    //5.InHouse版本
    if ([kBundleIdentifier isEqualToString:@"com.dianshang.wanhui.InHouse"]) {
        [API appVersionCheckOnCompletion:^(NSError *error,id response){
            if (!error) {
                NSDictionary *dateDic = response;
                if (dateDic && [dateDic isKindOfClass:[NSDictionary class]]) {
                    if (dateDic.count>0) {
                        NSString *version=dateDic[@"version"];
                        NSString *description=dateDic[@"update_info"];
                        NSInteger force_update=[dateDic[@"force_update"] integerValue];
                        
                        if ([kBuildVersion integerValue]<[version integerValue]) {
                            [UIAlertController showWithTitle:@"版本升级"
                                                     message:description
                                           cancelButtonTitle:force_update?nil:@"下次再说"
                                           defultButtonTitle:@"立即更新"
                                      destructiveButtonTitle:nil
                                                    onCancel:^(UIAlertAction *action) {
                                                    }
                                                    onDefult:^(UIAlertAction *action) {
                                                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/ren-ren-lie-tou/id558470197?mt=8"]];
                                                    }
                                               onDestructive:nil];
                        }
                    }
                    else{
                        CLog(@"版本检查完成，没有可更新的版本。");
                    }
                }
            }
            else{//code>0
                [[TKAlertCenter defaultCenter] postAlertWithMessage:error.domain];
            }
        }];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //大概5s的时间处理要完成的任务,若需要长时间运行任务，如下
    //[application beginBackgroundTaskWithExpirationHandler:^{
    //    CLog(@"begin Background Task With Expiration Handler");
    //}];
    if([[self.window topViewController] isKindOfClass:[BaseViewController class]]) {
        BaseViewController *curVC=(BaseViewController *)[self.window topViewController];
        [curVC pageviewEnd];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if([[self.window topViewController] isKindOfClass:[BaseViewController class]]) {
        BaseViewController *curVC=(BaseViewController *)[self.window topViewController];
        [curVC pageviewStart];
    }
    //如还没有注册APN获取通知DeviceToken，进行注册
    DeviceModel *device = [DeviceModel loadCurRecord];
    if (device.pushToken.length <= 1) {
        [self registerAPNS];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[NetworkCenter sharedInstance] performSelectorInBackground:@selector(appActive) withObject:nil];
    //[[NetworkCenter sharedInstance] performSelectorInBackground:@selector(startUploadQueue) withObject:nil];
    
    // 处理推送信息
    if(_pushPayload) {
        [self performSelector:@selector(handlePushPayload) withObject:nil afterDelay:0.0];
    }
    
    //测试push notification
    //[self performSelector:@selector(handlePushPayload) withObject:nil afterDelay:0.0];
    
    //1.不管用户是否点通知,不点通知时pushPayload＝nil，都将app icon's badge 置为0
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    //2.后台每隔１天取得推送信息
//    NSDate *curDate = [NSDate date];
//    NSDate *lastDate = (NSDate *)[[NSUserDefaults standardUserDefaults] objectForKey:@"lastDate"];
//    if (!lastDate) {
//        lastDate=[NSDate date];
//
//        [[NSUserDefaults standardUserDefaults] setObject:curDate forKey:@"lastDate"];// 保存到本地 //Library/Preferences/com.jishike.mppp.plist
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
//    //比较两个日期间的天数：
//    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//    unsigned int unitFlags =NSDayCalendarUnit;
//    NSDateComponents *comps = [gregorian components:unitFlags fromDate:lastDate toDate:curDate options:0];
//    int days = [comps day];
//    if (days>0) {//１天之外
//        [[NSUserDefaults standardUserDefaults] setObject:curDate forKey:@"lastDate"];// 保存到本地 //Library/Preferences/com.jishike.mppp.plist
//        [[NSUserDefaults standardUserDefaults] synchronize];
//
//        [[NetworkCenter sharedInstance] performSelectorInBackground:@selector(sumSubscrible) withObject:nil];
//    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    //这个方法有5s的限制
    [[ContactManager sharedInstance] stopThread];
}

#ifdef __IPHONE_8_0
- (BOOL)application:(nonnull UIApplication *)application continueUserActivity:(nonnull NSUserActivity *)userActivity restorationHandler:(nonnull void (^)(NSArray * _Nullable))restorationHandler {
    NSString *itemID = userActivity.userInfo[@"kCSSearchableItemActivityIdentifier"];
    CLog(@"根据[itemID:%@]跳转",itemID);
    return YES;
}
#endif

#ifdef __IPHONE_9_0
- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void(^)(BOOL succeeded))completionHandler {
    [self handleShortCutItem:shortcutItem];
}
#endif

#pragma mark handleOpenURL

// 处理url
- (void)handleUrl:(NSURL *)url title:(NSString *)title{
    if ([FFRouteManager supportSchemeURL:url]) {//是否支持Scheme跳转
        if([FFRouteManager canRouteURL:url]){
            [FFRouteManager routeURL:url];
        }
        else{
            [FFRouteManager routeReduceURL:url];
        }
    }
    else if ([FFRouteManager isHttpURL:url]){//是否是http,https开口的url
        BaseViewController *curVC=(BaseViewController *)[self.window topViewController];
        
        NSDictionary *params=[[url query] queryDictionaryUsingEncoding:NSUTF8StringEncoding];
        WebViewController *vc = [[WebViewController alloc]initWithUrl:[url absoluteString] title:title];
        vc.navBarHidden=[params[@"hide_navbar"] integerValue];
        vc.hidesBottomBarWhenPushed=YES;
        [curVC.navigationController pushViewController:vc animated:YES];
    }
    else{
        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"不合法的连接!"];
    }
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    CLog(@"source app-%@, des app-%@",sourceApplication,application);
    
    if ([sourceApplication isEqualToString:@"com.tencent.mqq"]) {
        return [TencentOAuth HandleOpenURL:url];
    }
    else if ([sourceApplication isEqualToString:@"com.tencent.xin"]) {
        return [WXApi handleOpenURL:url delegate:self];
    }
    else if ([sourceApplication isEqualToString:@"com.alipay.safepayclient"] || [sourceApplication isEqualToString:@"com.alipay.iphoneclient"]) {
        //如果极简开发包不可用,会跳转支付宝钱包进行支付,需要将支付宝钱包的支付结果回传给开发包
        if ([url.host isEqualToString:@"safepay"]) {
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url
                                                      standbyCallback:^(NSDictionary *resultDic) {
                                                          NSInteger resultStatus=[resultDic[@"resultStatus"] integerValue];
                                                          NSInteger pay_status=1;//"pay_status": //0，成功；1, 失败；2，取消；3，支付中
                                                          switch (resultStatus) {
                                                              case 9000:
                                                                  pay_status=0;
                                                                  CLog(@"订单支付成功:reslut = %@",resultDic);
                                                                  break;
                                                              case 6001:
                                                                  pay_status=2;
                                                                  CLog(@"用户中途取消:reslut = %@",resultDic);
                                                                  break;
                                                              case 6002:
                                                                  pay_status=2;
                                                                  CLog(@"网络连接出错:reslut = %@",resultDic);
                                                                  break;
                                                              case 4000:
                                                                  pay_status=1;
                                                                  CLog(@"订单支付失败:reslut = %@",resultDic);
                                                                  break;
                                                              /*
                                                               case 8000:
                                                               pay_status=3;
                                                               CLog(@"正在处理中:reslut = %@",resultDic);
                                                               break;
                                                               */
                                                              default:
                                                                  CLog(@"reslut = %@",resultDic);
                                                                  //[[TKAlertCenter defaultCenter] postAlertWithMessage:resultDic[@"memo"]];
                                                                  [[TKAlertCenter defaultCenter] postAlertWithMessage:@"支付失败!"];
                                                                  break;
                                                          }
                                                          //发出消息
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_ALIPAY object:@(pay_status) userInfo:nil];
                                                      }];
        }
        if ([url.host isEqualToString:@"platformapi"]){//支付宝钱包快登授权返回 authCode
            [[AlipaySDK defaultService] processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
                CLog(@"result = %@",resultDic);
                //发出消息
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_ALIPAY object:nil userInfo:nil];
            }];
        }
        return YES;
    }
    else if ([FFRouteManager supportSchemeURL:url]) {//APPOutScheme:外部跳转Scheme
        if([FFRouteManager canRouteURL:url]){
            [FFRouteManager routeURL: url];
        }
        else{
            [FFRouteManager routeReduceURL:url];
        }
        return YES;
    }
    
    return YES;
}

#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

#pragma mark Apple Local Notification methods
// 1.Handle local notification 定时本地通知

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)localNotif {
    // Handle the notificaton when the app is running
    if (localNotif) {
        CLog(@"Recieved Local Notification %@",localNotif);
        
        _pushPayload=nil;
        NSString *u=localNotif.userInfo[@"u"];
        NSString *pushStr=@"";
        if (u && u.length>0) {
            pushStr=[NSString stringWithFormat:@"{\"aps\" : {\"alert\" : \"%@\", \"badge\" : \"1\", \"sound\" : \"default\"}, \"u\" : \"%@\"}",localNotif.alertBody,u];
        }
        else{
            pushStr=[NSString stringWithFormat:@"{\"aps\" : {\"alert\" : \"%@\", \"badge\" : \"1\", \"sound\" : \"default\"}}",localNotif.alertBody];
        }
        _pushPayload=[NSMutableDictionary dictionaryWithDictionary:[pushStr JSONValue]];
        [_pushPayload setValue:@"WakeApp" forKey:@"mode"];
        CLog(@"receive load push:%@", _pushPayload);
        
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            [self performSelector:@selector(handlePushPayload) withObject:nil afterDelay:0.0];
        } else {
            // it will be handled in applicationDidBecomeActive
        }
    }
}

#pragma mark Apple Push Notification methods
// 2.apple push notification 远程通知

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    //register to receive Remote notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application
handleActionWithIdentifier:(NSString *)identifier
forLocalNotification:(UILocalNotification *)notification
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
  completionHandler:(void (^)())completionHandler
#pragma clang diagnostic pop
{
    //handle the actions
    if ([identifier isEqualToString:@"declineAction"]){
    }
    else if ([identifier isEqualToString:@"answerAction"]){
    }
}
#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)pToken {
    NSString *str = [[[pToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<> "]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    CLog(@"regisger push:%@", str);
    
    DeviceModel *device = [DeviceModel loadCurRecord];
    device.pushToken = str;
    [DeviceModel saveCurRecord:device];
    [[NSNotificationCenter defaultCenter] postNotificationName:PushRegistNotification object:nil];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    CLog(@"fail to register push: %@", error);
    
    DeviceModel *device = [DeviceModel loadCurRecord];
    device.pushToken = @"";
    [DeviceModel saveCurRecord:device];
    [[NSNotificationCenter defaultCenter] postNotificationName:PushRegistNotification object:nil];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    CLog(@"receive push:%@", userInfo);
    _pushPayload=nil;
    _pushPayload = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        [_pushPayload setValue:@"InApp" forKey:@"mode"];
        [self performSelector:@selector(handlePushPayload) withObject:nil afterDelay:0.0];
        
        //app运行中收到消息进行提示
//        if (_pushPayload) {
//            NSDictionary *apsDic=[_pushPayload valueForKey:@"aps"];
//            [UIAlertController alert:[apsDic valueForKey:@"alert"] title:nil bTitle:@"确定"];
//        }
        
        //声音提示 1012 -iphone   1152 ipad  1109 ipad
        //AudioServicesPlaySystemSound(1012);
    } else {
        [_pushPayload setValue:@"WakeApp" forKey:@"mode"];
        // it will be handled in applicationDidBecomeActive
    }
}

// 处理推送信息,mode:三个值：OpenApp,InApp,WakeApp
// OpenApp:app没运行时，从消息列表打开app
// InApp:在app运行时收到消息
// WakeApp:app在后台，从消息列表唤醒app
//推送:http://phab.51meilin.com/w/开发文档/app/推送/
- (void)handlePushPayload{
    //测试push notification
//    _pushPayload=nil;
//    NSString *pushStr=@"{\"aps\" : {\"alert\" : \"你的订阅有新的５个职位 \ue415 \", \"badge\" : \"1\", \"sound\" : \"default\"}, \"m\" : \"1" , \"u\" : \"greenbaby://huijiame.com/activity\"}";//有表情
//    _pushPayload=[NSMutableDictionary dictionaryWithDictionary:[pushStr JSONValue]];
//    CLog(@"receive Test push:%@", _pushPayload);
    /*
     aps =     {
     alert = "\U56de\U5bb6\U4e48";
     badge = 1;
     sound = default;
     };
     "m" : "1";
     "u" : "greenbaby://huijiame.com/activity";
     ...
     */
    
    if (_pushPayload) {
        NSDictionary *apsDic=_pushPayload[@"aps"];
        [[NSNotificationCenter defaultCenter] postNotificationName:MessageReceiveCount object:nil userInfo:nil];
//        if (apsDic) {
//            NSString *alertTitle=apsDic[@"alert"];
//            CLog(@"push alertTitle[1]:%@", alertTitle);
//        }
        
        NSString *m=_pushPayload[@"m"];//消息 id
        NSString *u=_pushPayload[@"u"];//route url
        
        UserModel *user = [UserModel loadCurRecord];
        if (user && user.user_id) {//已登录
            if (u && u.length>0) {
                NSString *mode=[_pushPayload valueForKey:@"mode"];
                if ([mode isEqualToString:@"OpenApp"] || [mode isEqualToString:@"WakeApp"]) {//OpenApp && WakeApp
                    [self handleUrl:[NSURL URLWithString:u] title:[apsDic valueForKey:@"alert"]];
                }
                else{//InApp
                }
                
                _pushPayload = nil;
            }
            else if (m && m.length>0) {
                switch ([m integerValue]) {
                    case 0://0--职位订阅
                    {
                        if (![UIApplication sharedApplication].statusBarHidden) {
                            LNNotification* notification = [LNNotification notificationWithMessage:apsDic[@"alert"]];
                            [[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:kBundleIdentifier];
                        }
                        
                        //声音提示 1012 -iphone   1152 ipad  1109 ipad
                        AudioServicesPlaySystemSound(1012);
                        
                        if ([[AppDelegate sharedAppDelegate].window.rootViewController isKindOfClass:[CustomTabBarController class]]) {
                            CustomTabBarController *mtabBarController = (CustomTabBarController *)[AppDelegate sharedAppDelegate].window.rootViewController;
                            
                            [mtabBarController.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                UINavigationController* nc = (UINavigationController*)obj;
                                [nc popToRootViewControllerAnimated:NO];
                            }];
                            
                            mtabBarController.selectedIndex=0;
                            //[[mtabBarController.tabBar.items objectAtIndex:1] setBadgeValue:@"1"];
                            //[mtabBarController addTabBarBadge:type];
                        }
                        
                        _pushPayload = nil;
                        break;
                    }
                    case 1://1--系统网址消息
                    {
                        NSURL *url=[NSURL URLWithString:u];
                        
                        //[[UIApplication sharedApplication] openURL:url];
                        UIViewController *vc=[self.window topViewController];
                        SVWebViewController *sv = [[SVWebViewController alloc] initWithURL:url];
                        [sv setTitle:url.baseString];
                        sv.hidesBottomBarWhenPushed=YES;
                        [vc.navigationController pushViewController:sv animated:YES];
                        
                        _pushPayload = nil;
                        break;
                    }
                    case 20://20--好友聊天信息
                    {
                        NSString *mode=[_pushPayload valueForKey:@"mode"];
                        if ([mode isEqualToString:@"OpenApp"] || [mode isEqualToString:@"WakeApp"]) {//OpenApp && WakeApp
                            if ([[AppDelegate sharedAppDelegate].window.rootViewController isKindOfClass:[CustomTabBarController class]]) {
                                CustomTabBarController *mtabBarController = (CustomTabBarController *)[AppDelegate sharedAppDelegate].window.rootViewController;
                                
                                [mtabBarController.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                    UINavigationController* nc = (UINavigationController*)obj;
                                    [nc popToRootViewControllerAnimated:NO];
                                }];
                                
                                mtabBarController.selectedIndex=1;
                                //[[mtabBarController.tabBar.items objectAtIndex:1] setBadgeValue:@"1"];
                                //[mtabBarController addTabBarBadge:type];
                            }
                        }
                        else{//InApp
//                            UIViewController *vc=[self.window topViewController];
//                            if ([vc isKindOfClass:[FriendTalkViewController class]]) {
//                                //正在对话
//                            }
//                            else{
//                                if (![UIApplication sharedApplication].statusBarHidden) {
//                                    LNNotification* notification = [LNNotification notificationWithMessage:apsDic[@"alert"]];
//                                    [[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:kBundleIdentifier];
//                                }
//                                
//                                //声音提示 1012 -iphone   1152 ipad  1109 ipad
//                                AudioServicesPlaySystemSound(1012);
//                            }
                        }
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:MessageReceiveCount object:nil userInfo:nil];
                        
                        _pushPayload = nil;
                        break;
                    }
                    default:
                    {
                        if (![UIApplication sharedApplication].statusBarHidden) {
                            LNNotification* notification = [LNNotification notificationWithMessage:apsDic[@"alert"]];
                            [[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:kBundleIdentifier];
                        }
                        
                        NSString *soundName=RKMapping([apsDic valueForKey:@"sound"]);
                        if (![soundName isEqualToString:@"(null)"]) {
                            //声音提示 1012 -iphone   1152 ipad  1109 ipad
                            AudioServicesPlaySystemSound(1012);
                        }
                        
                        _pushPayload = nil;
                        break;
                    }
                }
            }
            else{//环信消息，没有params
                NSString *mode=[_pushPayload valueForKey:@"mode"];
                if ([mode isEqualToString:@"OpenApp"] || [mode isEqualToString:@"WakeApp"]) {//OpenApp && WakeApp
                    if ([[AppDelegate sharedAppDelegate].window.rootViewController isKindOfClass:[CustomTabBarController class]]) {
                        CustomTabBarController *mtabBarController = (CustomTabBarController *)[AppDelegate sharedAppDelegate].window.rootViewController;
                        
//                        [mtabBarController.viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                            UINavigationController* nc = (UINavigationController*)obj;
//                            [nc popToRootViewControllerAnimated:NO];
//                        }];
                        
                        mtabBarController.selectedIndex=1;
                        //[[mtabBarController.tabBar.items objectAtIndex:1] setBadgeValue:@"1"];
                        //[mtabBarController addTabBarBadge:type];
                    }
                }
                else{//InApp
                }
                
                _pushPayload = nil;
            }

        }
        else{//未登录
            UIViewController *vc = [[StartViewController alloc] init];
            //MLNavigationController *nc = [[MLNavigationController alloc] initWithRootViewController:vc];
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
            nc.navigationBar.translucent = NO;
            self.window.rootViewController = nc;
            
            _pushPayload = nil;
        }
    }
}

- (void)handleShortCutItem:(UIApplicationShortcutItem *)shortcutItem  {
    if([shortcutItem.type isEqualToString:@"new_chat"]){
    }
    else if([shortcutItem.type isEqualToString:@"myqrcode"]){
    }
}

- (void)killApp{
    //home button press programmatically
    UIApplication *app = [UIApplication sharedApplication];
    [app performSelector:@selector(suspend)];
    
    //wait 2 seconds while app is going background
    [NSThread sleepForTimeInterval:2.0];
    
    //exit app when app is in background
    exit(0);
}

#pragma mark LNNotificationCenter

- (void)notificationWasTapped:(NSNotification*)notification{
    LNNotification* tappedNotification = notification.object;
    [UIAlertController alert:tappedNotification.message title:tappedNotification.title bTitle:@"确定"];
}

#pragma mark - WXApiDelegate

-(void) onReq:(BaseReq*)req{
}

-(void) onResp:(BaseResp*)resp{
    CLog(@"%@",resp);
    
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        switch (resp.errCode) {
            case WXSuccess://用户同意
                [[NSNotificationCenter defaultCenter]postNotificationName:KNOTIFICATION_WECHAT_LOGIN_AUTHRESP
                                                                   object:((SendAuthResp *)resp).code];
                break;
            case WXErrCodeUserCancel:
                [[TKAlertCenter defaultCenter] postAlertWithMessage:@"用户取消!"];
                break;
            case WXErrCodeAuthDeny:
                [[TKAlertCenter defaultCenter] postAlertWithMessage:@"用户拒绝授权!"];
                break;
            default:
                break;
        }
    }
    else if([resp isKindOfClass:[SendMessageToWXResp class]]) {
    }
    else if ([resp isKindOfClass:[PayResp class]]) {
        PayResp *response = (PayResp *)resp;
        NSInteger pay_status=1;//"pay_status": //0，成功；1, 失败；2，取消；3，支付中
        switch (response.errCode) {
            case WXSuccess:
            {
                pay_status=0;
                //支付成功；
                //注意由客户端返回的支付结果不能作为最终支付的可信结果,应以服务器端的支付结果通知为准
            }
                break;
            case WXErrCodeUserCancel:
            {
                pay_status=2;
                //放弃支付；
                //注意由客户端返回的支付结果不能作为最终支付的可信结果,应以服务器端的支付结果通知为准
            }
                break;
            default:
            {
                //支付失败；
                [[TKAlertCenter defaultCenter] postAlertWithMessage:@"支付失败!"];
            }
                break;
        }
        //发出消息
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_WXPAY object:@(pay_status) userInfo:nil];
    }
}

@end
