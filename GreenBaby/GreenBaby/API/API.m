//
//  API.m
//  Hunt
//
//  Created by LiXiangCheng on 15/7/28.
//  Copyright (c) 2015年 LiXiangCheng. All rights reserved.
//

#import "API.h"

#import "DeviceModel.h"
#import "UserModel.h"


@implementation API

#pragma mark - base

/**
 *  获取API的URLStr
 *
 *  @return 基础URLStr http://api.abc.com
 */
+ (NSString *)apiUrl{
    DeviceModel *device = [DeviceModel loadCurRecord];
    return [kAPIList safeObjectAtIndex:device.apiEnv];
}

/**
 *  获取API的基础URL
 *
 *  @return 基础URL http://api.abc.com
 */
+ (NSURL *)baseUR{
    return [NSURL URLWithString:[self apiUrl]];
}

/**
 *  根据API路径获取完整的URL
 *
 *  @param path API路径 /index.php
 *
 *  @return 完整的NSURL http://api.abc.com/index.php
 */
+ (NSURL *)fullURLWithPath:(NSString *)path{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [self apiUrl],path]];
}

/**
 *  请求包加密
 *
 *  @param pathParam API路径+参数(GET|DELETE)  /index.php?key1=value1&key2=value2
 *
 *  @return
 */
+ (void)encryptRequestWithManager:(AFHTTPSessionManager *)manager pathParam:(NSString *)pathParam{
    NSString *base64AuthCredentials = @"";
    //Basic认证字符串，不需要'Basic '
    NSString *basicAuth = [manager.requestSerializer valueForHTTPHeaderField:@"Authorization"];
    if (basicAuth && basicAuth.length) {
        base64AuthCredentials = [basicAuth stringByReplacingOccurrencesOfString:@"Basic " withString:@""];
    }
    
    long long time=[[NSDate date] timeIntervalSince1970];
    NSString *t=[NSString stringWithFormat:@"%@",@(time)];
    NSString *authPath=[NSString stringWithFormat:@"%@%@Q~E)ej5#vE+8D)ju",base64AuthCredentials,pathParam];
    NSString *m=[NSString stringWithFormat:@"4XJ\\wX_=T&$x[?$p%@%@",t,authPath.md5Hash];
    
    [manager.requestSerializer setValue:t forHTTPHeaderField:@"X-Auth-T"];
    [manager.requestSerializer setValue:[m md5Hash] forHTTPHeaderField:@"X-Auth-M"];
}

//HTTPS,客户端自带证书
+ (AFSecurityPolicy *)customSecurityPolicyWithCerName:(NSString *)cerName{
    //先导入证书
    AFSecurityPolicy *securityPolicy;
    
    securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModePublicKey];
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:cerName ofType:@"cer"];//证书的路径
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    securityPolicy.pinnedCertificates = [NSSet setWithObject:certData];
    
    securityPolicy.allowInvalidCertificates = NO;//万达还是有钱的
    securityPolicy.validatesDomainName = YES;//如果为NO，有可能引发中间人攻击
    
    return securityPolicy;
}

//默认模式，HTTPS,客户端不自带证书
+ (AFSecurityPolicy *)defaultSecurityPolicy{
    AFSecurityPolicy *securityPolicy;
    securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    
    securityPolicy.allowInvalidCertificates = NO;//万达还是有钱的
    securityPolicy.validatesDomainName = YES;//如果为NO，有可能引发中间人攻击
    
    return securityPolicy;
}

/**
 *  执行ANF Request，支持gzip，自动解压
 *
 *  @param path             API路径,/index.php
 *  @param paramDic         API参数,key1=value1 key2=value2
 *  @param auth             是否Base Auth
 *  @param ApiType          请求方法：GET|DELETE|PUT|POST|PostMultipart
 *  @param formdataBlock    API 仅在PostMultipart请求要上传文件Block,可为nil
 *  @param progressBlock    API请求进度Block,只有GET(下载文件代表下载进度)|POST|PostMultipart（上传文件代表上传进度）,可为nil
 *  @param completionBlock  API请求的回调Block
 *
 *  @return
 */
+ (void)executeRequestWithPath:(NSString *)path paramDic:(NSDictionary *)paramDic auth:(BOOL)auth apiType:(ApiType)apiType formdataBlock:(APIFormData)formdataBlock progressBlock:(APIProgress)progressBlock completionBlock:(APICompletion)completionBlock{
    AFHTTPSessionManager* manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[self baseUR]];
    //0.设置安全策略
    [manager setSecurityPolicy:[self defaultSecurityPolicy]];//默认模式，HTTPS,客户端不自带证书
    //1.构造requestSerializer
    manager.requestSerializer = [AFJSONRequestSerializer serializer];//post下body中raw为json
    //设置cookie,默认YES，允许请求带cookies，响应设置cookies，风控针对一些接口如登录必须使用
    [manager.requestSerializer setHTTPShouldHandleCookies:YES];
    //设置超时
    NSTimeInterval timeoutInterval = 30;
    switch (apiType) {
        case kApiTypeGetImage:
            timeoutInterval = 60;
            break;
        case kApiTypeGetFile:
            timeoutInterval = 60;
            break;
        case kApiTypePostMultipartFormData:
            timeoutInterval = 180;
            break;
        default:
            timeoutInterval = 30;
            break;
    }
    manager.requestSerializer.timeoutInterval = timeoutInterval;//默认60
    //设置Content-Type
    //[manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    //[manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[UIDevice getSystemName] forHTTPHeaderField:@"os"];
    [manager.requestSerializer setValue:kVersion forHTTPHeaderField:@"version"];
    DeviceModel *device = [DeviceModel loadCurRecord];
    if (device.vid.length > 0) {
        [manager.requestSerializer setValue:device.vid forHTTPHeaderField:@"vid"];
    }
    //设置User-Agent
    [manager.requestSerializer setValue:[[NetworkCenter sharedInstance] getRequestUserAgent] forHTTPHeaderField:@"User-Agent"];
    //设置Basic Auth
    UserModel *user = [UserModel loadCurRecord];
    if (auth && user && user.user_id) {
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:user.username password:user.password];
    }
    //请求包加密
    __block NSString *pathParam=path;//pathParam=/index.php?key1=value1&key2=value2
    if (apiType == kApiTypeGet || apiType == kApiTypeDelete) {
        [paramDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *value=[NSString stringWithFormat:@"%@",obj];
            if (value && value.length) {
                value=[value stringByURLEncodingStringParameterWithEncoding:NSUTF8StringEncoding];
            }
            pathParam= [pathParam stringByAppendingFormat:@"%@%@=%@",[pathParam rangeOfString:@"?"].length > 0 ? @"&" : @"?",key,value];
        }];
    }
    [self encryptRequestWithManager:manager pathParam:pathParam];
    //2.构造responseSerializer
    switch (apiType) {
        case kApiTypeGetImage:
            manager.responseSerializer = [AFImageResponseSerializer serializer];//image/jpeg
            break;
        case kApiTypeGetFile:
            manager.responseSerializer = [AFCompoundResponseSerializer serializer];//混合
            break;
        default:
            manager.responseSerializer = [AFJSONResponseSerializer serializer];//application/json
            //manager.responseSerializer = [AFXMLParserResponseSerializer serializer];//application/xml
            break;
    }
    //设置Status Code接受范围，默认200-300
    //manager.responseSerializer.acceptableStatusCodes=[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
    //服务端不关心 contentType，因此客户端不做验证
    manager.responseSerializer.acceptableContentTypes = nil;
    //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json; charset=utf-8",@"text/json", @"text/plain", nil];
    
    NSLog(@"开始调用 %@", [self fullURLWithPath:path]);
    switch (apiType) {
        case kApiTypeGet:
        {
            [manager GET:path
              parameters:paramDic
                progress:^(NSProgress *downloadProgress)
             {
                 if(progressBlock)
                     progressBlock(downloadProgress);
             }
                 success:^void(NSURLSessionDataTask *task,id response)
             {
                 [self parseResponseWithTask:task error:nil response:response path:path paramDic:paramDic apiType:apiType completionBlock:completionBlock];
             }
                 failure:^void(NSURLSessionDataTask * task, NSError * error)
             {
                 [self parseResponseWithTask:task error:error response:nil path:path paramDic:paramDic apiType:apiType completionBlock:completionBlock];
             }];
        }
            break;
        case kApiTypeDelete:
        {
            [manager DELETE:path
                 parameters:paramDic
                    success:^(NSURLSessionDataTask *task, id response)
             {
                 [self parseResponseWithTask:task error:nil response:response path:path paramDic:paramDic apiType:apiType completionBlock:completionBlock];
                 
             }
                    failure:^(NSURLSessionDataTask *task, NSError *error)
             {
                 [self parseResponseWithTask:task error:error response:nil path:path paramDic:paramDic apiType:apiType completionBlock:completionBlock];
             }];
        }
            break;
        case kApiTypePut:
        {
            [manager PUT:path
              parameters:paramDic
                 success:^(NSURLSessionDataTask *task, id response)
             {
                 [self parseResponseWithTask:task error:nil response:response path:path paramDic:paramDic apiType:apiType completionBlock:completionBlock];
             }
                 failure:^(NSURLSessionDataTask *task, NSError *error)
             {
                 [self parseResponseWithTask:task error:error response:nil path:path paramDic:paramDic apiType:apiType completionBlock:completionBlock];
             }];
        }
            break;
        case kApiTypePost:
        default:
        {
            [manager POST:path
               parameters:paramDic
                 progress:^(NSProgress *downloadProgress)
             {
                 if(progressBlock)
                     progressBlock(downloadProgress);
             }
                  success:^void(NSURLSessionDataTask *task,id response)
             {
                 [self parseResponseWithTask:task error:nil response:response path:path paramDic:paramDic apiType:apiType completionBlock:completionBlock];
             }
                  failure:^void(NSURLSessionDataTask * task, NSError * error)
             {
                 [self parseResponseWithTask:task error:error response:nil path:path paramDic:paramDic apiType:apiType completionBlock:completionBlock];
             }];
        }
            break;
        case kApiTypePostMultipartFormData:
        {
            [manager POST:path
               parameters:paramDic
constructingBodyWithBlock:formdataBlock
                 progress:^(NSProgress *downloadProgress)
             {
                 if(progressBlock)
                     progressBlock(downloadProgress);
             }
                  success:^void(NSURLSessionDataTask * task, id response)
             {
                 [self parseResponseWithTask:task error:nil response:response path:path paramDic:paramDic apiType:apiType completionBlock:completionBlock];
             }
                  failure:^ void(NSURLSessionDataTask * task, NSError * error)
             {
                 [self parseResponseWithTask:task error:error response:nil path:path paramDic:paramDic apiType:apiType completionBlock:completionBlock];
             }];
        }
            break;
    }
}

+ (void)parseResponseWithTask:(NSURLSessionDataTask *)task error:(NSError *)error response:(id)response path:(NSString *)path paramDic:(NSDictionary *)paramDic apiType:(ApiType)apiType completionBlock:(APICompletion)completionBlock{
    if (error){
        NSString *domain=@"";
        NSData *responseData=nil;
        if (error.userInfo && error.userInfo.count>0) {
            if (error.userInfo[NSLocalizedDescriptionKey]) {
                domain=error.userInfo[NSLocalizedDescriptionKey];
                if (error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey]) {
                    responseData=error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                }
            }
            else{
                if (error.userInfo[NSUnderlyingErrorKey]) {
                    NSError *underlyingError=error.userInfo[NSUnderlyingErrorKey];
                    if (underlyingError.userInfo && underlyingError.userInfo.count>0) {
                        if (underlyingError.userInfo[NSLocalizedDescriptionKey]) {
                            domain=underlyingError.userInfo[NSLocalizedDescriptionKey];
                        }
                        if (underlyingError.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey]) {
                            responseData=underlyingError.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
                        }
                    }
                }
            }
        }
        if (!domain.length) {
            if (![Reachability reachabilityForInternetConnection].isReachable){
                domain=@"当前无法连接到网络";
            }
            else{
                domain=@"连接超时";
            }
        }
//        if (![Reachability reachabilityForInternetConnection].isReachable){
//            domain=@"当前无法连接到网络";
//        }
//        else{
//            domain=@"连接超时";
//        }
        
        NSError *newError = [NSError errorWithDomain:domain
                                                code:-1//error.code
                                            userInfo:error.userInfo];
        completionBlock(newError, nil);
        
#ifndef RELEASE
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        NSLog(@"responseString : %@",responseString);
        
        if (responseData) {
            NSString *style = [NSString stringWithFormat:@"<style type=\"text/css\"> \n"
                               "<!-- \n"
                               "body {font-family: \"%@\";font-size: %dpx;color:rgb(%d,%d,%d);background-color:rgb(%d,%d,%d)} \n"
                               "p {text-indent:2em; line-height:1.5em; margin-top:0; margin-bottom:0;} \n"
                               "--> \n"
                               "</style>",@"宋体",48,0,0,0,255,255,255];
            NSString *html=[NSString stringWithFormat:@"%@<body>Url:<br>%@<br><br>Method:<br>%@<br><br>param:<br>%@<br><br>postData:<br>%@<br><br>Headers:<br>%@<br><br></body><br>responseString:<br>%@",style,task.currentRequest.URL,task.currentRequest.HTTPMethod,paramDic,[[NSString alloc] initWithData:task.currentRequest.HTTPBody encoding:NSUTF8StringEncoding],task.currentRequest.allHTTPHeaderFields,responseString];
            UIViewController *curVC=[[AppDelegate sharedAppDelegate].window topViewController];
            UIViewController *post = [[APIParseErrorViewController alloc] initWithHtml:html title:@"API调用失败"];
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:post];
            nc.navigationBar.translucent = NO;
            [curVC presentViewController:nc animated:YES completion:nil];
        }
#endif
    }
    else{
        NSLog(@"调用结果:Url:%@\nMethod:%@\nparam:%@\npostData:%@\nHeaders:%@\nresponseString:%@",task.currentRequest.URL,task.currentRequest.HTTPMethod,paramDic,[[NSString alloc] initWithData:task.currentRequest.HTTPBody encoding:NSUTF8StringEncoding],task.currentRequest.allHTTPHeaderFields,response);
        switch (apiType) {
            case kApiTypeGetImage:
                completionBlock(nil, response);//response:UIImage
                break;
            case kApiTypeGetFile:
                completionBlock(nil, response);//response:NSData
                break;
            default://response:NSDictionary
            {
                NSInteger code = [[NSNumber safeNumberFromObject:response[@"code"]] integerValue];
                if (code == 0){// API调用成功
                    completionBlock(nil, [NSDictionary safeDictionaryFromObject:response]);
                }
                else if (code == 401) {//token过期，请登录
                    BaseViewController *curVC=(BaseViewController *)[[AppDelegate sharedAppDelegate].window topViewController];
//                    if(![curVC isKindOfClass:[LoginViewController class]]){
                        //UIViewController *vc = [[LoginViewController alloc] init];
                        UIViewController *vc = [[BaseViewController alloc] init];
                        UINavigationController *nc = [[NavRootViewController alloc] initWithRootViewController:vc];
                        //UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
                        nc.navigationBar.translucent = NO;
                        [curVC presentViewController:nc animated:YES completion:nil];
//                    }
                }
                else if (code == 1212) {  //此版本放弃使用，请升级到最新版本
                    [UIAlertController showWithTitle:@"提示"
                                             message:[NSString safeStringFromObject:response[@"message"]]
                                   cancelButtonTitle:nil
                                   defultButtonTitle:NSLocalizedString(@"确定",nil)
                              destructiveButtonTitle:nil
                                            onCancel:nil
                                            onDefult:^(UIAlertAction *action) {
                                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/ren-ren-lie-tou/id558470197?mt=8"]];
                                            }
                                       onDestructive:nil];
                }
                else{
                    NSError *error = [NSError errorWithDomain:[NSString safeStringFromObject:response[@"message"]]
                                                         code:code
                                                     userInfo:nil];
                    completionBlock(error, nil);
                }
            }
                break;
        }
    }
}

#pragma mark - common
+ (void)appVersionCheckOnCompletion:(APICompletion)completion{
    NSMutableDictionary *paramDic=[NSMutableDictionary dictionary];
    [paramDic setObject:[UIDevice getSystemName] forKey:@"platform"];
    [paramDic setObject:kBuildVersion forKey:@"build_version"];
    [self executeRequestWithPath:@"/v1/setting/check_update" paramDic:paramDic auth:NO apiType:kApiTypePost formdataBlock:nil progressBlock:nil completionBlock:completion];
}

+ (void)regPushToken:(NSString *)pushToken completion:(APICompletion)completion{
    NSMutableDictionary *paramDic=[NSMutableDictionary dictionary];
    [paramDic setObject:pushToken forKey:@"deviceid"];//设备推送token信息
    [paramDic setObject:[UIDevice getSystemName] forKey:@"os"];//系统信息。目前支持的值只能为ios或android
    if ([kBundleIdentifier isEqualToString:@"com.ideal.GreenBaby.InHouse"]) {//InHouse版本
        [paramDic setObject:@(2) forKey:@"apptype"];
    }
    else{
        [paramDic setObject:@(1) forKey:@"apptype"];
    }
    [paramDic setObject:kVersion forKey:@"version"];
    [paramDic setObject:[UIDevice imei] forKey:@"imei"];//imei编号
    [paramDic setObject:[[UIDevice getDevice] stringByReplacingOccurrencesOfString:@" " withString:@"_"] forKey:@"device"];//device
    [self executeRequestWithPath:@"/v1/user/register_device" paramDic:paramDic auth:YES apiType:kApiTypePost formdataBlock:nil progressBlock:nil completionBlock:completion];
}

+ (void)postContacts:(NSString *)contacts completion:(APICompletion)completion{
    NSMutableDictionary *paramDic=[NSMutableDictionary dictionary];
    [paramDic setObject:contacts forKey:@"contacts"];//contacts
    [paramDic setObject:[UIDevice getSystemName] forKey:@"platform"];
    [self executeRequestWithPath:@"/v1/contact/sync" paramDic:paramDic auth:YES apiType:kApiTypePost formdataBlock:nil progressBlock:nil completionBlock:completion];
}

+ (void)getPublicDataOnCompletion:(APICompletion)completion{
    [self executeRequestWithPath:@"/v1/public/data" paramDic:nil auth:NO apiType:kApiTypeGet formdataBlock:nil progressBlock:nil completionBlock:completion];
}

+ (void)getMessageCountOnCompletion:(APICompletion)completion{
    NSMutableDictionary *paramDic=[NSMutableDictionary dictionary];
    [paramDic setObject:@"request_count,message_count,tucao_new,feed_new,hposition_new,reward_position_new" forKey:@"type"];//type:消息类型（可选，apply_count,view_count,active_count,message_count）
    [self executeRequestWithPath:@"/v1/notification/has_new" paramDic:paramDic auth:YES apiType:kApiTypePost formdataBlock:nil progressBlock:nil completionBlock:completion];
}

+ (void)getWelcomeImgOnCompletion:(APICompletion)completion{
    NSMutableDictionary *paramDic=[NSMutableDictionary dictionary];
    [paramDic setObject:[UIDevice getSystemName] forKey:@"os"];
    [paramDic setObject:@((int)[[UIScreen mainScreen] bounds].size.width*[[UIScreen mainScreen] scale]) forKey:@"width"];
    [paramDic setObject:@((int)[[UIScreen mainScreen] bounds].size.height*[[UIScreen mainScreen] scale]) forKey:@"height"];
    [self executeRequestWithPath:@"/v1/public/welcome_image" paramDic:paramDic auth:NO apiType:kApiTypePost formdataBlock:nil progressBlock:nil completionBlock:completion];
}

+ (void)updatePushStatusOnCompletion:(APICompletion)completion{
    NSMutableDictionary *paramDic=[NSMutableDictionary dictionary];
    [paramDic setObject:[UIDevice getSystemName] forKey:@"os"];
    DeviceModel *device = [DeviceModel  loadCurRecord];
    if (device.vid.length > 0) {
        [paramDic setObject:device.vid forKey:@"visitor_id"];
    }
    [paramDic setObject:@(device.push_status) forKey:@"pushstatus"];
    [self executeRequestWithPath:@"/v1/setting/update_push_status" paramDic:paramDic auth:YES apiType:kApiTypePost formdataBlock:nil progressBlock:nil completionBlock:completion];
}

+ (void)downloadAvatarWithProgress:(APIProgress)progress
                        completion:(APICompletion)completion{
    [self executeRequestWithPath:@"/v1/user/avatar" paramDic:nil auth:YES apiType:kApiTypeGetImage formdataBlock:nil progressBlock:progress completionBlock:completion];
}

+ (void)downloadAvatarFileWithProgress:(APIProgress)progress
                            completion:(APICompletion)completion{
    [self executeRequestWithPath:@"/v1/user/avatar" paramDic:nil auth:YES apiType:kApiTypeGetFile formdataBlock:nil progressBlock:progress completionBlock:completion];
}

+ (void)uploadAvatar:(NSData *)fileData
            progress:(APIProgress)progress
          completion:(APICompletion)completion{
    APIFormData formdata = ^(id <AFMultipartFormData> formData){
        [formData appendPartWithFileData:fileData name:@"userfile" fileName:@"userfile.jpg" mimeType:@"image/jpeg"];
    };
    [self executeRequestWithPath:@"/v1/user/update_avatar" paramDic:nil auth:YES apiType:kApiTypePostMultipartFormData formdataBlock:formdata progressBlock:progress completionBlock:completion];
}

+ (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
               completion:(APICompletion)completion{
    NSMutableDictionary *paramDic=[NSMutableDictionary dictionary];
    [paramDic setObject:username forKey:@"username"];
    [paramDic setObject:password forKey:@"password"];
    [self executeRequestWithPath:@"/v1/user/login" paramDic:paramDic auth:NO apiType:kApiTypePost formdataBlock:nil progressBlock:nil completionBlock:completion];
}

+ (void)regWithUsername:(NSString *)username
               password:(NSString *)password
                   code:(NSString *)code
             completion:(APICompletion)completion{
    NSMutableDictionary *paramDic=[NSMutableDictionary dictionary];
    [paramDic setObject:username forKey:@"username"];
    [paramDic setObject:password forKey:@"password"];
    [paramDic setObject:code forKey:@"code"];
    [self executeRequestWithPath:@"/v1/user/reg" paramDic:paramDic auth:NO apiType:kApiTypePost formdataBlock:nil progressBlock:nil completionBlock:completion];
}

+ (void)sendCodeWithMobile:(NSString *)mobile
                completion:(APICompletion)completion{
    NSMutableDictionary *paramDic=[NSMutableDictionary dictionary];
    [paramDic setObject:mobile forKey:@"mobile"];
    [self executeRequestWithPath:@"/v1/user/SendPswCode" paramDic:paramDic auth:NO apiType:kApiTypePost formdataBlock:nil progressBlock:nil completionBlock:completion];
}

+ (void)validateCodeWithMobile:(NSString *)mobile
                          code:(NSString *)code
                    completion:(APICompletion)completion{
    NSMutableDictionary *paramDic=[NSMutableDictionary dictionary];
    [paramDic setObject:mobile forKey:@"mobile"];
    [paramDic setObject:code forKey:@"code"];
    [self executeRequestWithPath:@"/v1/user/ValidateCode" paramDic:paramDic auth:NO apiType:kApiTypePost formdataBlock:nil progressBlock:nil completionBlock:completion];
}

#pragma mark - Talk
+ (void)getMsgListWithPage:(NSUInteger)page
                     count:(NSUInteger)count
                   startid:(NSUInteger)startid
                completion:(APICompletion)completion{
    NSMutableDictionary *paramDic=[NSMutableDictionary dictionary];
    if (page > 0) {
        [paramDic setObject:@(page) forKey:@"page"];
    }
    if (count > 0) {
        [paramDic setObject:@(count) forKey:@"count"];
    }
    if (startid > 0) {
        [paramDic setObject:@(startid) forKey:@"startid"];
    }
    [self executeRequestWithPath:@"/v1/msg/list" paramDic:paramDic auth:YES apiType:kApiTypePost formdataBlock:nil progressBlock:nil completionBlock:completion];
}

+ (void)getMessageWithTouid:(NSInteger)touid//对方用户编号（必选）
                  fetch_new:(NSInteger)fetch_new//获取新消息。（可选，1获取新消息，0获取历史消息）
                    startid:(NSInteger)startid//起始消息编号。（可选，默认为0）
                      count:(NSUInteger)count//每页的数量。（可选，默认为10）
                 completion:(APICompletion)completion{
    NSMutableDictionary *paramDic=[NSMutableDictionary dictionary];
    [paramDic setObject:@(touid) forKey:@"touid"];
    [paramDic setObject:@(fetch_new) forKey:@"fetch_new"];
    if (startid > 0) {
        [paramDic setObject:@(startid) forKey:@"startid"];
    }
    if (count > 0) {
        [paramDic setObject:@(count) forKey:@"count"];
    }
    [self executeRequestWithPath:@"/v1/msg/view" paramDic:paramDic auth:YES apiType:kApiTypePost formdataBlock:nil progressBlock:nil completionBlock:completion];
}

+ (void)sendMessageWithTouid:(NSInteger)touid//对方用户编号（必选）
                     startid:(NSInteger)startid//起始消息编号。（可选，默认为0）
                    msg_type:(NSInteger)msg_type//消息类型（1文本含emoji，2表示图片）
                     content:(NSString *)content//消息内容(1文本含emoji,2:[图片])
                       image:(NSString *)image//图片信息(url+width+height)
                  completion:(APICompletion)completion{
    NSMutableDictionary *paramDic=[NSMutableDictionary dictionary];
    [paramDic setObject:@(touid) forKey:@"touid"];
    if (startid > 0) {
        [paramDic setObject:@(startid) forKey:@"startid"];
    }
    [paramDic setObject:@(msg_type) forKey:@"msg_type"];
    [paramDic setObject:content forKey:@"content"];
    if (image && image.length) {
        [paramDic setObject:image forKey:@"image"];
    }
    [self executeRequestWithPath:@"/v1/msg/send" paramDic:paramDic auth:YES apiType:kApiTypePost formdataBlock:nil progressBlock:nil completionBlock:completion];
}

#pragma mark - 订单&支付
+ (void)getOrderInfo:(NSUInteger)order_id completion:(APICompletion)completion
{
    NSMutableDictionary *paramDic=[NSMutableDictionary dictionary];
    [paramDic setObject:@(order_id) forKey:@"order_id"];
    [self executeRequestWithPath:@"/v1/order/info" paramDic:paramDic auth:YES apiType:kApiTypePost formdataBlock:nil progressBlock:nil completionBlock:completion];
}

+ (void)cancelOrderInfo:(NSUInteger)order_id completion:(APICompletion)completion
{
    NSMutableDictionary *paramDic=[NSMutableDictionary dictionary];
    [paramDic setObject:@(order_id) forKey:@"order_id"];
    [self executeRequestWithPath:@"/v1/order/cancel" paramDic:paramDic auth:YES apiType:kApiTypePost formdataBlock:nil progressBlock:nil completionBlock:completion];
}

+ (void)getWeiXinPayWithOrderID:(NSString *)order_id completion:(APICompletion)completion
{
    NSMutableDictionary *paramDic=[NSMutableDictionary dictionary];
    [paramDic setObject:order_id forKey:@"order_id"];
    [self executeRequestWithPath:@"/v1/order/weixin_pay" paramDic:paramDic auth:YES apiType:kApiTypePost formdataBlock:nil progressBlock:nil completionBlock:completion];
}

+ (void)getAliPayWithOrderID:(NSString *)order_id completion:(APICompletion)completion
{
    NSMutableDictionary *paramDic=[NSMutableDictionary dictionary];
    [paramDic setObject:order_id forKey:@"order_id"];
    [self executeRequestWithPath:@"/v1/order/apipay_pay" paramDic:paramDic auth:YES apiType:kApiTypePost formdataBlock:nil progressBlock:nil completionBlock:completion];
}

#pragma mark - 环信EaseMob
+ (void)getEasemobWelcomeMessageCompletion:(APICompletion)completion{
    [self executeRequestWithPath:@"/v1/easemob/welcome_message" paramDic:nil auth:YES apiType:kApiTypePost formdataBlock:nil progressBlock:nil completionBlock:completion];
}

+ (void)getEasemobChatterProfileWithChatter:(NSString *)chatter completion:(APICompletion)completion{
    NSMutableDictionary *paramDic=[NSMutableDictionary dictionary];
    [paramDic setObject:chatter forKey:@"chatter"];
    [self executeRequestWithPath:@"/v1/easemob/account_profile" paramDic:paramDic auth:YES apiType:kApiTypePost formdataBlock:nil progressBlock:nil completionBlock:completion];
}

+ (void)getEasemobGroupMumber:(NSString *)groupId completion:(APICompletion)completion
{
    NSMutableDictionary *paramDic=[NSMutableDictionary dictionary];
    [paramDic setObject:groupId forKey:@"groupId"];
    [self executeRequestWithPath:@"/v1/easemob/member_list" paramDic:paramDic auth:YES apiType:kApiTypePost formdataBlock:nil progressBlock:nil completionBlock:completion];
}

+ (void)sayHelloUserNo:(NSString *)user_no completion:(APICompletion)completion
{
    NSMutableDictionary *paramDic=[NSMutableDictionary dictionary];
    [paramDic setObject:user_no forKey:@"user_no"];
    [self executeRequestWithPath:@"/v1/easemob/hello" paramDic:paramDic auth:YES apiType:kApiTypePost formdataBlock:nil progressBlock:nil completionBlock:completion];
}

@end
