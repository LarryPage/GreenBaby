//
//  APIQN.m
//  GreenBaby
//
//  Created by LiXiangCheng on 15/7/30.
//  Copyright (c) 2015年 LiXiangCheng. All rights reserved.
//

#import "APIQN.h"
#import "APIParseErrorViewController.h"

#import "QiniuConfig.h"
#import "QiniuUtils.h"
#import "QiniuSimpleUploader.h"

@implementation APIQN

+ (NSString *)tokenWithScope:(NSString *)scope{
    QiniuPutPolicy *policy = [QiniuPutPolicy new];
    policy.scope = scope;
    
    return [policy makeToken:QiniuAccessKey secretKey:QiniuSecretKey];
}

+ (void)uploadFile:(NSString *)filePath
               key:(NSString *)key
             scope:(NSString *)scope//QiniuBucketNameMsgPic
             extra:(QiniuPutExtra *)extra//默认传nil
          complete:(QNUpCompletion)completion{
    [ASIHTTPRequest setDefaultTimeOutSeconds:180];
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:kQiniuUpHost]];
    // YES is the default, you can turn off gzip compression by setting this to NO
    [request setAllowCompressedResponse:AllowCompressedResponse];//gzip
    [request addRequestHeader:@"Content-Type" value:@"multipart/form-data"];
    [request addRequestHeader:@"Accept" value:@"application/json"];
    [request addRequestHeader:@"User-Agent" value:kQiniuUserAgent];
    
    // multipart body
    [request addPostValue:[APIQN tokenWithScope:scope] forKey:@"token"];
    if (![key isEqualToString:kQiniuUndefinedKey]) {
        [request addPostValue:key forKey:@"key"];
    }
    NSString *mimeType = nil;
    if (extra) {
        mimeType = extra.mimeType;
        if (extra.checkCrc == 1) {
            [request addPostValue: [NSString stringWithFormat:@"%@", @(extra.crc32)] forKey:@"crc32"];
        }
        for (NSString *key in extra.params) {
            [request addPostValue:[extra.params objectForKey:key] forKey:key];
        }
    }
    if (mimeType != nil) {
        [request addFile:filePath withFileName:filePath andContentType:mimeType forKey:@"file"];
    } else {
        [request addFile:filePath forKey:@"file"];
    }
    
    request.delegate = self;
    [request setValidatesSecureCertificate:NO];// As your certificate is self-signed, iOS can't validate the certificate
    request.uploadProgressDelegate = self;
    request.userInfo = @{@"filePath": filePath, @"Completion": completion};
    [request startAsynchronous];
}

#pragma mark - ASIHTTPRequestDelegate

- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes{
}

+ (void)requestStarted:(ASIHTTPRequest *)request {
    CLog(@"开始调用 %@", request.url);
}

+ (void)requestFinished:(ASIHTTPRequest *)request {
    NSString *filePath = request.userInfo[@"filePath"];
    QNUpCompletion completion = request.userInfo[@"Completion"];// 得到调用完成后执行的Block
    
    int statusCode = [request responseStatusCode];
    if (statusCode == 200) { // Success!
        // 将JSON Data解析为Foundation Object(NSDictionary)
        NSError *error = nil;
        NSString *responseString = [[NSString alloc] initWithData:[request responseData] encoding:NSUTF8StringEncoding];
        CLog(@"responseString : %@",responseString);
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:request.responseData options:0 error:&error];
        if (!error)
        {
            completion(nil, filePath, responseDic);
        }
        else  // JSON解析失败
        {
            NSError *newError = [NSError errorWithDomain:@"数据格式解析失败"
                                                    code:error.code
                                                userInfo:error.userInfo];
            completion(newError, filePath, nil);
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
    } else { // Server returns an error code.
        [self requestFailed:request];
    }
    
    [ASIHTTPRequest setDefaultTimeOutSeconds:[ASIHTTPRequest defaultTimeOutSeconds]];
}

+ (void)requestFailed:(ASIHTTPRequest *)request {
    NSString *filePath = request.userInfo[@"filePath"];
    QNUpCompletion completion = request.userInfo[@"Completion"];
    
    NSError *error = qiniuErrorWithRequest(request);
    NSString *domain=@"";
    if (error.userInfo && error.userInfo.count>0 && error.userInfo[kQiniuErrorKey]) {
        domain=error.userInfo[kQiniuErrorKey];
    }
    else{
        if (![Reachability reachabilityForInternetConnection].isReachable){
            domain=@"当前无法连接到网络";
        }
        else{
            domain=@"连接超时";
        }
    }
    
    
    NSError *newError = [NSError errorWithDomain:domain
                                            code:error.code
                                        userInfo:error.userInfo];
    completion(newError, filePath, nil);
    
    [ASIHTTPRequest setDefaultTimeOutSeconds:[ASIHTTPRequest defaultTimeOutSeconds]];
}

@end
