//
//  APIQN.m
//  GreenBaby
//
//  Created by LiXiangCheng on 15/7/30.
//  Copyright (c) 2015年 LiXiangCheng. All rights reserved.
//

#import "APIQN.h"
#import "APIParseErrorViewController.h"

@implementation APIQN

NSString *tokenWithScope(NSString *scope){
    QiniuPutPolicy *policy = [QiniuPutPolicy new];
    policy.scope = scope;
    
    return [policy makeToken:QiniuAccessKey secretKey:QiniuSecretKey];
}

+ (void)uploadFile:(NSString *)filePath
               key:(NSString *)key
             scope:(NSString *)scope//QiniuBucketNameImg
             extra:(QiniuPutExtra *)extra//默认传nil
     progressBlock:(APIProgress)progressBlock
   completionBlock:(QNUpCompletion)completionBlock{
    AFHTTPSessionManager* manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kQiniuUpHost]];
    //0.设置安全策略
    [manager setSecurityPolicy:[AFSecurityPolicy defaultPolicy]];
    //1.构造requestSerializer
    //设置cookie,默认YES，允许请求带cookies，响应设置cookies，风控针对一些接口如登录必须使用
    [manager.requestSerializer setHTTPShouldHandleCookies:NO];
    //设置超时
    manager.requestSerializer.timeoutInterval = 180;//默认60
    //设置Content-Type
    //[manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    //[manager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    //设置User-Agent
    [manager.requestSerializer setValue:kQiniuUserAgent forHTTPHeaderField:@"User-Agent"];
    //2.构造responseSerializer
    manager.responseSerializer = [AFJSONResponseSerializer serializer];//application/json
    //manager.responseSerializer = [AFXMLParserResponseSerializer serializer];//application/xml
    //设置Status Code接受范围，默认200-300
    //manager.responseSerializer.acceptableStatusCodes=[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
    //服务端不关心 contentType，因此客户端不做验证
    manager.responseSerializer.acceptableContentTypes = nil;
    //manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json; charset=utf-8",@"text/json", @"text/plain", nil];
    
    NSLog(@"开始调用 %@", kQiniuUpHost);
    
    NSMutableDictionary *paramDic=[NSMutableDictionary dictionary];
    [paramDic setObject:tokenWithScope(scope) forKey:@"token"];
    if (![key isEqualToString:kQiniuUndefinedKey]) {
        [paramDic setObject:key forKey:@"key"];
    }
    NSString *mimeType = nil;
    if (extra) {
        mimeType = extra.mimeType;
        if (extra.checkCrc == 1) {
            [paramDic setObject:[NSString stringWithFormat:@"%@", @(extra.crc32)] forKey:@"crc32"];
        }
        for (NSString *key in extra.params) {
            [paramDic setObject:[extra.params objectForKey:key] forKey:key];
        }
    }
    
    APIFormData formdata = ^(id <AFMultipartFormData> formData){
        if (mimeType != nil) {
            [formData appendPartWithFileData:[NSData dataWithContentsOfFile:filePath] name:@"file" fileName:filePath mimeType:mimeType];
        } else {
            [formData appendPartWithFileData:[NSData dataWithContentsOfFile:filePath] name:@"file" fileName:filePath mimeType:@"image/jpeg"];
        }
    };
    
    
    [manager POST:@""
       parameters:paramDic
constructingBodyWithBlock:formdata
         progress:^(NSProgress *downloadProgress)
     {
         if(progressBlock)
             progressBlock(downloadProgress);
     }
          success:^void(NSURLSessionDataTask * task, id response)
     {
         parseQNResponse(task,nil,response,filePath,paramDic,completionBlock);
     }
          failure:^ void(NSURLSessionDataTask * task, NSError * error)
     {
         parseQNResponse(task,error,nil,filePath,paramDic,completionBlock);
     }];
}

void parseQNResponse(NSURLSessionDataTask *task,NSError *error,id response,NSString *filePath,NSDictionary *paramDic,QNUpCompletion completionBlock)
{
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
                                                code:error.code
                                            userInfo:error.userInfo];
        completionBlock(newError, filePath, nil);
        
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
            NSString *html=[NSString stringWithFormat:@"%@<body>Url:<br>%@<br><br>filePath:<br>%@<br><br>Method:<br>%@<br><br>param:<br>%@<br><br>postData:<br>%@<br><br>Headers:<br>%@<br><br></body><br>responseString:<br>%@",style,task.currentRequest.URL,filePath,task.currentRequest.HTTPMethod,paramDic,[[NSString alloc] initWithData:task.currentRequest.HTTPBody encoding:NSUTF8StringEncoding],task.currentRequest.allHTTPHeaderFields,responseString];
            UIViewController *curVC=[[AppDelegate sharedAppDelegate].window topViewController];
            UIViewController *post = [[APIParseErrorViewController alloc] initWithHtml:html title:@"API调用失败"];
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:post];
            nc.navigationBar.translucent = NO;
            [curVC presentViewController:nc animated:YES completion:nil];
        }
#endif
    }
    else{
        completionBlock(nil, filePath, response);
    }
}

@end
