//
//  API.h
//  本类用于对所有的API进行一层封装，方便各处调用
//
//  Created by LiXiangCheng on 15/7/28.
//  Copyright (c) 2015年 LiXiangCheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APIParseErrorViewController.h"

typedef enum ApiType {
    kApiTypeGet,                      // Get方式
    kApiTypeGetImage,                 // Get方式,DownImage下载图片
    kApiTypeGetFile,                  // Get方式,DownFile下载文件
    kApiTypeDelete,                   // Delete方式
    kApiTypePut,                      // Put方式
    kApiTypePost,                     // Post方式
    kApiTypePostMultipartFormData,    // Post方式,Multipart上传文件
}ApiType;

/**
 *  API PostMultipart请求要上传文件Block
 *
 *  @param formData 上传文件数据
 */
typedef void (^APIFormData)(id <AFMultipartFormData> formData);
/**
 *  API请求的进度Block
 *
 *  @param progress GET请求的下载进度Block|POST请求的上传进度Block
 */
typedef void (^APIProgress)(NSProgress *progress);
/**
 *  API请求的回调Block
 *
 *  @param error 返回的错误信息，如果调用成功则为nil，调用失败则通过error.domain获取错误信息
 *  @param response 返回的数据，数据类型如下:
 *  ApiType=kApiTypeGetImage    response:UIImage
 *  ApiType=kApiTypeGetFile     response:NSData
 *  ApiType=其他类型(默认)        response:NSDictionary,等于API输出数据中"data"字段中的内容
 */
typedef void (^APICompletion)(NSError *error, id response);

@interface API : NSObject

#pragma mark - base

/**
 *  获取API的URLStr
 *
 *  @return 基础URLStr http://api.abc.com
 */
+ (NSString *)apiUrl;

/**
 *  获取API的基础URL
 *
 *  @return 基础URL http://api.abc.com
 */
+ (NSURL *)baseUR;

/**
 *  根据API路径获取完整的URL
 *
 *  @param path API路径 /index.php
 *
 *  @return 完整的NSURL http://api.abc.com/index.php
 */
+ (NSURL *)fullURLWithPath:(NSString *)path;

/**
 *  请求包加密
 *
 *  @param pathParam API路径+参数(GET|DELETE)  /index.php?key1=value1&key2=value2
 *
 *  @return
 */
+ (void)encryptRequestWithManager:(AFHTTPSessionManager *)manager pathParam:(NSString *)pathParam;

/*
 *HTTPS,客户端自带证书
 */
+ (AFSecurityPolicy *)customSecurityPolicyWithCerName:(NSString *)cerName;

/*
 *默认模式，HTTPS,客户端不自带证书
 */
+ (AFSecurityPolicy *)defaultSecurityPolicy;

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
+ (void)executeRequestWithPath:(NSString *)path paramDic:(NSDictionary *)paramDic auth:(BOOL)auth apiType:(ApiType)apiType formdataBlock:(APIFormData)formdataBlock progressBlock:(APIProgress)progressBlock completionBlock:(APICompletion)completionBlock;

/*
 *解析数据
 */
+ (void)parseResponseWithTask:(NSURLSessionDataTask *)task error:(NSError *)error response:(id)response path:(NSString *)path paramDic:(NSDictionary *)paramDic apiType:(ApiType)apiType completionBlock:(APICompletion)completionBlock;

#pragma mark - common
/*
 *获取最新版本信息
 */
+ (void)appVersionCheckOnCompletion:(APICompletion)completion;

/**
 *  APNS  pushToken注册
 */
+ (void)regPushToken:(NSString *)pushToken completion:(APICompletion)completion;

/**
 *  上传通讯录
 */
+ (void)postContacts:(NSString *)contacts completion:(APICompletion)completion;

/**
 *  获取公共数据
 */
+ (void)getPublicDataOnCompletion:(APICompletion)completion;

/*
 *  获取消息数
 */
+ (void)getMessageCountOnCompletion:(APICompletion)completion;

/**
 *  获取欢迎图
 */
+ (void)getWelcomeImgOnCompletion:(APICompletion)completion;

/**
 *  更新推送状态
 */
+ (void)updatePushStatusOnCompletion:(APICompletion)completion;

/**
 *  下载头像图片,response:UIImage
 */
+ (void)downloadAvatarWithProgress:(APIProgress)progress
                        completion:(APICompletion)completion;

/**
 *  下载头像文件,response:NSData
 */
+ (void)downloadAvatarFileWithProgress:(APIProgress)progress
                            completion:(APICompletion)completion;

/*
 *  上传头像图片
 */
+ (void)uploadAvatar:(NSData *)fileData
            progress:(APIProgress)progress
          completion:(APICompletion)completion;

/*
 *  登录
 */
+ (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
               completion:(APICompletion)completion;

/*
 *  注册
 */
+ (void)regWithUsername:(NSString *)username
               password:(NSString *)password
                   code:(NSString *)code
             completion:(APICompletion)completion;
/*
 *  获取手机验证码
 */
+ (void)sendCodeWithMobile:(NSString *)mobile
                completion:(APICompletion)completion;

/*
 *  验证code
 */
+ (void)validateCodeWithMobile:(NSString *)mobile
                          code:(NSString *)code
                    completion:(APICompletion)completion;

#pragma mark - Talk
/**
 *  获取用户新消息列表
 *
 *  @param page       page description
 *  @param count      count description
 *  @param startid    startid：起始消息编号。（可选，默认为0，用于过滤此编号以后的新数据）
 *  @param completion completion description
 */
+ (void)getMsgListWithPage:(NSUInteger)page
                     count:(NSUInteger)count
                   startid:(NSUInteger)startid
                completion:(APICompletion)completion;

/**
 *  获取用户对话消息列表
 */
+ (void)getMessageWithTouid:(NSInteger)touid//对方用户编号（必选）
                  fetch_new:(NSInteger)fetch_new//获取新消息。（可选，1获取新消息，0获取历史消息）
                    startid:(NSInteger)startid//起始消息编号。（可选，默认为0）
                      count:(NSUInteger)count//每页的数量。（可选，默认为10）
                 completion:(APICompletion)completion;

/**
 *  用户给好友发送一条消息
 */
+ (void)sendMessageWithTouid:(NSInteger)touid//对方用户编号（必选）
                     startid:(NSInteger)startid//起始消息编号。（可选，默认为0）
                    msg_type:(NSInteger)msg_type//消息类型（1文本含emoji，2表示图片）
                     content:(NSString *)content//消息内容(1文本含emoji,2:[图片])
                       image:(NSString *)image//图片信息(url+width+height)
                  completion:(APICompletion)completion;

#pragma mark - 订单&支付
/*
 *获取订单信息
 */
+ (void)getOrderInfo:(NSUInteger)order_id completion:(APICompletion)completion;

/*
 *取消订单
 */
+ (void)cancelOrderInfo:(NSUInteger)order_id completion:(APICompletion)completion;

/*
 *微信支付信息
 */
+ (void)getWeiXinPayWithOrderID:(NSString *)order_id completion:(APICompletion)completion;

/*
 *支付宝支付信息
 */
+ (void)getAliPayWithOrderID:(NSString *)order_id completion:(APICompletion)completion;

#pragma mark - 环信EaseMob
/**
 *  获取初始会话消息
 */
+ (void)getEasemobWelcomeMessageCompletion:(APICompletion)completion;

/**
 *  获取环信id简介(用户或群组）
 */
+ (void)getEasemobChatterProfileWithChatter:(NSString *)chatter completion:(APICompletion)completion;

/*
 * 获取群成员列表
 */
+ (void)getEasemobGroupMumber:(NSString *)groupId completion:(APICompletion)completion;

/*
 *打呼呼接口  user_no：环信用户编号（必选）
 */
+ (void)sayHelloUserNo:(NSString *)user_no completion:(APICompletion)completion;

@end
