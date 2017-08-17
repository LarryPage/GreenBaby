//
//  NetworkCenter.m
//  CardBump
//
//  Created by 香成 李 on 12-1-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//
#import "NetworkCenter.h"
#import "ContactManager.h"
#import <CoreSpotlight/CoreSpotlight.h>

static NSString *sessionid = nil;

@interface NetworkCenter (){
    Boolean _finished;//保证数据及时并完整的返回到需要的地方  NSRunLoop
}
@end

@implementation NetworkCenter

SINGLETON_IMP(NetworkCenter)

- (id)init{
    self = [super init];
    if (self) {
        // Initialization code here.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushRegist:) name:PushRegistNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postContact) name:ContactReadFinished object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceiveCount:) name:MessageReceiveCount object:nil];
        //开启网络状况的监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        Reachability *internetReach = [Reachability reachabilityForInternetConnection];
        [internetReach startNotifier];  //开始监听,会启动一个run loop
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark custom Notification

//注册设备信息
- (void)pushRegist:(NSNotification *)n {
    UserInfo *user = [UserInfo loadCurRecord];
    if (user && user.user_id) {
        SystemInfo *systemInfo = [SystemInfo loadCurRecord];
        [API regPushToken:systemInfo.pushToken completion:^(NSError *error,id response){}];
    }
}

//消息接收
- (void)messageReceiveCount:(NSNotification *)n {
    UserInfo *user = [UserInfo loadCurRecord];
    if (user && user.user_id) {
        [self performSelector:@selector(getMessageCount) withObject:nil afterDelay:0.0];
    }
}

// 连接改变
- (void) reachabilityChanged: (NSNotification* )note{
    Reachability *currReach = [note object];
    NetworkStatus networkStatus =[currReach currentReachabilityStatus];
    switch (networkStatus) {
        case NotReachable:
            // 没有网络连接
            break;
        case ReachableViaWWAN:
            // 使用WWAN网络:2G,3G,4G
            break;
        case ReachableViaWiFi:
            // 使用WiFi网络
//            if (!self.bUploading) {
//                [self performSelectorInBackground:@selector(startUploadQueue) withObject:nil];
//            }
            break;
    }
}

#pragma mark Action

-(NSString *)getRequestUserAgent{
    return [NSString stringWithFormat:@"os/%@ device/%@ version/%@ imei/%@ osversion/%@ network/%@ operator/%@ resolution/%d*%d sessionid/%@", [UIDevice getSystemName], [[UIDevice getDevice] stringByReplacingOccurrencesOfString:@" " withString:@"_"], kVersion, [UIDevice imei], [UIDevice getSystemVersion],[UIDevice curNetWorkType],[UIDevice getCellularProviderName],(int)[[UIScreen mainScreen] bounds].size.width,(int)[[UIScreen mainScreen] bounds].size.height,[self getSessionid]];
}

-(NSString *)getSessionid{
    if (sessionid == nil) {
        sessionid=[UIDevice GetUUID];
    }
    return sessionid;
}

//上传手机通讯录信息
- (void)getContacts{
    [[ContactManager sharedInstance] getContacts];//抓取联系人
}

//加密算法AES
- ( NSData *) encryptString :( NSString *) plaintext withKey :( NSString *) key {
    return [[ plaintext dataUsingEncoding : NSUTF8StringEncoding ] AES128EncryptWithKey : key ];
}
//解密算法AES
- ( NSString *) decryptData :( NSData *) ciphertext withKey :( NSString *) key {
    return [[ NSString alloc ] initWithData :[ ciphertext AES128DecryptWithKey : key ]
                                   encoding : NSUTF8StringEncoding ];
}

//上传通讯录接口
- (void)postContact{
    NSMutableArray *allContacts = [[ContactManager sharedInstance] getContacts];
    if (allContacts.count==0) {
        CLog(@"通讯录数据为空次数");
    }
    NSString *pTotalString = [allContacts jsonStringEncoded];
    CLog(@"allContacts:%@",pTotalString);
    
    NSData* pEncyptData = [self encryptString:pTotalString withKey:@"AbC13YH8kL90HBMN"];
    //CLog(@"pEncyptData = %s",[[pEncyptData description] UTF8String]);
    //CLog(@"decypt data = %@",[self decryptData:pEncyptData withKey:@"AbC13YH8kL90HBMN"]);
    NSString* pEncyptString = [pEncyptData base64EncodedString];
    
    [API postContacts:pEncyptString
           completion:^(NSError *error,id response){
               if (!error) {
                   [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"lastDate"];
                   [[NSUserDefaults standardUserDefaults] synchronize];
               }
               else{
                   [[TKAlertCenter defaultCenter] postAlertWithMessage:error.domain];
               }
           }
     ];
}

//app启动后台要执行的进程
-(void)appActive{
    @autoreleasepool {
        [self setSearchableIndex];
        [self getPublicData];//7天
        
        UserInfo *user = [UserInfo loadCurRecord];
        if (user && user.user_id) {
            [self getMessageCount];
        }
        
        [self getWelcomeImg];
    }
}

//设置搜索
- (void)setSearchableIndex{
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
        NSMutableArray<CSSearchableItem *> *searchableItems = [NSMutableArray array];
        
        CSSearchableItemAttributeSet *attributedSet = [[CSSearchableItemAttributeSet alloc]initWithItemContentType:@"image"];
        attributedSet.title = kProductName;
        attributedSet.contentDescription = @"绿婴，活动，报名，需求，换物";
        attributedSet.thumbnailData = UIImagePNGRepresentation([UIImage imageNamed:@"Icon"]);
        
        CSSearchableItem *item = [[CSSearchableItem alloc]initWithUniqueIdentifier:@"1" domainIdentifier:kBundleIdentifier attributeSet:attributedSet];
        [searchableItems addObject:item];
        
        [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:searchableItems completionHandler:^(NSError * _Nullable error) {
            if (error) {
                CLog(@"%@",error.localizedDescription);
            }
        }];
    }
}

//所有枚举类型
- (void)getPublicData{
    NSString *cacheKey=[NSString stringWithFormat:@"%@_%@_%@",NSStringFromSelector(_cmd),APIServer,kVersion];
    cacheKey=[cacheKey md5Hash];
    if(![[FFCache currentCache] hasCacheForKey:cacheKey]){
        [API getPublicDataOnCompletion:^(NSError *error,id response){
            if (!error) {
                NSDictionary *dateDic = response;
                if (dateDic && dateDic.count>0) {
                    //"0":订单&钱包
                    SystemInfo *systemInfo = [SystemInfo loadCurRecord];
                    systemInfo.my_order_url = dateDic[@"my_order_url"];
                    systemInfo.my_wallet_url = dateDic[@"my_wallet_url"];
                    [SystemInfo saveCurRecord:systemInfo];
                    //"1":城市
                    [City clearHistory];
                    NSArray *citys = dateDic[@"city"];
                    if (citys && citys.count>0) {
                        for (NSDictionary *recordDic in citys) {
                            City *record = [[City alloc] initWithDic:recordDic];
                            [City addRecord:record];
                        }
                    }
                    //"2":省份
                    [Region clearHistory];
                    NSArray *regions = dateDic[@"region"];
                    if (regions && regions.count>0) {
                        for (NSDictionary *recordDic in regions) {
                            Region *record = [[Region alloc] initWithDic:recordDic];
                            [Region addRecord:record];
                        }
                    }
                }
                
                //2.保存本地
                [[FFCache currentCache] setString:[response JSONRepresentation] forKey:cacheKey withTimeoutInterval:60*60*24*7];//7天
            }
            else{//code>0
                [[TKAlertCenter defaultCenter] postAlertWithMessage:error.domain];
            }
        }];
    }
}

//获取各种消息数
- (void)getMessageCount{
    [API getMessageCountOnCompletion:^(NSError *error,id response){
        if (!error) {
            NSDictionary *dateDic = response;
            
            if (dateDic && dateDic.count>0) {
                UserInfo *user = [UserInfo loadCurRecord];
                user.news_total=[RKMapping(dateDic[@"news_total"]) integerValue];
                [UserInfo saveCurRecord:user];
                
                if ([[AppDelegate sharedAppDelegate].window.rootViewController isKindOfClass:[CustomTabBarController class]]) {
                    CustomTabBarController *mtabBarController = (CustomTabBarController *)[AppDelegate sharedAppDelegate].window.rootViewController;
                    
                    //mtabBarController.selectedIndex=1;
                    NSString *badgeValue=user.news_total>0?[NSString stringWithFormat:@"%@",@(user.news_total)]:nil;
                    [[mtabBarController.tabBar.items objectAtIndex:1] setBadgeValue:badgeValue];
                    //[mtabBarController hideTabbarReddots:1];
                }
                
                //若推送关闭（用户可从设置或ios通用中关闭），要手动刷新消息列表
                [[NSNotificationCenter defaultCenter] postNotificationName:MessageDidReceive object:nil userInfo:nil];
                
                if (user.news_total>0) {
                    if (![UIApplication sharedApplication].statusBarHidden) {
                        //显示方式1.生成本地通知
                        /*
                        NSDate *date = [NSDate date];
                        NSTimeInterval time = 1;//单位为秒
                        NSDate *itemDate = [date dateByAddingTimeInterval:time];//加时间
                        //NSDate *itemDate = [date dateByAddingTimeInterval:-time];//减时间
                        
                        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
                        if (localNotif){
                            localNotif.fireDate = itemDate;
                            localNotif.timeZone = [NSTimeZone defaultTimeZone];
                            
                            // Notification details
                            localNotif.alertBody = @"有新消息了!";
                            // Set the action button
                            localNotif.alertAction = NSLocalizedString(@"open", @"Open");
                            
                            localNotif.soundName = UILocalNotificationDefaultSoundName;
                            //localNotif.applicationIconBadgeNumber = 1;
                            
                            // Specify custom data for the notification
                            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"[%@,%@]",dateDic[@"type"],dateDic[@"param"]] forKey:@"params"];
                            localNotif.userInfo = userInfo;
                            
                            // Schedule the notification
                            [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
                        }
                         */
                        //NSArray *notificationArray = [[UIApplication sharedApplication] scheduledLocalNotifications];
                        //UILocalNotification *notif = [notificationArray objectAtIndex:indexPath.row];
                        //显示方式2
                        LNNotification* notification = [LNNotification notificationWithMessage:@"有新消息了!"];
                        [[LNNotificationCenter defaultCenter] presentNotification:notification forApplicationIdentifier:kBundleIdentifier];
                        
                        //声音提示 1012 -iphone   1152 ipad  1109 ipad
                        AudioServicesPlaySystemSound(1012);
                    }
                }
            }
        }
        else{//code>0
            [[TKAlertCenter defaultCenter] postAlertWithMessage:error.domain];
        }
    }];
}

//获取欢迎图
- (void)getWelcomeImg{
    [API getWelcomeImgOnCompletion:^(NSError *error,id response){
        if (!error) {
            NSString *welcome_img=response[@"welcome_img"];
            NSURL *url=[NSURL URLWithString:welcome_img];
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadImageWithURL:url
                                  options:SDWebImageRetryFailed
                                 progress:nil
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                    if (image) {
                                        // do something with image
                                        SystemInfo *systemInfo = [SystemInfo loadCurRecord];
                                        systemInfo.welcome_img = welcome_img;
                                        [SystemInfo saveCurRecord:systemInfo];
                                    }
                                }];
        }
    }];
}

- (void)startUploadQueue{
    @autoreleasepool {
    }
}

@end
