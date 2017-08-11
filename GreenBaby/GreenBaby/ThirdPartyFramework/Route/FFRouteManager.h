//
//  FFRouteManager.h
//  FFRouteManager
//
//  Created by LiXiangCheng on 16/10/14.
//  Copyright © 2016年 wanda. All rights reserved.
//

/*
 使用方式：
        1.调度方式统一使用NSURL
        2.URL的Scheme统一为：greenbaby,内部：greenbabyin，外部：greenbabyout 例如：greenbabyin://marketing/scan?adddd=dafdf&afdfsadfsdf=123445
        3.绑定URL和事件处理回调Block，在程序初始化时，直接在内存中绑定事件URL和具体事件回调block的方式:
        + (void)addRoute:(NSString *)routePattern handler:(BOOL (^)(NSDictionary *parameters))handlerBlock impClass:(Class)impClass;
        4.执行Route操作
        + (BOOL)routeURL:(NSURL *)URL;
 
        备注：
        支持模糊匹配，模糊匹配符为"*"
        例如 greenbabyin://marketing/scan?adddd=dafdf&afdfsadfsdf=123445 能被greenbabyin://marketing/ * 匹配 也能被greenbabyin:// * /scan匹配
        模糊匹配优先级低于精确匹配
 */

#import <Foundation/Foundation.h>
#import "FFRoute.h"

@protocol FFRouteImpProtocol <NSObject>

@required
-(void) registerRoute;

@end



@interface FFRouteManager : NSObject

//初始化函数，在主程序中调用一次
+(void) addRouteImps:(NSArray <id<FFRouteImpProtocol>>*) Imps;

//用于FFRouteImp绑定处理回调
+ (void)addRoute:(NSString *)routePattern handler:(id (^)(NSDictionary *parameters))handlerBlock impClass:(Class)impClass;
//用于FFRouteImp去除绑定回调
+ (void)removeRoute:(NSString *)routePattern;

//执行Route操作
+ (id)routeURL:(NSURL *)URL;
//执行Route操作带复杂上下文参数
+ (id)routeURL:(NSURL *)URL withParameters:(NSDictionary *)parameters;
//执行Route操作，route完成后执行block
+ (id)routeURL:(NSURL *)URL withParameters:(NSDictionary *)parameters completed:(void (^)(id result))completedBlock;

//执行Route操作
+ (id)routeURLStr:(NSString *)URLStr;
//执行Route操作带复杂上下文参数
+ (id)routeURLStr:(NSString *)URLStr withParameters:(NSDictionary *)parameters;
//执行Route操作，route完成后执行block
+ (id)routeURLStr:(NSString *)URLStr withParameters:(NSDictionary *)parameters completed:(void (^)(id result))completedBlock;

//执行Route降级操作
+ (void)routeReduceURL:(NSURL *)URL;

//执行Route降级操作
+ (void)routeReduceURLStr:(NSString *)URLStr;

//判断当前URL是否支持Scheme
+ (BOOL)supportSchemeURL:(NSURL *)URL;
//判断当前URL是否可以Route
+ (BOOL)canRouteURL:(NSURL *)URL;

//判断当前URLStr是否支持Scheme
+ (BOOL)supportSchemeURLStr:(NSString *)URLStr;
//判断当前URLStr是否可以Route
+ (BOOL)canRouteURLStr:(NSString *)URLStr;

+ (NSString *)APPScheme;
//内部跳转Scheme
+ (NSString *)APPInScheme;
//外部跳转Scheme
+ (NSString *)APPOutScheme;

//判断是否是http,https开口的url
+ (BOOL)isHttpURL:(NSURL *)URL;

//判断是否是http,https开口的url
+ (BOOL)isHttpURLStr:(NSString *)URLStr;

@end
