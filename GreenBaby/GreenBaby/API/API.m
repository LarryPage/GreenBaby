//
//  API.m
//  Hunt
//
//  Created by LiXiangCheng on 15/7/28.
//  Copyright (c) 2015年 LiXiangCheng. All rights reserved.
//

#import "API.h"
#import "APIParseErrorViewController.h"

#import "SystemInfo.h"
#import "UserInfo.h"


@implementation API

/**
 *  根据API路径得到完整的URL
 *
 *  @param path API路径
 *
 *  @return 完整的NSURL
 */
NSURL *fullURLWithPath(NSString *API) {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", APIServer,API]];
}

/**
 *  请求包加密
 */
+ (void)encryptRequest:(ASIFormDataRequest *)request authBase64String:(NSString *)authBase64String{
    long long time=[[NSDate date] timeIntervalSince1970];
    NSString *t=[NSString stringWithFormat:@"%@",@(time)];
    NSString *urlPath=[request.url path];
    NSString *urlQuery=[request.url query];
    NSString *pathstr=[NSString stringWithFormat:@"%@%@%@",urlPath,(urlQuery && urlQuery.length)?@"?":@"",(urlQuery && urlQuery.length)?urlQuery:@""];
    NSString *pathauth=[NSString stringWithFormat:@"%@%@Q~E)ej5#vE+8D)ju",authBase64String,pathstr];
    NSString *m=[NSString stringWithFormat:@"4XJ\\wX_=T&$x[?$p%@%@",t,pathauth.md5Hash];
    [request addRequestHeader:@"X-Auth-T" value:t];
    [request addRequestHeader:@"X-Auth-M" value:[m md5Hash]];
}

/**
 *  创建Request
 *
 *  @param path       API路径
 *  @param auth       是否Base Auth
 *  @param method     请求方法：GET|POST
 *  @param delegate   委托对象
 *  @param completion 回调
 *
 *  @return 一个ASIFormDataRequest对象
 */
ASIFormDataRequest *createRequest(NSString *path,BOOL auth,NSString *method,NSDictionary *paramDic,id delegate,APICompletion completion){
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:fullURLWithPath(path)];
    // YES is the default, you can turn off gzip compression by setting this to NO
    [request setAllowCompressedResponse:AllowCompressedResponse];//gzip
    [request addRequestHeader:@"Content-Type" value:@"application/x-www-form-urlencoded; charset=utf-8"];
    //[request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"User-Agent" value:[[NetworkCenter sharedInstance] getRequestUserAgent]];
    
    UserInfo *user = [UserInfo loadCurRecord];
    NSString *authString = @"";
    NSString *authBase64String = @"";
    if (auth && user && user.user_id) {
        authString = [NSString stringWithFormat:@"%@:%@", user.username, user.password];
        authBase64String = [NSString base64encode:authString];
        [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", authBase64String]];
    }
    
    if (method && method.length>0) {
        [request setRequestMethod:method];
    }
    else{
        [request setRequestMethod:@"POST"];
    }
    
    if (paramDic && paramDic.count>0) {//POST,PUT
        if ([request.requestMethod isEqualToString:@"POST"] || [request.requestMethod isEqualToString:@"PUT"]) {
            [paramDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [request addPostValue:obj forKey:key];
            }];
            //NSMutableData *postBody = [NSMutableData dataWithData:[[paramDic JSONRepresentation] dataUsingEncoding:NSUTF8StringEncoding]];
            //[request setPostBody:postBody];
        }
        else{//GET,DELETE
            __block NSString *urlStr=request.url.absoluteString;
            [paramDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSString *value=[NSString stringWithFormat:@"%@",obj];
                if (value && value.length) {
                    value=[value stringByURLEncodingStringParameterWithEncoding:NSUTF8StringEncoding];
                }
                urlStr= [urlStr stringByAppendingFormat:@"%@%@=%@",[urlStr rangeOfString:@"?"].length > 0 ? @"&" : @"?",key,value];
            }];
            request.url=[NSURL URLWithString:urlStr];
        }
    }
    
    //请求包加密
    [API encryptRequest:request authBase64String:authBase64String];
    
    request.delegate = delegate;
    [request setValidatesSecureCertificate:NO];// As your certificate is self-signed, iOS can't validate the certificate
    request.uploadProgressDelegate = delegate;
    request.userInfo = @{@"Completion": completion};
    
    return request;
}

#pragma mark - ASIHTTPRequestDelegate

- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes{
}

+ (void)requestStarted:(ASIHTTPRequest *)request {
    CLog(@"开始调用 %@", request.url);
}

+ (void)requestFinished:(ASIHTTPRequest *)request {
    // 得到调用完成后执行的Block
    APICompletion completion = request.userInfo[@"Completion"];
    
    // 将JSON Data解析为Foundation Object(NSDictionary)
    NSError *error = nil;
    NSString *responseString = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
    CLog(@"responseString : %@",responseString);
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:request.responseData options:kNilOptions error:&error];
    if (!error)
    {
        NSInteger code = [[NSNumber safeNumberFromObject:responseDic[@"code"]] integerValue];
        if (code == 0){// API调用成功
            completion(nil, [NSDictionary safeDictionaryFromObject:responseDic[@"data"]]);
        }
        else if (code == 1212) {  //此版本放弃使用，请升级到最新版本
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:[NSString safeStringFromObject:responseDic[@"message"]]
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"确定",nil];
            alert.tag=1;
            alert.delegate=[AppDelegate sharedAppDelegate];
            [alert show];
        }
        else{
            NSError *error = [NSError errorWithDomain:[NSString safeStringFromObject:responseDic[@"message"]]
                                                 code:code
                                             userInfo:nil];
            completion(error, nil);
        }
    }
    else  // JSON解析失败
    {
        NSError *newError = [NSError errorWithDomain:@"数据格式解析失败"
                                                code:error.code
                                            userInfo:error.userInfo];
        completion(newError, nil);
#ifndef RELEASE
        NSString *style = [NSString stringWithFormat:@"<style type=\"text/css\"> \n"
                           "<!-- \n"
                           "body {font-family: \"%@\";font-size: %dpx;color:rgb(%d,%d,%d);background-color:rgb(%d,%d,%d)} \n"
                           "p {text-indent:2em; line-height:1.5em; margin-top:0; margin-bottom:0;} \n"
                           "--> \n"
                           "</style>",@"宋体",48,0,0,0,255,255,255];
        NSString *html=[NSString stringWithFormat:@"%@<body>Url:<br>%@<br><br>Method:<br>%@<br><br>Headers:<br>%@<br><br>postData:<br>%@<br><br></body><br>responseString:<br>%@",style,request.url,request.requestMethod,request.requestHeaders,[[NSString alloc] initWithData:request.postBody encoding:NSUTF8StringEncoding],responseString];
        UIViewController *curVC=[[AppDelegate sharedAppDelegate].window topViewController];
        UIViewController *post = [[APIParseErrorViewController alloc] initWithHtml:html title:@"数据格式解析失败"];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:post];
        nc.navigationBar.translucent = NO;
        [curVC presentViewController:nc animated:YES completion:nil];
#endif
    }
    
    [ASIHTTPRequest setDefaultTimeOutSeconds:[ASIHTTPRequest defaultTimeOutSeconds]];
}

+ (void)requestFailed:(ASIHTTPRequest *)request {
    APICompletion completion = request.userInfo[@"Completion"];
    NSError *error = [request error];
    
    NSString *domain=@"";
//    if (error.userInfo && error.userInfo.count>0 && error.userInfo[@"NSLocalizedDescription"]) {
//        domain=error.userInfo[@"NSLocalizedDescription"];
//    }
//    else{
//        if (![Reachability reachabilityForInternetConnection].isReachable){
//            domain=@"当前无法连接到网络";
//        }
//        else{
//            domain=@"连接超时";
//        }
//    }
    if (![Reachability reachabilityForInternetConnection].isReachable){
        domain=@"当前无法连接到网络";
    }
    else{
        domain=@"连接超时";
    }
    
    NSError *newError = [NSError errorWithDomain:domain
                                            code:-1//error.code
                                        userInfo:error.userInfo];
    completion(newError, nil);
    
    [ASIHTTPRequest setDefaultTimeOutSeconds:[ASIHTTPRequest defaultTimeOutSeconds]];
}

#pragma mark - common
+ (void)appVersionCheckOnCompletion:(APICompletion)completion{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setObject:[UIDevice getSystemName] forKey:@"platform"];
    [dic setObject:kBuildVersion forKey:@"build_version"];
    
    ASIFormDataRequest *request = createRequest(@"/v1/setting/check_update",NO,@"POST",dic,self,completion);
    [request startAsynchronous];
}

+ (void)regPushToken:(NSString *)pushToken completion:(APICompletion)completion{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setObject:pushToken forKey:@"deviceid"];//设备推送token信息
    [dic setObject:[UIDevice getSystemName] forKey:@"os"];//系统信息。目前支持的值只能为ios或android
    if ([kBundleIdentifier isEqualToString:@"com.ideal.GreenBaby.InHouse"]) {//InHouse版本
        [dic setObject:@(2) forKey:@"apptype"];
    }
    else{
        [dic setObject:@(1) forKey:@"apptype"];
    }
    [dic setObject:kVersion forKey:@"version"];
    [dic setObject:[UIDevice imei] forKey:@"imei"];//imei编号
    [dic setObject:[[UIDevice getDevice] stringByReplacingOccurrencesOfString:@" " withString:@"_"] forKey:@"device"];//device
    
    ASIFormDataRequest *request = createRequest(@"/v1/user/register_device",YES,@"POST",dic,self,completion);
    [request startAsynchronous];
}

+ (void)postContacts:(NSString *)contacts completion:(APICompletion)completion{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setObject:contacts forKey:@"contacts"];//contacts
    [dic setObject:[UIDevice getSystemName] forKey:@"platform"];
    
    ASIFormDataRequest *request = createRequest(@"/v1/contact/sync",YES,@"POST",dic,self,completion);
    [request startAsynchronous];
}

+ (void)getPublicDataOnCompletion:(APICompletion)completion{
    ASIFormDataRequest *request = createRequest(@"/v1/public/data",NO,@"GET",nil,self,completion);
    [request startAsynchronous];
}

+ (void)getMessageCountOnCompletion:(APICompletion)completion{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setObject:@"request_count,message_count,tucao_new,feed_new,hposition_new,reward_position_new" forKey:@"type"];//type:消息类型（可选，apply_count,view_count,active_count,message_count）
    
    ASIFormDataRequest *request = createRequest(@"/v1/notification/has_new",YES,@"POST",dic,self,completion);
    [request startAsynchronous];
}

+ (void)getWelcomeImgOnCompletion:(APICompletion)completion{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setObject:[UIDevice getSystemName] forKey:@"os"];
    [dic setObject:@((int)[[UIScreen mainScreen] bounds].size.width*[[UIScreen mainScreen] scale]) forKey:@"width"];
    [dic setObject:@((int)[[UIScreen mainScreen] bounds].size.height*[[UIScreen mainScreen] scale]) forKey:@"height"];
    
    ASIFormDataRequest *request = createRequest(@"/v1/public/welcome_image",NO,@"POST",dic,self,completion);
    [request startAsynchronous];
}

+ (void)updatePushStatusOnCompletion:(APICompletion)completion{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setObject:[UIDevice getSystemName] forKey:@"os"];
    UserInfo *user = [UserInfo loadCurRecord];
    [dic setObject:@(user.push_status) forKey:@"pushstatus"];//pushstatus:0为关闭，1为打开
    
    ASIFormDataRequest *request = createRequest(@"/v1/setting/update_push_status",YES,@"POST",dic,self,completion);
    [request startAsynchronous];
}

+ (void)updateAvatar:(NSData *)fileData completion:(APICompletion)completion{
    [ASIHTTPRequest setDefaultTimeOutSeconds:180];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:fullURLWithPath(@"/v1/user/update_avatar")];
    // YES is the default, you can turn off gzip compression by setting this to NO
    [request setAllowCompressedResponse:AllowCompressedResponse];//gzip
    [request addRequestHeader:@"Content-Type" value:@"multipart/form-data"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"User-Agent" value:[[NetworkCenter sharedInstance] getRequestUserAgent]];
    
    UserInfo *user = [UserInfo loadCurRecord];
    NSString *authString = @"";
    NSString *authBase64String = @"";
    if (user && user.user_id) {
        authString = [NSString stringWithFormat:@"%@:%@", user.username, user.password];
        authBase64String = [NSString base64encode:authString];
        [request addRequestHeader:@"Authorization" value:[NSString stringWithFormat:@"Basic %@", authBase64String]];
    }
    
    [request addData:fileData withFileName:@"userfile.jpg" andContentType:@"image/jpeg" forKey:@"userfile"];//压缩大小
    
    //请求包加密
    [API encryptRequest:request authBase64String:authBase64String];
    
    request.delegate = self;
    request.uploadProgressDelegate = self;
    request.userInfo = @{@"Completion": completion};
    [request startAsynchronous];
}

+ (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
               completion:(APICompletion)completion{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setObject:username forKey:@"username"];
    [dic setObject:password forKey:@"password"];
    
    ASIFormDataRequest *request = createRequest(@"/v1/user/login",NO,@"POST",dic,self,completion);
    [request startAsynchronous];
}

+ (void)regWithUsername:(NSString *)username
               password:(NSString *)password
                   code:(NSString *)code
             completion:(APICompletion)completion{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setObject:username forKey:@"username"];
    [dic setObject:password forKey:@"password"];
    [dic setObject:code forKey:@"code"];
    
    ASIFormDataRequest *request = createRequest(@"/v1/user/reg",NO,@"POST",dic,self,completion);
    [request startAsynchronous];
}

+ (void)sendCodeWithMobile:(NSString *)mobile
                completion:(APICompletion)completion{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setObject:mobile forKey:@"mobile"];
    
    ASIFormDataRequest *request = createRequest(@"/v1/user/SendPswCode",NO,@"POST",dic,self,completion);
    [request startAsynchronous];
}

+ (void)validateCodeWithMobile:(NSString *)mobile
                          code:(NSString *)code
                    completion:(APICompletion)completion{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setObject:mobile forKey:@"mobile"];
    [dic setObject:code forKey:@"code"];
    
    ASIFormDataRequest *request = createRequest(@"/v1/user/ValidateCode",NO,@"POST",dic,self,completion);
    [request startAsynchronous];
}

#pragma mark - Talk
+ (void)getMsgListWithPage:(NSUInteger)page
                     count:(NSUInteger)count
                   startid:(NSUInteger)startid
                completion:(APICompletion)completion{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    if (page > 0) {
        [dic setObject:@(page) forKey:@"page"];
    }
    if (count > 0) {
        [dic setObject:@(count) forKey:@"count"];
    }
    if (startid > 0) {
        [dic setObject:@(startid) forKey:@"startid"];
    }
    
    ASIFormDataRequest *request = createRequest(@"/v1/msg/list",YES,@"POST",dic,self,completion);
    [request startAsynchronous];
}

+ (void)getMessageWithTouid:(NSInteger)touid//对方用户编号（必选）
                  fetch_new:(NSInteger)fetch_new//获取新消息。（可选，1获取新消息，0获取历史消息）
                    startid:(NSInteger)startid//起始消息编号。（可选，默认为0）
                      count:(NSUInteger)count//每页的数量。（可选，默认为10）
                 completion:(APICompletion)completion{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setObject:@(touid) forKey:@"touid"];
    [dic setObject:@(fetch_new) forKey:@"fetch_new"];
    if (startid > 0) {
        [dic setObject:@(startid) forKey:@"startid"];
    }
    if (count > 0) {
        [dic setObject:@(count) forKey:@"count"];
    }
    
    ASIFormDataRequest *request = createRequest(@"/v1/msg/view",YES,@"POST",dic,self,completion);
    [request startAsynchronous];
}

+ (void)sendMessageWithTouid:(NSInteger)touid//对方用户编号（必选）
                     startid:(NSInteger)startid//起始消息编号。（可选，默认为0）
                    msg_type:(NSInteger)msg_type//消息类型（1文本含emoji，2表示图片）
                     content:(NSString *)content//消息内容(1文本含emoji,2:[图片])
                       image:(NSString *)image//图片信息(url+width+height)
                  completion:(APICompletion)completion{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setObject:@(touid) forKey:@"touid"];
    if (startid > 0) {
        [dic setObject:@(startid) forKey:@"startid"];
    }
    [dic setObject:@(msg_type) forKey:@"msg_type"];
    [dic setObject:content forKey:@"content"];
    if (image && image.length) {
        [dic setObject:image forKey:@"image"];
    }
    
    ASIFormDataRequest *request = createRequest(@"/v1/msg/send",YES,@"POST",dic,self,completion);
    [request startAsynchronous];
}

#pragma mark - 订单&支付
+ (void)getOrderInfo:(NSUInteger)order_id completion:(APICompletion)completion
{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setObject:@(order_id) forKey:@"order_id"];
    
    ASIFormDataRequest *request = createRequest(@"/v1/order/info",YES,@"POST",dic,self,completion);
    [request startAsynchronous];
}

+ (void)cancelOrderInfo:(NSUInteger)order_id completion:(APICompletion)completion
{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setObject:@(order_id) forKey:@"order_id"];
    
    ASIFormDataRequest *request = createRequest(@"/v1/order/cancel",YES,@"POST",dic,self,completion);
    [request startAsynchronous];
}

+ (void)getWeiXinPayWithOrderID:(NSString *)order_id completion:(APICompletion)completion
{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setObject:order_id forKey:@"order_id"];
    
    ASIFormDataRequest *request = createRequest(@"/v1/order/weixin_pay",YES,@"POST",dic,self,completion);
    [request startAsynchronous];
}

+ (void)getAliPayWithOrderID:(NSString *)order_id completion:(APICompletion)completion
{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setObject:order_id forKey:@"order_id"];
    
    ASIFormDataRequest *request = createRequest(@"/v1/order/apipay_pay",YES,@"POST",dic,self,completion);
    [request startAsynchronous];
}

#pragma mark - 环信EaseMob
+ (void)getEasemobWelcomeMessageCompletion:(APICompletion)completion{
    ASIFormDataRequest *request = createRequest(@"/v1/easemob/welcome_message",YES,@"POST",nil,self,completion);
    [request startAsynchronous];
}

+ (void)getEasemobChatterProfileWithChatter:(NSString *)chatter completion:(APICompletion)completion{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setObject:chatter forKey:@"chatter"];
    
    ASIFormDataRequest *request = createRequest(@"/v1/easemob/account_profile",YES,@"POST",dic,self,completion);
    [request startAsynchronous];
}

+ (void)getEasemobGroupMumber:(NSString *)groupId completion:(APICompletion)completion
{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setObject:groupId forKey:@"groupId"];
    
    ASIFormDataRequest *request = createRequest(@"/v1/easemob/member_list",YES,@"POST",dic,self,completion);
    [request startAsynchronous];
}

+ (void)sayHelloUserNo:(NSString *)user_no completion:(APICompletion)completion
{
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    [dic setObject:user_no forKey:@"user_no"];
    
    ASIFormDataRequest *request = createRequest(@"/v1/easemob/hello",YES,@"POST",dic,self,completion);
    [request startAsynchronous];
}

@end
