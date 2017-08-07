//
//  FFRoute.h
//  FFRouter
//
//  Created by LiXiangCheng on 16/10/13.
//  Copyright © 2016年 wanda. All rights reserved.
//

#import <Foundation/Foundation.h>

//日志输出开关
#define FF_ROUTE_LOG_ENABLED  1

static NSString *const kFFRoutePatternKey = @"FFRoutePattern";
static NSString *const kFFRouteURLKey = @"FFRouteURL";
static NSString *const kFFRouteSchemeKey = @"FFRouteScheme";
static NSString *const kFFRouteCompleteBlockKey = @"FFRouteCompleteBlock";

@interface FFRoute : NSObject

@property (nonatomic, copy) NSString *scheme;

+ (instancetype)routeForScheme:(NSString *)scheme;

//添加Route
- (void)addRoute:(NSString *)routePattern handler:(id (^)(NSDictionary *parameters))handlerBlock impClass:(Class)impClass;

//册除Route
- (void)removeRoute:(NSString *)routePattern;

//执行Route操作
- (id)routeURL:(NSURL *)URL;

//执行Route操作,带复杂参数
- (id)routeURL:(NSURL *)URL withParameters:(NSDictionary *)parameters;

//执行Route操作,带复杂参数,Route完成后执行block
- (id)routeURL:(NSURL *)URL withParameters:(NSDictionary *)parameters completed:(void (^)(id result))completedBlock;

//判断当前URL是否可以Route
- (BOOL)canRouteURL:(NSURL *)URL;

@end
