//
//  API.h
//  本类用于对所有的API进行一层封装，方便各处调用
//
//  Created by LiXiangCheng on 15/7/28.
//  Copyright (c) 2015年 LiXiangCheng. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  API请求的回调Block
 *
 *  @param error 返回的错误信息，如果调用成功则为nil，调用失败则通过error.domain获取错误信息
 *  @param responseDic 返回的数据，等于API输出数据中"data"字段中的内容
 */
typedef void (^APICompletion)(NSError *error, id responseDic);

@interface API : NSObject

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

/*
 *  更新头像信息
 */
+ (void)updateAvatar:(NSData *)fileData completion:(APICompletion)completion;

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
