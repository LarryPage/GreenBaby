//
//  FFRoute.m
//  FFRouter
//
//  Created by LiXiangCheng on 16/10/13.
//  Copyright © 2016年 wanda. All rights reserved.
//

#import "FFRoute.h"

@interface _FFRouteItem : NSObject

@property (nonatomic, strong) NSString *pattern;
@property (nonatomic, strong) id (^handlerBlock)(NSDictionary *parameters);
@property (nonatomic, strong) Class impClass;//用于调试

-(BOOL) isMatchURL:(NSURL *)url;//是否匹配: 先判断是否精确，若不是精确匹配，是否模糊匹配
-(BOOL) routeContainsWildcard;//是否包含模糊匹配字段

@end

@implementation _FFRouteItem

-(BOOL) isMatchURL:(NSURL *)url
{
    if(!url)
    {
        return NO;
    }
    NSArray *pathComponents = [(url.pathComponents ?: @[]) filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT SELF like '/'"]];
    pathComponents = [@[url.host] arrayByAddingObjectsFromArray:pathComponents];
    
    NSArray *patternPathComponents =[[self.pattern pathComponents] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT SELF like '/'"]];
    
    BOOL componentCountEqual = patternPathComponents.count == pathComponents.count;
    BOOL isMatch = NO;
    //精确匹配
    if(componentCountEqual)
    {
        isMatch = YES;
        for(int i =0 ; i < pathComponents.count ; i++)
        {
            NSString *pathComponent = pathComponents[i];
            NSString *patternPathComponent = patternPathComponents[i];
            if(![pathComponent isEqualToString:patternPathComponent])
            {
                isMatch = NO;
                break;
            }
        }
    }
    //没有精确匹配，进行模糊匹配
    if(!isMatch && [self routeContainsWildcard])
    {
        NSUInteger maxCount = MAX(patternPathComponents.count, pathComponents.count);
        isMatch = YES;
        for(int i =0 ; i < maxCount ; i++)
        {
            NSString *pathComponent = @"";
            if(i < pathComponents.count)
            {
                pathComponent= pathComponents[i];
            }
            NSString *patternPathComponent = @"";
            if(i < patternPathComponents.count)
            {
                patternPathComponent = patternPathComponents[i];
            }
            
            if([patternPathComponent isEqualToString:@"*"] || patternPathComponent.length == 0)
            {
                continue;
            }
            if(![pathComponent isEqualToString:patternPathComponent])
            {
                isMatch = NO;
                break;
            }
        }
    }
    
    return isMatch;
}

-(BOOL) routeContainsWildcard
{
    return !NSEqualRanges([self.pattern rangeOfString:@"*"], NSMakeRange(NSNotFound, 0));
}

@end

@interface NSString (FFRoute)

- (NSString *)FFRoute_URLDecodedString;
- (NSDictionary *)FFRoute_URLParameterDictionary;

@end


@implementation NSString (FFRoute)

- (NSString *)FFRoute_URLDecodedString {
    NSString *input = [self stringByReplacingOccurrencesOfString:@"+" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, self.length)];
    //return [input stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return [input stringByRemovingPercentEncoding];
}

- (NSDictionary *)FFRoute_URLParameterDictionary {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (self.length && [self rangeOfString:@"="].location != NSNotFound) {
        NSArray *keyValuePairs = [self componentsSeparatedByString:@"&"];
        for (NSString *keyValuePair in keyValuePairs) {
            NSArray *pair = [keyValuePair componentsSeparatedByString:@"="];
            NSString *paramValue = pair.count == 2 ? pair[1] : @"";
            parameters[[pair[0] lowercaseString]] = [paramValue FFRoute_URLDecodedString] ?: @"";
        }
    }
    return parameters;
}

@end

static NSMutableDictionary *routeControllersMap = nil;

@interface FFRoute()

@property (nonatomic, strong) NSMutableArray *routeItems;

@end

@implementation FFRoute

- (id)init {
    if ((self = [super init])) {
        self.routeItems = [NSMutableArray array];
    }
    return self;
}

+ (instancetype)routeForScheme:(NSString *)scheme
{
    FFRoute *routesController = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        routeControllersMap = [[NSMutableDictionary alloc] init];
    });
    
    if (!routeControllersMap[scheme]) {
        routesController = [[self alloc] init];
        routesController.scheme = scheme;
        routeControllersMap[scheme] = routesController;
    }
    
    routesController = routeControllersMap[scheme];
    return routesController;
}


- (void)addRoute:(NSString *)routePattern handler:(id (^)(NSDictionary *parameters))handlerBlock impClass:(Class)impClass
{
    _FFRouteItem * routeItem = [[_FFRouteItem alloc] init];
    routeItem.pattern = routePattern;
    routeItem.handlerBlock = handlerBlock;
    routeItem.impClass = impClass;
    
    if (!routeItem.handlerBlock) {
        routeItem.handlerBlock = [^BOOL (NSDictionary *params) {
            return YES;
        } copy];
    }
    
    BOOL isExist = NO;
    for (_FFRouteItem * item in self.routeItems)
    {
        if([item.pattern isEqualToString:routePattern])
        {
            isExist = YES;
            break;
        }
    }
    NSString * tips = [NSString stringWithFormat:@"lxc温馨提示:%@已被人抢注,请更换",routePattern];
    NSAssert(!isExist,tips);
    if(!isExist)
    {
        [self.routeItems addObject:routeItem];
    }
    
}

- (void)removeRoute:(NSString *)routePattern
{
    NSUInteger routeIndex = NSNotFound;
    NSUInteger index = 0;
    
    for (_FFRouteItem *route in self.routeItems) {
        if ([route.pattern isEqualToString:routePattern]) {
            routeIndex = index;
            break;
        }
        index++;
    }
    
    if (routeIndex != NSNotFound) {
        [self.routeItems removeObjectAtIndex:routeIndex];
    }
}

- (id)routeURL:(NSURL *)URL
{
    return  [self routeURL:URL withParameters:nil];
}
- (id)routeURL:(NSURL *)URL withParameters:(NSDictionary *)parameters
{
    return [self routeURL:URL withParameters:parameters executeRouteBlock:YES completed:nil];
}

- (id)routeURL:(NSURL *)URL withParameters:(NSDictionary *)parameters completed:(void (^)(id result))completedBlock
{
    return [self routeURL:URL withParameters:parameters executeRouteBlock:YES completed:completedBlock];
}


- (BOOL)canRouteURL:(NSURL *)URL
{
    return [self routeURL:URL withParameters:nil executeRouteBlock:NO completed:nil];
}

-(id)routeURL:(NSURL *)URL withParameters:(NSDictionary *)parameters executeRouteBlock:(BOOL)executeRouteBlock completed:(void (^)(id result))completedBlock
{
    if(!URL)
    {
        return nil;
    }
    id didRoute = nil;
    
    if (!executeRouteBlock)
    {
        if(FF_ROUTE_LOG_ENABLED)
        {
            CLog(@"开始查询路由。。。。");
        }
    }
    _FFRouteItem * matchedRoute = nil;
    for (_FFRouteItem *route in self.routeItems)
    {
        if([route isMatchURL:URL])
        {
            if (!executeRouteBlock)
            {
                return @(YES);
            }
            matchedRoute = route;
            
            if(![matchedRoute routeContainsWildcard])//不包含模糊匹配，精准匹配
            {
                break;
            }
            
        }
    }
    if(!matchedRoute)
    {
        if(FF_ROUTE_LOG_ENABLED)
        {
            CLog(@"URL:%@ 没有被任何imp注册",[URL absoluteString]);
        }
    }
    else
    {
        if(FF_ROUTE_LOG_ENABLED)
        {
            CLog(@"找到匹配路由:%@",matchedRoute.pattern);
        }
        NSMutableDictionary *finalParameters = [NSMutableDictionary dictionary];
        NSDictionary *queryParameters = [URL.query FFRoute_URLParameterDictionary];
        [finalParameters addEntriesFromDictionary:queryParameters];//url参数
        [finalParameters addEntriesFromDictionary:parameters];//复杂参数
        finalParameters[kFFRoutePatternKey] = matchedRoute.pattern;
        finalParameters[kFFRouteURLKey] = URL;
        finalParameters[kFFRouteSchemeKey] = self.scheme ?: [NSNull null];
        if(completedBlock)
        {
            finalParameters[kFFRouteCompleteBlockKey] = completedBlock;
        }
        if(FF_ROUTE_LOG_ENABLED)
        {
            CLog(@"匹配路由参数:%@",finalParameters);
            CLog(@"开始执行Route回调block,impClass为:%@",matchedRoute.impClass);
        }
        didRoute = matchedRoute.handlerBlock(finalParameters);
        if(FF_ROUTE_LOG_ENABLED)
        {
            CLog(@"结束执行Route回调block");
        }
    }
    return didRoute;
}

@end
