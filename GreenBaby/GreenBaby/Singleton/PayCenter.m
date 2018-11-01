//
//  PayCenter.m
//  EHome
//
//  Created by LiXiangCheng on 15/6/29.
//  Copyright (c) 2015年 MeiLin. All rights reserved.
//

#import "PayCenter.h"

@interface PayCenter ()<PKPaymentAuthorizationViewControllerDelegate>{
}
@end

@implementation PayCenter

SINGLETON_IMP(PayCenter)

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc {
}

/* -------------   0.ApplePay  ------------- */

- (void)applePayActionDemo{
    //判断是否支持支付功能
    if ([PKPaymentAuthorizationViewController canMakePayments]) {//ios8.0以上
        //初始化订单请求对象
        PKPaymentRequest *requst = [[PKPaymentRequest alloc]init];
        
        //设置商品订单信息对象
        PKPaymentSummaryItem *widget1 = [PKPaymentSummaryItem summaryItemWithLabel:@"火锅" amount:[NSDecimalNumber decimalNumberWithString:@"0.01"]];
        
        PKPaymentSummaryItem *widget2 = [PKPaymentSummaryItem summaryItemWithLabel:@"自助" amount:[NSDecimalNumber decimalNumberWithString:@"0.01"]];
        
        PKPaymentSummaryItem *widget3 = [PKPaymentSummaryItem summaryItemWithLabel:@"烧烤" amount:[NSDecimalNumber decimalNumberWithString:@"0.01"]];
        
        //设置支付对象
        PKPaymentSummaryItem *total = [PKPaymentSummaryItem summaryItemWithLabel:@"FFIB" amount:[NSDecimalNumber decimalNumberWithString:@"0.03"]type:PKPaymentSummaryItemTypeFinal];
        requst.paymentSummaryItems = @[widget1 ,widget2 ,widget3 ,total];
        
        //设置国家地区编码
        requst.countryCode = @"CN";
        //设置国家货币种类 :人民币
        requst.currencyCode = @"CNY";
        //支付支持的网上银行支付方式
        requst.supportedNetworks =  @[PKPaymentNetworkChinaUnionPay, PKPaymentNetworkMasterCard, PKPaymentNetworkVisa];
        
        //设置的支付范围限制
        requst.merchantCapabilities = PKMerchantCapabilityEMV;
        // 这里填的是就是我们创建的merchat IDs
        requst.merchantIdentifier = @"merchant.com.ideal.ifont";
        
        //设置支付窗口
        PKPaymentAuthorizationViewController * payVC = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:requst];
        //设置代理
        payVC.delegate = self;
        if (!payVC) {
            //有问题  直接抛出异常
            @throw  [NSException exceptionWithName:@"CQ_Error" reason:@"创建支付显示界面不成功" userInfo:nil];
        }else
        {
            //支付没有问题,则模态出支付创口
            [[[AppDelegate sharedAppDelegate].window topViewController] presentViewController:payVC animated:YES completion:nil];
        }
    }
}

#pragma mark - PKPaymentAuthorizationViewControllerDelegate

//代理的回调方法
-(void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didAuthorizePayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion{
    //在这里将token和地址发送到自己的服务器，有自己的服务器与银行和商家进行接口调用和支付将结果返回到这里
    //我们根据结果生成对应的状态对象，根据状态对象显示不同的支付结构
    //状态对象
    NSLog(@"%@",payment.token);
    
    // When the async call is done, send the callback.
    // Available cases are:
    //    PKPaymentAuthorizationStatusSuccess, // Merchant auth'd (or expects to auth) the transaction successfully.
    //    PKPaymentAuthorizationStatusFailure, // Merchant failed to auth the transaction.
    //
    //    PKPaymentAuthorizationStatusInvalidBillingPostalAddress,  // Merchant refuses service to this billing address.
    //    PKPaymentAuthorizationStatusInvalidShippingPostalAddress, // Merchant refuses service to this shipping address.
    //    PKPaymentAuthorizationStatusInvalidShippingContact        // Supplied contact information is insufficient.
    //在这里了 为了测试方便 设置为支付失败的状态
    //可以选择枚举值PKPaymentAuthorizationStatusSuccess   (支付成功)
    PKPaymentAuthorizationStatus staus = PKPaymentAuthorizationStatusFailure;
    completion(staus);
}


//支付完成的代理方法
-(void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller{
    [controller dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"支付完成");
}

/* -------------   1.微信支付   ------------- */
#pragma mark - 微信支付

- (void)wxPayActionDemo{
    //本实例只是演示签名过程， 请将该过程在商户服务器上实现
    
    //创建支付签名对象
    payRequsestHandler *req = [[payRequsestHandler alloc] init];
    //初始化支付签名对象
    [req init:APP_ID mch_id:MCH_ID];
    //设置密钥
    [req setKey:PARTNER_ID];
    
    //获取到实际调起微信支付的参数后，在app端调起支付
    NSMutableDictionary *dict = [req sendPay_demo];
    
    if(dict == nil){
        //错误提示
        NSLog(@"%@\n\n",[req getDebugifo]);
    }else{
        NSLog(@"%@\n\n",[req getDebugifo]);
        //[self alert:@"确认" msg:@"下单成功，点击OK后调起支付！"];
        
        NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
        
        //调起微信支付
        PayReq* req             = [[PayReq alloc] init];
        req.openID              = [dict objectForKey:@"appid"];
        req.partnerId           = [dict objectForKey:@"partnerid"];
        req.prepayId            = [dict objectForKey:@"prepayid"];
        req.nonceStr            = [dict objectForKey:@"noncestr"];
        req.timeStamp           = stamp.intValue;
        req.package             = [dict objectForKey:@"package"];
        req.sign                = [dict objectForKey:@"sign"];
        
        [WXApi sendReq:req];
    }
    
}

-(void)wxPayActionWithDict:(NSDictionary *)dict{
    NSMutableString *stamp  = [dict objectForKey:@"timestamp"];
    
    //调起微信支付
    PayReq* req             = [[PayReq alloc] init];
    req.openID              = [dict objectForKey:@"appid"];
    req.partnerId           = [dict objectForKey:@"partnerid"];
    req.prepayId            = [dict objectForKey:@"prepayid"];
    req.nonceStr            = [dict objectForKey:@"noncestr"];
    req.timeStamp           = stamp.intValue;
    req.package             = [dict objectForKey:@"package"];
    if (!(req.package && req.package.length)) {
        req.package         = [dict objectForKey:@"_package"];
    }
    req.sign                = [dict objectForKey:@"sign"];
    
    [WXApi sendReq:req];
}

/* -------------   2.支付宝支付   ------------- */
#pragma mark - 支付宝支付

//点击订单模拟支付行为
-(void)aliPayActionDemo{
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order *order = [[Order alloc] init];
    order.partner = PartnerID;
    order.sellerID = SellerID;
    order.outTradeNO = [self generateTradeNO]; //订单ID（由商家自行制定）
    order.subject = @"千足金箍棒"; //商品标题
    order.body = @"千足金箍棒,这是测试数据"; //商品描述
    order.totalFee = [NSString stringWithFormat:@"%.2f",0.01]; //商品价格
    order.notifyURL =  @"http://www.xxx.com"; //回调URL
    
    order.service = @"mobile.securitypay.pay";
    order.paymentType = @"1";
    order.inputCharset = @"utf-8";
    order.itBPay = @"30m";
    order.showURL = @"m.alipay.com";
    
    //应用注册scheme,在Info.plist定义URL types
    NSString *appScheme = @"huijiame0405";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(PartnerPrivKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (!orderString) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        NSLog(@"orderString = %@",orderString);
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSInteger resultStatus=[resultDic[@"resultStatus"] integerValue];
            NSInteger pay_status=1;//"pay_status": //0，成功；1, 失败；2，取消；3，支付中
            switch (resultStatus) {
                case 9000:
                    pay_status=0;
                    NSLog(@"订单支付成功:reslut = %@",resultDic);
                    break;
                case 6001:
                    pay_status=2;
                    NSLog(@"用户中途取消:reslut = %@",resultDic);
                    break;
                case 6002:
                    pay_status=2;
                    NSLog(@"网络连接出错:reslut = %@",resultDic);
                    break;
                case 4000:
                    pay_status=1;
                    NSLog(@"订单支付失败:reslut = %@",resultDic);
                    break;
                /*
                 case 8000:
                 pay_status=3;
                 NSLog(@"正在处理中:reslut = %@",resultDic);
                 break;
                 */
                default:
                    NSLog(@"reslut = %@",resultDic);
                    //[[TKAlertCenter defaultCenter] postAlertWithMessage:resultDic[@"memo"]];
                    [[TKAlertCenter defaultCenter] postAlertWithMessage:@"支付失败!"];
                    break;
            }
            //发出消息
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_ALIPAY object:@(pay_status) userInfo:nil];
        }];
    }
}

//产生随机订单号
- (NSString *)generateTradeNO{
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = arc4random() % [sourceStr length];////通过arc4random() 获取0到x-1之间的整数: arc4random() % x
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}

-(void)aliPayActionWithOrderString:(NSString *)orderString{
    //应用注册scheme,在Info.plist定义URL types
    NSString *appScheme = @"huijiame0405";
    
    [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        NSInteger resultStatus=[resultDic[@"resultStatus"] integerValue];
        NSInteger pay_status=1;//"pay_status": //0，成功；1, 失败；2，取消；3，支付中
        switch (resultStatus) {
            case 9000:
                pay_status=0;
                NSLog(@"订单支付成功:reslut = %@",resultDic);
                break;
            case 6001:
                pay_status=2;
                NSLog(@"用户中途取消:reslut = %@",resultDic);
                break;
            case 6002:
                pay_status=2;
                NSLog(@"网络连接出错:reslut = %@",resultDic);
                break;
            case 4000:
                pay_status=1;
                NSLog(@"订单支付失败:reslut = %@",resultDic);
                break;
            /*
             case 8000:
             pay_status=3;
             NSLog(@"正在处理中:reslut = %@",resultDic);
             break;
             */
            default:
                NSLog(@"reslut = %@",resultDic);
                //[[TKAlertCenter defaultCenter] postAlertWithMessage:resultDic[@"memo"]];
                [[TKAlertCenter defaultCenter] postAlertWithMessage:@"支付失败!"];
                break;
        }
        //发出消息
        [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_ALIPAY object:@(pay_status) userInfo:nil];
    }];
}

@end
