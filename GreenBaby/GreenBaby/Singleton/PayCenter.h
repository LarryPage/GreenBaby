//
//  PayCenter.h
//  EHome
//
//  Created by LiXiangCheng on 15/6/29.
//  Copyright (c) 2015年 MeiLin. All rights reserved.
//

#import <Foundation/Foundation.h>

/* -------------   0.ApplePay  ------------- */
#import <PassKit/PassKit.h>
#import <AddressBook/AddressBook.h>
//http://www.jianshu.com/p/f821749cd8f6?utm_campaign=haruki&utm_content=note&utm_medium=reader_share&utm_source=qq

/* -------------   1.微信支付   ------------- */
#import "WXApi.h"
#import "WXApiObject.h"
#import "payRequsestHandler.h"
//https://pay.weixin.qq.com/

/* -------------   2.支付宝支付   ------------- */
#import "Order.h"
#import "DataSigner.h"
#import <AlipaySDK/AlipaySDK.h>//http://blog.sina.com.cn/s/blog_916e0cff0102vath.html
//  https://b.alipay.com/order/productDetail.htm?productId=2014110308141993
//  提示：如何获取安全校验码和合作身份者id
//  1.用您的签约支付宝账号登录支付宝网站(www.alipay.com)
//  2.点击“商家服务”(https://b.alipay.com/order/myorder.htm)
//  3.点击“查询合作者身份(pid)”、“查询安全校验码(key)”
//

//合作身份者ID,以 2088 开头由 16 位纯数字组成的字符串。请参考“7.1 如何获得PID与 密钥”
#define PartnerID @"2088021101527281"
//支付宝收款账号,手机号码或邮箱格式
#define SellerID  @"apple@huijiame.com"

//安全校验码（MD5）密钥，以数字和字母组成的32位字符
#define MD5_KEY @"n7z5w77syjo89pcekk7v526e60mmhbfp"

//商户方的私钥,pkcs8 格式
#define PartnerPrivKey @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBAKgZw+3NulbhwrEzkONEfSpwac7faEj/H8zhUUsl4dUQPES+MVNNeTk0oDiRzJF7RDSW+CZVQpk6aNXstm6xUiAU5h6tz9GLzNtp7IwRj20PVB1lWdl5Dh3fQLhmQXKtigGLxBVw946/Gb2IcmxzoXGL5CsPqTIDHe585e15drIzAgMBAAECgYBZkaD8TOpE8PY0RS2maw/mVQ+L0y5V9tqS6FvQltbGGGiEmHLf2CAHgyr7+XPu8Kde/jIq+rMJwj2p/v8V7BW9dQeAZyREiSdkl8hiFLLMH/p4Huqf0LwSqPj7SPtPEUhMre3L5lIdbKFL7HHBnMEdewh3+tTP8m0tNakPv2CEwQJBANp6Ctm+iWGa2xMGpTADMUoiK7a4ioQ6kGuJhtC++pity+d5d0iH2k+rdnIpNuuZGM43j/Vb/brZHEfL7BkhQxUCQQDE+MssTIxkSXooeIJSDuVcZpwLoFIZRvKVWmF8PhWxzstERBgsyncKJ4sxwBqBYqYRUmH0fzX9Gk3CON+XdhInAkBYHjs8IbaFcJEFtntvxwndTbT16K6tsHVJelmu3ihy5j5EqWAsF+c8lPqcBvWIxuITYqOkoarP7vuSFbSvWhQVAkEArY/c14gMHUJxlb+6dbwSdr0ju0rljMhrcRdW1zeNvkPN8LVf5/fvtM7rZEc2E9RtKM5C6kI9vGy1H/Mlcjzj+QJAPBWKYJJ9eKlVbkJPxW5DaroqIj980JADvHqXEGAGkH1YwFB+ki/2uh6KRBmqtijgPtIRP2cqvyXn87uTyA1G0g=="


//支付宝公钥
#define AlipayPubKey   @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCnxj/9qwVfgoUh/y2W89L6BkRAFljhNhgPdyPuBV64bfQNN1PjbCzkIM6qRdKBoLPXmKKMiFYnkd6rAoprih3/PrQEB/VsW8OoM8fxn67UDYuyBTqA23MML9q1+ilIZwBC2AQ2UBVOrFXfFl75p6/B5KsiNG9zpgmLCUYuLkxpLQIDAQAB"


@interface PayCenter : NSObject

SINGLETON_DEF(PayCenter)

/* -------------   0.ApplePay  ------------- */
-(void)applePayActionDemo;

/* -------------   1.微信支付   ------------- */
-(void)wxPayActionDemo;
-(void)wxPayActionWithDict:(NSDictionary *)dict;

/* -------------   2.支付宝支付  ------------- */
-(void)aliPayActionDemo;
-(void)aliPayActionWithOrderString:(NSString *)orderString;
@end