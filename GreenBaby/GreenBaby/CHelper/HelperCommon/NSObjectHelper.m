//
//  NSObject+AutoParser.m
//  AutoParser
//
//  Created by LiXiangCheng on 16/9/16.
//  Copyright (c) 2016年 Wanda Inc All rights reserved.
//

#import "NSObjectHelper.h"

/**
 1.nscache 是可以自动释放内存的。
 2.nscache是线程安全的，我们可以在不同的线程中添加，删除和查询缓存中的对象。
 3.一个缓存对象不会拷贝key对象
 
 缓存要解析的类的属性{"ClassName":propertiesDic}=Table scheme
 countLimit=500
 最大缓存500个Model定义,1个model按10个左右属性，大约0.1K，500个model点内存50K
 */
static NSCache *gPropertiesOfClass = nil;
/**
 缓存要解析的类中不一致的propertyName与josnKeyName
 countLimit=500
 最大缓存500个Model定义（同上）
 */
static NSCache *gReplacedKeyMapsOfClass = nil;
/**
 缓存不要处理(解析或归档)的的类的propertyName
 countLimit=500
 最大缓存500个Model定义（同上）
 */
static NSCache *gIgnoredPropertyNamesOfClass = nil;
/** 缓存要保存的类的历史记录{"ClassName":RecordDicArray}=Table Data */
static NSMutableDictionary *gRecordDicOfClass = nil;
/** 缓存要保存的类的当前记录{"ClassName":RecordDic}=Table row */
static NSMutableDictionary *gCurRecordDicOfClass = nil;
/** 缓存数据库操作队列 */
static FMDatabaseQueue *gFMDBQueue = nil;

@implementation NSObject (Helper)

/** NSObject提供 的performSelector最多只支持两个参数,针对NSObject增加了如下扩展 */
- (id)performSelector:(SEL)selector withObjects:(NSArray *)objects {
    NSMethodSignature *signature = [self methodSignatureForSelector:selector];
    if (signature) {
        NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:self];
        [invocation setSelector:selector];
        for(int i = 0; i < [objects count]; i++){
            id object = [objects objectAtIndex:i];
            [invocation setArgument:&object atIndex: (i + 2)];
        }
        [invocation invoke];
        if (signature.methodReturnLength) {
            id anObject;
            [invocation getReturnValue:&anObject];
            return anObject;
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

@end

@implementation NSObject (KVC)

- (id)initWithDic:(NSDictionary *)dic{
    self = [self init];
    if (self) {
        if (!dic || ![dic isKindOfClass:[NSDictionary class]]) {
            return nil;
        }
        
        [NSObject KeyValueDecoderForObject:self dic:dic];
    }
    return self;
}

- (NSDictionary *)dic{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    [NSObject KeyValueEncoderForObject:self dic:dic];
    
    return dic;
}

- (id)initWithJson:(NSString *)json{
    NSData *data= [json dataUsingEncoding:NSUTF8StringEncoding];
    if (!data) {
        return nil;
    }
    
    NSError *error;
    id jsonData = [NSJSONSerialization
                   JSONObjectWithData:data
                   options:NSJSONReadingMutableContainers
                   error:&error];
    if (error) {
        return nil;
    }
    
    if (![jsonData isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    NSDictionary *dic = (NSDictionary *)jsonData;
    return [self initWithDic:dic];
}

- (NSString *)json{
    NSDictionary *dic=[self dic];
    
    if ([NSJSONSerialization isValidJSONObject:dic]) {
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:0 error:&error];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if (!error) return json;
    }
    return nil;
}

+ (NSDictionary *)replacedKeyMap{
    return nil;
}

+ (NSDictionary *)replacedKeyMapOfClass:(Class)klass{
    //memory缓存
    if (!gReplacedKeyMapsOfClass) {
        gReplacedKeyMapsOfClass = [[NSCache alloc] init];
        gReplacedKeyMapsOfClass.name=@"AutuParser.ReplacedKeyMapsOfClass";
        gReplacedKeyMapsOfClass.countLimit=500;
    }
    NSMutableDictionary * map=[gReplacedKeyMapsOfClass objectForKey:NSStringFromClass(klass)];
    if (map) {
    }
    else{
        map = [NSMutableDictionary dictionary];
        [self replacedKeyMapForHierarchyOfClass:klass onDictionary:map];
        //NSLog(@"%@:%@",NSStringFromClass(klass),map);
        [gReplacedKeyMapsOfClass setObject:map forKey:NSStringFromClass(klass)];
    }
    return map;
    
//    NSMutableDictionary *map = [NSMutableDictionary dictionary];
//    [self replacedKeyMapForHierarchyOfClass:klass onDictionary:map];
//    return [NSDictionary dictionaryWithDictionary:map];
}

+ (void)replacedKeyMapForHierarchyOfClass:(Class)class onDictionary:(NSMutableDictionary *)map{
    if (class == NULL) {
        return;
    }
    
    if (class == [NSObject class]) {
    }
    
    [self replacedKeyMapForHierarchyOfClass:[class superclass] onDictionary:map];
    
    [[class replacedKeyMap] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [map safeSetObject:obj forKey:key];
    }];
}

+ (NSArray *)ignoredParserPropertyNames{
    return nil;
}

+ (NSArray *)ignoredCodingPropertyNames{
    return nil;
}

+ (NSDictionary *)ignoredPropertyNamesOfClass:(Class)klass{
    //memory缓存
    if (!gIgnoredPropertyNamesOfClass) {
        gIgnoredPropertyNamesOfClass = [[NSCache alloc] init];
        gIgnoredPropertyNamesOfClass.name=@"AutuParser.IgnoredPropertyNamesOfClass";
        gIgnoredPropertyNamesOfClass.countLimit=500;
    }
    NSMutableDictionary * map=[gIgnoredPropertyNamesOfClass objectForKey:NSStringFromClass(klass)];
    if (map) {
    }
    else{
        map = [NSMutableDictionary dictionary];
        [self ignoredPropertyNamesForHierarchyOfClass:klass onDictionary:map];
        [gIgnoredPropertyNamesOfClass setObject:map forKey:NSStringFromClass(klass)];
    }
    return map;
}

+ (void)ignoredPropertyNamesForHierarchyOfClass:(Class)class onDictionary:(NSMutableDictionary *)map{
    if (class == NULL) {
        return;
    }
    
    if (class == [NSObject class]) {
    }
    
    [self ignoredPropertyNamesForHierarchyOfClass:[class superclass] onDictionary:map];
    
    [[class ignoredParserPropertyNames] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [map safeSetObject:@(PropertyNameStateIgnoredParser) forKey:obj];
    }];
    [[class ignoredCodingPropertyNames] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PropertyNameState propertyNameState=[[map valueForKey:obj] integerValue];
        propertyNameState |= PropertyNameStateIgnoredCoding;
        [map safeSetObject:@(propertyNameState) forKey:obj];
    }];
}

+ (void)KeyValueDecoderForObject:(id)object dic:(NSDictionary *)dic{
    NSDictionary *propertysDic = [self propertiesOfObject:object];
    NSDictionary *keyMap = [self replacedKeyMapOfClass:[object class]];
    NSDictionary *ignoredPropertyNames = [self ignoredPropertyNamesOfClass:[object class]];
    [propertysDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        PropertyNameState propertyNameState=[[ignoredPropertyNames valueForKey:key] integerValue];
        if (!(propertyNameState & PropertyNameStateIgnoredParser)) {
            NSString *jsonKeyName=(keyMap && [keyMap valueForKey:key])?[keyMap valueForKey:key]:key;
            id jsonValue=[dic valueForKey:jsonKeyName];
            
            if (jsonValue && jsonValue!=[NSNull null]) {
                if ([obj isEqualToString:NSStringFromClass([NSString class])]) {
                    id value= [NSString safeStringFromObject:jsonValue];
                    [object setValue:value forKeyPath:key];
                }
                else if ([obj isEqualToString:NSStringFromClass([NSMutableString class])]) {
                    id value=[NSMutableString safeStringFromObject:jsonValue];
                    //value=(NSMutableString *)[value stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                    [object setValue:value forKeyPath:key];
                }
                else if ([obj isEqualToString:NSStringFromClass([NSDictionary class])]) {
                    id value=[NSDictionary safeDictionaryFromObject:jsonValue];
                    [object setValue:value forKeyPath:key];
                }
                else if ([obj isEqualToString:NSStringFromClass([NSMutableDictionary class])]) {
                    id value=[NSMutableDictionary safeDictionaryFromObject:jsonValue];
                    [object setValue:value forKeyPath:key];
                }
                else if ([obj isEqualToString:NSStringFromClass([NSNumber class])]) {
                    id value=[NSNumber safeNumberFromObject:jsonValue];
                    [object setValue:value forKeyPath:key];
                }
                else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_LNG_LNG]]
                         || [obj isEqualToString:[NSString stringWithFormat:@"%c",_C_INT]]
                         || [obj isEqualToString:[NSString stringWithFormat:@"%c",_C_LNG]]) {//NSInteger
                    NSInteger value=[[NSString safeStringFromObject:jsonValue] integerValue];
                    [object setValue:@(value) forKeyPath:key];
                }
                else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_ULNG_LNG]]
                         || [obj isEqualToString:[NSString stringWithFormat:@"%c",_C_UINT]]
                         || [obj isEqualToString:[NSString stringWithFormat:@"%c",_C_ULNG]]) {//NSUInteger
                    NSUInteger value=[[NSString safeStringFromObject:jsonValue] integerValue];
                    [object setValue:@(value) forKeyPath:key];
                }
                else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_DBL]]) {//double
                    double value=[[NSString safeStringFromObject:jsonValue] doubleValue];
                    [object setValue:@(value) forKeyPath:key];
                }
                else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_FLT]]) {//float
                    float value=[[NSString safeStringFromObject:jsonValue] floatValue];
                    [object setValue:@(value) forKeyPath:key];
                }
                else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_INT]]) {//int
                    int value=[[NSString safeStringFromObject:jsonValue] intValue];
                    [object setValue:@(value) forKeyPath:key];
                }
                else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_BOOL]]) {//bool,BOOL
                    bool value=[[NSString safeStringFromObject:jsonValue] boolValue];
                    [object setValue:@(value) forKeyPath:key];
                }
                else if ([obj isEqualToString:NSStringFromClass([NSArray class])] || [obj isEqualToString:NSStringFromClass([NSMutableArray class])]) {
                    NSMutableArray *value=[[NSMutableArray alloc] init];
                    
                    NSArray *records = [NSArray safeArrayFromObject:jsonValue];
                    for (NSObject *record in records) {
                        [value safeAddObject:record];
                    }
                    
                    [object setValue:value forKeyPath:key];
                }
                else if ([obj isEqualToString:NSStringFromClass([NSSet class])] || [obj isEqualToString:NSStringFromClass([NSMutableSet class])]) {
                    NSMutableSet *value=[[NSMutableSet alloc] init];
                    
                    NSSet *records = [NSSet safeSetFromObject:jsonValue];
                    for (NSObject *record in records) {
                        [value safeAddObject:record];
                    }
                    
                    [object setValue:value forKeyPath:key];
                }
                else if ([obj isEqualToString:NSStringFromClass([NSOrderedSet class])] || [obj isEqualToString:NSStringFromClass([NSMutableOrderedSet class])]) {
                    NSMutableOrderedSet *value=[[NSMutableOrderedSet alloc] init];
                    
                    NSOrderedSet *records = [NSOrderedSet safeOrderedSetFromObject:jsonValue];
                    for (NSObject *record in records) {
                        [value safeAddObject:record];
                    }
                    
                    [object setValue:value forKeyPath:key];
                }
                else{//自定义class
                    NSRegularExpression *arrayRegExp=[[NSRegularExpression alloc] initWithPattern:@"(?<=\\<).*?(?=\\>)" options:NSRegularExpressionCaseInsensitive error:nil];
                    NSArray *results=[arrayRegExp matchesInString:obj options:NSMatchingWithTransparentBounds range:NSMakeRange(0, [obj length])];
                    if (results.count>0) {
                        NSTextCheckingResult *result=[results safeObjectAtIndex:0];
                        NSRange range = result.range;
                        NSString *className = [[obj substringToIndex:range.location-1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        NSString *recordClassName = [[obj substringWithRange:range] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        id recordClass = NSClassFromString(recordClassName);
                        if ([className isEqualToString:NSStringFromClass([NSArray class])] || [className isEqualToString:NSStringFromClass([NSMutableArray class])]) {
                            NSMutableArray *value=[[NSMutableArray alloc] init];
                            
                            NSArray *records = [NSArray safeArrayFromObject:jsonValue];
                            for (NSObject *record in records) {
                                if (!record) {
                                    continue;
                                }
                                if ([recordClassName isEqualToString:NSStringFromClass([NSNumber class])]) {
                                    [value safeAddObject:[NSNumber safeNumberFromObject:record]];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSString class])]) {
                                    [value safeAddObject:[NSString safeStringFromObject:record]];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSMutableString class])]) {
                                    [value safeAddObject:[NSMutableString safeStringFromObject:record]];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSDictionary class])]) {
                                    [value safeAddObject:[NSDictionary safeDictionaryFromObject:record]];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSMutableDictionary class])]) {
                                    [value safeAddObject:[NSMutableDictionary safeDictionaryFromObject:record]];
                                }
                                else{
                                    if ([record isKindOfClass:[NSDictionary class]]) {
                                        if([recordClass instancesRespondToSelector:@selector(initWithDic:)]){
                                            [value safeAddObject:[[recordClass alloc] initWithDic:(NSDictionary *)record]];
                                        }
                                    }
                                }
                            }
                            
                            [object setValue:value forKeyPath:key];
                            return;
                        }
                        else if ([className isEqualToString:NSStringFromClass([NSSet class])] || [className isEqualToString:NSStringFromClass([NSMutableSet class])]) {
                            NSMutableSet *value=[[NSMutableSet alloc] init];
                            
                            NSSet *records = [NSSet safeSetFromObject:jsonValue];
                            for (NSObject *record in records) {
                                if (!record) {
                                    continue;
                                }
                                if ([recordClassName isEqualToString:NSStringFromClass([NSNumber class])]) {
                                    [value safeAddObject:[NSNumber safeNumberFromObject:record]];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSString class])]) {
                                    [value safeAddObject:[NSString safeStringFromObject:record]];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSMutableString class])]) {
                                    [value safeAddObject:[NSMutableString safeStringFromObject:record]];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSDictionary class])]) {
                                    [value safeAddObject:[NSDictionary safeDictionaryFromObject:record]];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSMutableDictionary class])]) {
                                    [value safeAddObject:[NSMutableDictionary safeDictionaryFromObject:record]];
                                }
                                else{
                                    if ([record isKindOfClass:[NSDictionary class]]) {
                                        if([recordClass instancesRespondToSelector:@selector(initWithDic:)]){
                                            [value safeAddObject:[[recordClass alloc] initWithDic:(NSDictionary *)record]];
                                        }
                                    }
                                }
                            }
                            
                            [object setValue:value forKeyPath:key];
                            return;
                        }
                        else if ([className isEqualToString:NSStringFromClass([NSOrderedSet class])] || [className isEqualToString:NSStringFromClass([NSMutableOrderedSet class])]) {
                            NSMutableOrderedSet *value=[[NSMutableOrderedSet alloc] init];
                            
                            NSOrderedSet *records = [NSOrderedSet safeOrderedSetFromObject:jsonValue];
                            for (NSObject *record in records) {
                                if (!record) {
                                    continue;
                                }
                                if ([recordClassName isEqualToString:NSStringFromClass([NSNumber class])]) {
                                    [value safeAddObject:[NSNumber safeNumberFromObject:record]];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSString class])]) {
                                    [value safeAddObject:[NSString safeStringFromObject:record]];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSMutableString class])]) {
                                    [value safeAddObject:[NSMutableString safeStringFromObject:record]];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSDictionary class])]) {
                                    [value safeAddObject:[NSDictionary safeDictionaryFromObject:record]];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSMutableDictionary class])]) {
                                    [value safeAddObject:[NSMutableDictionary safeDictionaryFromObject:record]];
                                }
                                else{
                                    if ([record isKindOfClass:[NSDictionary class]]) {
                                        if([recordClass instancesRespondToSelector:@selector(initWithDic:)]){
                                            [value safeAddObject:[[recordClass alloc] initWithDic:(NSDictionary *)record]];
                                        }
                                    }
                                }
                            }
                            
                            [object setValue:value forKeyPath:key];
                            return;
                        }
                    }
                    
                    id aClass = NSClassFromString(obj);
                    if([aClass instancesRespondToSelector:@selector(initWithDic:)]){
                        id value=[[aClass alloc] initWithDic:jsonValue];
                        if (value) {
                            [object setValue:value forKeyPath:key];
                        }
                    }
                }
            }
        }
    }];
}

+ (void)KeyValueEncoderForObject:(id)object dic:(NSDictionary *)dic{
    NSDictionary *propertysDic = [self propertiesOfObject:object];
    NSDictionary *keyMap = [self replacedKeyMapOfClass:[object class]];
    NSDictionary *ignoredPropertyNames = [self ignoredPropertyNamesOfClass:[object class]];
    [propertysDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        PropertyNameState propertyNameState=[[ignoredPropertyNames valueForKey:key] integerValue];
        if (!(propertyNameState & PropertyNameStateIgnoredParser)) {
            NSString *jsonKeyName=(keyMap && [keyMap valueForKey:key])?[keyMap valueForKey:key]:key;
            id value=[object valueForKeyPath:key];
            
            if (value) {
                if ([obj isEqualToString:NSStringFromClass([NSString class])] || [obj isEqualToString:NSStringFromClass([NSMutableString class])]) {
                    [dic setValue:value forKey:jsonKeyName];
                }
                else if ([obj isEqualToString:NSStringFromClass([NSDictionary class])] || [obj isEqualToString:NSStringFromClass([NSMutableDictionary class])]) {
                    [dic setValue:value forKey:jsonKeyName];
                }
                else if ([obj isEqualToString:NSStringFromClass([NSNumber class])]) {
                    [dic setValue:value forKey:jsonKeyName];
                }
                else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_LNG_LNG]]
                         || [obj isEqualToString:[NSString stringWithFormat:@"%c",_C_INT]]
                         || [obj isEqualToString:[NSString stringWithFormat:@"%c",_C_LNG]]) {//NSInteger
                    NSInteger jsonValue=[value integerValue];
                    [dic setValue:@(jsonValue) forKey:jsonKeyName];
                }
                else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_ULNG_LNG]]
                         || [obj isEqualToString:[NSString stringWithFormat:@"%c",_C_UINT]]
                         || [obj isEqualToString:[NSString stringWithFormat:@"%c",_C_ULNG]]) {//NSUInteger
                    NSUInteger jsonValue=[value integerValue];
                    [dic setValue:@(jsonValue) forKey:jsonKeyName];
                }
                else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_DBL]]) {//double
                    double jsonValue=[value doubleValue];
                    [dic setValue:[NSString stringWithFormat:@"%0.6f", jsonValue] forKey:jsonKeyName];
                }
                else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_FLT]]) {//float
                    float jsonValue=[value floatValue];
                    [dic setValue:[NSString stringWithFormat:@"%0.6f", jsonValue] forKey:jsonKeyName];
                }
                else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_INT]]) {//int
                    int jsonValue=[value intValue];
                    [dic setValue:@(jsonValue) forKey:jsonKeyName];
                }
                else if ([obj isEqualToString:[NSString stringWithFormat:@"%c",_C_BOOL]]) {//bool,BOOL
                    bool jsonValue=[value boolValue];
                    [dic setValue:@(jsonValue) forKey:jsonKeyName];
                }
                else if ([obj isEqualToString:NSStringFromClass([NSArray class])] || [obj isEqualToString:NSStringFromClass([NSMutableArray class])]) {
                    NSMutableArray *jsonValue=[NSMutableArray array];
                    
                    NSArray *records=value;
                    [records enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSObject *record = (NSObject *)obj;
                        [jsonValue safeAddObject:record];
                    }];
                    [dic setValue:jsonValue forKey:jsonKeyName];
                }
                else if ([obj isEqualToString:NSStringFromClass([NSSet class])] || [obj isEqualToString:NSStringFromClass([NSMutableSet class])]) {
                    NSMutableSet *jsonValue=[NSMutableSet set];
                    
                    NSSet *records=value;
                    [records enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                        NSObject *record = (NSObject *)obj;
                        [jsonValue safeAddObject:record];
                    }];
                    [dic setValue:jsonValue forKey:jsonKeyName];
                }
                else if ([obj isEqualToString:NSStringFromClass([NSOrderedSet class])] || [obj isEqualToString:NSStringFromClass([NSMutableOrderedSet class])]) {
                    NSMutableOrderedSet *jsonValue=[NSMutableOrderedSet orderedSet];
                    
                    NSOrderedSet *records=value;
                    [records enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSObject *record = (NSObject *)obj;
                        [jsonValue safeAddObject:record];
                    }];
                    [dic setValue:jsonValue forKey:jsonKeyName];
                }
                else{//自定义class
                    NSRegularExpression *arrayRegExp=[[NSRegularExpression alloc] initWithPattern:@"(?<=\\<).*?(?=\\>)" options:NSRegularExpressionCaseInsensitive error:nil];
                    NSArray *results=[arrayRegExp matchesInString:obj options:NSMatchingWithTransparentBounds range:NSMakeRange(0, [obj length])];
                    if (results.count>0) {
                        NSTextCheckingResult *result=[results safeObjectAtIndex:0];
                        NSRange range = result.range;
                        NSString *className = [[obj substringToIndex:range.location-1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        NSString *recordClassName = [[obj substringWithRange:range] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        id recordClass = NSClassFromString(recordClassName);
                        if ([className isEqualToString:NSStringFromClass([NSArray class])] || [className isEqualToString:NSStringFromClass([NSMutableArray class])]) {
                            NSMutableArray *jsonValue=[NSMutableArray array];
                            
                            NSArray *records=value;
                            [records enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                if ([recordClassName isEqualToString:NSStringFromClass([NSNumber class])]) {
                                    [jsonValue safeAddObject:obj];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSString class])]) {
                                    [jsonValue safeAddObject:obj?obj:@""];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSMutableString class])]) {
                                    [jsonValue safeAddObject:obj?obj:@""];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSDictionary class])]) {
                                    [jsonValue safeAddObject:obj?obj:[NSMutableDictionary dictionary]];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSMutableDictionary class])]) {
                                    [jsonValue safeAddObject:obj?obj:[NSMutableDictionary dictionary]];
                                }
                                else{
                                    if([recordClass instancesRespondToSelector:@selector(dic)]){
                                        [jsonValue safeAddObject:[obj dic]];
                                    }
                                }
                            }];
                            
                            [dic setValue:jsonValue forKey:jsonKeyName];
                            return;
                        }
                        else if ([className isEqualToString:NSStringFromClass([NSSet class])] || [className isEqualToString:NSStringFromClass([NSMutableSet class])]) {
                            NSMutableSet *jsonValue=[NSMutableSet set];
                            
                            NSSet *records=value;
                            [records enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                                if ([recordClassName isEqualToString:NSStringFromClass([NSNumber class])]) {
                                    [jsonValue safeAddObject:obj];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSString class])]) {
                                    [jsonValue safeAddObject:obj?obj:@""];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSMutableString class])]) {
                                    [jsonValue safeAddObject:obj?obj:@""];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSDictionary class])]) {
                                    [jsonValue safeAddObject:obj?obj:[NSMutableDictionary dictionary]];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSMutableDictionary class])]) {
                                    [jsonValue safeAddObject:obj?obj:[NSMutableDictionary dictionary]];
                                }
                                else{
                                    if([recordClass instancesRespondToSelector:@selector(dic)]){
                                        [jsonValue safeAddObject:[obj dic]];
                                    }
                                }
                            }];
                            
                            [dic setValue:jsonValue forKey:jsonKeyName];
                            return;
                        }
                        else if ([className isEqualToString:NSStringFromClass([NSOrderedSet class])] || [className isEqualToString:NSStringFromClass([NSMutableOrderedSet class])]) {
                            NSMutableOrderedSet *jsonValue=[NSMutableOrderedSet orderedSet];
                            
                            NSOrderedSet *records=value;
                            [records enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                                if ([recordClassName isEqualToString:NSStringFromClass([NSNumber class])]) {
                                    [jsonValue safeAddObject:obj];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSString class])]) {
                                    [jsonValue safeAddObject:obj?obj:@""];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSMutableString class])]) {
                                    [jsonValue safeAddObject:obj?obj:@""];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSDictionary class])]) {
                                    [jsonValue safeAddObject:obj?obj:[NSMutableDictionary dictionary]];
                                }
                                else if ([recordClassName isEqualToString:NSStringFromClass([NSMutableDictionary class])]) {
                                    [jsonValue safeAddObject:obj?obj:[NSMutableDictionary dictionary]];
                                }
                                else{
                                    if([recordClass instancesRespondToSelector:@selector(dic)]){
                                        [jsonValue safeAddObject:[obj dic]];
                                    }
                                }
                            }];
                            
                            [dic setValue:jsonValue forKey:jsonKeyName];
                            return;
                        }
                    }
                    
                    id aClass = NSClassFromString(obj);
                    if([aClass instancesRespondToSelector:@selector(dic)]){
                        NSDictionary *jsonValue=[value dic];
                        [dic setValue:jsonValue?jsonValue:[NSDictionary dictionary] forKey:jsonKeyName];
                    }
                }
            }
        }
    }];
}

//http://stackoverflow.com/questions/754824/get-an-object-properties-list-in-objective-c
static const char *getPropertyType(const char *attributes) {
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {//strsep:分解字符串为一组字符串
        if (attribute[0] == 'T' && attribute[1] != '@') {
            // it's a C primitive type:
            /*
             if you want a list of what will be returned for these primitives, search online for
             "objective-c" "Property Attribute Description Examples"
             apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.
             */
            //return (const char *)[[NSData dataWithBytes:(attribute + 1) length:strlen(attribute) - 1] bytes];
            NSString *name = [[NSString alloc] initWithBytes:attribute + 1 length:strlen(attribute) - 1 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            // it's an ObjC id type:
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && attribute[2] == '?' && strlen(attribute) == 3) {
            // it's a block type:
            return "block";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            //return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
            NSString *name = [[NSString alloc] initWithBytes:attribute + 3 length:strlen(attribute) - 4 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
    }
    return "";
}

//recursive
+ (NSDictionary *) propertiesOfObject:(id)object
{
    Class class = [object class];
    return [self propertiesOfClass:class];
}

+ (NSDictionary *) propertiesOfClass:(Class)klass
{
    //memory缓存
    if (!gPropertiesOfClass) {
        gPropertiesOfClass = [[NSCache alloc] init];
        gPropertiesOfClass.name=@"AutuParser.PropertiesOfClass";
        gPropertiesOfClass.countLimit=500;
    }
    NSMutableDictionary * properties=[gPropertiesOfClass objectForKey:NSStringFromClass(klass)];
    if (properties && properties.count>0) {
    }
    else{
        properties = [NSMutableDictionary dictionary];
        [self propertiesForHierarchyOfClass:klass onDictionary:properties];
        //NSLog(@"%@:%@",NSStringFromClass(klass),properties);
        [gPropertiesOfClass setObject:properties forKey:NSStringFromClass(klass)];
    }
    return properties;
    
//    NSMutableDictionary * properties = [NSMutableDictionary dictionary];
//    [self propertiesForHierarchyOfClass:klass onDictionary:properties];
//    return [NSDictionary dictionaryWithDictionary:properties];
}

+ (NSDictionary *) propertiesOfSubclass:(Class)klass
{
    if (klass == NULL) {
        return nil;
    }
    
    NSMutableDictionary *properties = [NSMutableDictionary dictionary];
    return [self propertiesForSubclass:klass onDictionary:properties];
}

+ (NSMutableDictionary *)propertiesForHierarchyOfClass:(Class)class onDictionary:(NSMutableDictionary *)properties
{
    if (class == NULL) {
        return nil;
    }
    
    if (class == [NSObject class]) {
        // On reaching the NSObject base class, return all properties collected.
        return properties;
    }
    
    // Collect properties from the current class.
    [self propertiesForSubclass:class onDictionary:properties];
    
    // Collect properties from the superclass.
    return [self propertiesForHierarchyOfClass:[class superclass] onDictionary:properties];
}

+ (NSMutableDictionary *) propertiesForSubclass:(Class)class onDictionary:(NSMutableDictionary *)properties
{
    unsigned int outCount, i;
    objc_property_t *objcProperties = class_copyPropertyList(class, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = objcProperties[i];
        const char *propName = property_getName(property);
        if(propName) {
            const char *attributes = property_getAttributes(property);
            //printf("attributes=%s\n", attributes);
            NSArray *attrs = [@(attributes) componentsSeparatedByString:@","];
            if (attrs.count>1) {
                NSString *propRight=attrs[1];
                /*
                 C:copy
                 &:retain|readWrite
                 R:readonly
                 N:nonatomic
                 D:@dynamic
                 W:__weak
                 Gname:以 G 开头是的自定义的 Getter 方法名。(如：GcustomGetter 名字是:customGetter)
                 Sname:以 S 开头是的自定义的 Setter 方法名。(如：ScustoSetter: 名字是: ScustoSetter:)
                 */
                if (![propRight isEqualToString:@"R"]) {
                    const char *propType = getPropertyType(attributes);
                    NSString *propertyName = [NSString stringWithUTF8String:propName];
                    NSString *propertyType = [NSString stringWithUTF8String:propType];
                    [properties setObject:propertyType forKey:propertyName];
                }
            }
            
        }
    }
    free(objcProperties);
    
    return properties;
}

+ (NSMutableArray *)modelsFromDics:(NSArray *)dics
{
    if (!dics || [dics isKindOfClass:[NSNull class]]) return nil;
    
    //parse dictionaries to objects
    NSMutableArray* list = [[NSMutableArray alloc] init];
    for (id dic in dics) {
        if ([dic isKindOfClass:[NSNull class]]) {
            continue;
        }
        else if ([dic isKindOfClass:[NSDictionary class]]) {
            [list safeAddObject:[[self alloc] initWithDic:dic]];
        }
    }
    return list;
}

+ (NSMutableArray *)dicsFromModels:(NSArray *)models
{
    if (!models || [models isKindOfClass:[NSNull class]]) return nil;
    
    //parse dictionaries to objects
    NSMutableArray* list = [[NSMutableArray alloc] init];
    for (id model in models) {
        if ([model isKindOfClass:[NSNull class]]) {
            continue;
        }
        else if([self instancesRespondToSelector:@selector(dic)]){
            [list safeAddObject:[model dic]];
        }
    }
    return list;
}

#pragma mark sqlite3

+ (FMDatabaseQueue *)getFMDBQueue{
    if (!gFMDBQueue) {
        NSString *aSelectorName=@"dbPath";
        SEL aSel = NSSelectorFromString(aSelectorName);
        NSString *error=[NSString stringWithFormat:@"Cannot find method:%@",aSelectorName];
        NSAssert([Configs respondsToSelector:aSel],error);
        NSString* path = [Configs performSelector:aSel];
        gFMDBQueue = [FMDatabaseQueue databaseQueueWithPath:path];
        
        [gFMDBQueue inDatabase:^(FMDatabase *db){
            [db executeUpdate:@"CREATE TABLE IF NOT EXISTS META (key CHAR(50) PRIMARY KEY  NOT NULL,value TEXT)"];
        }];
    }
    
    Class class = self;
    //1.files
    NSString *aSelectorName=[NSString stringWithFormat:@"%@RecordPlistPath",NSStringFromClass(class)];
    SEL aSel = NSSelectorFromString(aSelectorName);
    //2.sqlite3
    NSString *bSelectorName=[NSString stringWithFormat:@"%@RecordTableName",NSStringFromClass(class)];
    SEL bSel = NSSelectorFromString(bSelectorName);
    if ([Configs respondsToSelector:aSel]) {
    }
    else if ([Configs respondsToSelector:bSel]) {
        NSString* tableName = [Configs performSelector:bSel];
        [gFMDBQueue inDatabase:^(FMDatabase *db){
            NSString *sql=[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (key CHAR(100) PRIMARY KEY  NOT NULL,value TEXT)",tableName];
            [db executeUpdate:sql];
        }];
    }
    
    return gFMDBQueue;
/*
    //[gFMDBQueue inDatabase:^(FMDatabase *db){
    [gFMDBQueue inTransaction:^(FMDatabase *db, BOOL *rollback){
        BOOL result = [db executeUpdate:@"CREATE TABLE test (a text, b text, c integer, d double, e double)"];
        result = [db executeUpdate:@"INSERT INTO test VALUES ('a', 'b', 1, 2.2, 2.3)"];
        
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM test"];
        [rs next];
        [rs close];
    }];
    
    [gFMDBQueue close];
 */
}

#pragma mark load and save CurRecord
+ (NSDictionary *)loadCurRecordDic{
    if (!gCurRecordDicOfClass) {
        gCurRecordDicOfClass = [[NSMutableDictionary alloc] init];
    }
    
    Class class = self;
    __block NSDictionary * curRecordDic=[gCurRecordDicOfClass valueForKey:NSStringFromClass(class)];
    if (!curRecordDic) {
        //1.files
        NSString *aSelectorName=[NSString stringWithFormat:@"%@CurRecordPlistPath",NSStringFromClass(class)];
        SEL aSel = NSSelectorFromString(aSelectorName);
        //2.sqlite3
        NSString *bSelectorName=[NSString stringWithFormat:@"%@CurRecordTableName",NSStringFromClass(class)];
        SEL bSel = NSSelectorFromString(bSelectorName);
        //0.exception
        NSString *error=[NSString stringWithFormat:@"Cannot find method:(%@ or %@)",aSelectorName,bSelectorName];
        NSAssert(([Configs respondsToSelector:aSel] || [Configs respondsToSelector:bSel]),error);
        if ([Configs respondsToSelector:aSel]) {
            NSString* path = [Configs performSelector:aSel];
            NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:path];
            if (!dict || ![dict isKindOfClass:[NSDictionary class]]) {
                curRecordDic = nil;
            }
            else{
                curRecordDic = dict;
            }
        }
        else if ([Configs respondsToSelector:bSel]) {
            NSString* tableName = [Configs performSelector:bSel];
            [[self getFMDBQueue] inDatabase:^(FMDatabase *db){
                NSDictionary* dict=nil;
                FMResultSet *rs = [db executeQuery:@"SELECT * FROM META WHERE key = ?",tableName];
                if ([rs next]) {
                    dict = [[rs stringForColumn:@"value"] jsonValueDecoded];
                }
                [rs close];
                
                if (!dict || ![dict isKindOfClass:[NSDictionary class]]) {
                    curRecordDic = nil;
                }
                else{
                    curRecordDic = dict;
                }
            }];
        }
        
        [gCurRecordDicOfClass setValue:curRecordDic forKey:NSStringFromClass(class)];
    }
    return curRecordDic;
}

//清空当前记录
+(void)clearCurRecord{
    if (!gCurRecordDicOfClass) {
        gCurRecordDicOfClass = [[NSMutableDictionary alloc] init];
    }
    
    Class class = self;
    NSDictionary * curRecordDic=[gCurRecordDicOfClass valueForKey:NSStringFromClass(class)];
    curRecordDic = nil;
    [gCurRecordDicOfClass setValue:curRecordDic forKey:NSStringFromClass(class)];
    
    //1.files
    NSString *aSelectorName=[NSString stringWithFormat:@"%@CurRecordPlistPath",NSStringFromClass(class)];
    SEL aSel = NSSelectorFromString(aSelectorName);
    //2.sqlite3
    NSString *bSelectorName=[NSString stringWithFormat:@"%@CurRecordTableName",NSStringFromClass(class)];
    SEL bSel = NSSelectorFromString(bSelectorName);
    //0.exception
    NSString *error=[NSString stringWithFormat:@"Cannot find method:(%@ or %@)",aSelectorName,bSelectorName];
    NSAssert(([Configs respondsToSelector:aSel] || [Configs respondsToSelector:bSel]),error);
    if ([Configs respondsToSelector:aSel]) {
        NSString* path = [Configs performSelector:aSel];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    else if ([Configs respondsToSelector:bSel]) {
        NSString* tableName = [Configs performSelector:bSel];
        [[self getFMDBQueue] inDatabase:^(FMDatabase *db){
            BOOL result = [db executeUpdate:@"DELETE FROM META WHERE key = ?",tableName];
        }];
    }
    
    // 通知当前记录已被删除
    NSString *notificationName=[NSString stringWithFormat:@"%@CurRecordChanged",NSStringFromClass(class)];
    // userInfo = NSDictionary {"action":"add"|"delete"}
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"delete", @"action", nil]];
}

/** 读取当前记录 */
+ (id)loadCurRecord{
    Class class = self;
    if([class instancesRespondToSelector:@selector(initWithDic:)]){
        return [[class alloc] initWithDic:[self loadCurRecordDic]];
    }
    return nil;
}

/** 保存当前记录数据 */
+ (void)saveCurRecordDicData{
    NSDictionary* dict = [NSDictionary dictionaryWithDictionary:[self loadCurRecordDic]];
    [self performSelectorInBackground:@selector(saveCurRecordDic:) withObject:dict];
}

/** 后台保存当前记录数据 */
+ (void)saveCurRecordDic:(NSMutableDictionary *)dic{
    @autoreleasepool {
        @synchronized(dic) {//保证此时没有其他线程对self对象进行修改
            Class class = self;
            //1.files
            NSString *aSelectorName=[NSString stringWithFormat:@"%@CurRecordPlistPath",NSStringFromClass(class)];
            SEL aSel = NSSelectorFromString(aSelectorName);
            //2.sqlite3
            NSString *bSelectorName=[NSString stringWithFormat:@"%@CurRecordTableName",NSStringFromClass(class)];
            SEL bSel = NSSelectorFromString(bSelectorName);
            //0.exception
            NSString *error=[NSString stringWithFormat:@"Cannot find method:(%@ or %@)",aSelectorName,bSelectorName];
            NSAssert(([Configs respondsToSelector:aSel] || [Configs respondsToSelector:bSel]),error);
            if ([Configs respondsToSelector:aSel]) {
                NSString* path = [Configs performSelector:aSel];
                [dic writeToFile:path atomically:YES];
            }
            else if ([Configs respondsToSelector:bSel]) {
                NSString* tableName = [Configs performSelector:bSel];
                [[self getFMDBQueue] inTransaction:^(FMDatabase *db, BOOL *rollback){
                    [db executeUpdate:@"DELETE FROM META WHERE key = ?",tableName];
                    [db executeUpdate:@"INSERT INTO META (key,value) VALUES (?,?)",tableName,[NSString safeStringFromObject:dic]];
                    //[db executeUpdate:@"UPDATE META SET value = ? WHERE key = ?",[NSString safeStringFromObject:dic],tableName];
                }];
            }
        }
    }
}

/** 保存当前记录 */
+ (BOOL)saveCurRecord:(NSObject *)record{
    BOOL result = NO;
    
    if (!gCurRecordDicOfClass) {
        gCurRecordDicOfClass = [[NSMutableDictionary alloc] init];
    }
    
    Class class = self;
    NSDictionary * curRecordDic=[gCurRecordDicOfClass valueForKey:NSStringFromClass(class)];
    
    NSObject *oldRecord = nil;
    if([class instancesRespondToSelector:@selector(initWithDic:)]){
        oldRecord = [[class alloc] initWithDic:curRecordDic];
    }
    
    if (record && [record isKindOfClass:class]) {
        NSAssert([class instancesRespondToSelector:@selector(dic)],@"Cannot find method:dic");
        curRecordDic=nil;
        curRecordDic=[record dic];
        [gCurRecordDicOfClass setValue:curRecordDic forKey:NSStringFromClass(class)];
        
        // 后台保存到文件中
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(saveCurRecordDicData) object:nil];
        [self performSelector:@selector(saveCurRecordDicData) withObject:nil afterDelay:1.0];
        
        // 通知当前记录已更新
        NSString *notificationName=[NSString stringWithFormat:@"%@CurRecordChanged",NSStringFromClass(class)];
        // userInfo = NSDictionary {"newRecord":record, "oldRecord":record, "action":"add"|"delete"}
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:record, @"newRecord", oldRecord, @"oldRecord", @"add", @"action", nil]];
        
        result = YES;
    } else {//册除
        //1.files
        NSString *aSelectorName=[NSString stringWithFormat:@"%@CurRecordPlistPath",NSStringFromClass(class)];
        SEL aSel = NSSelectorFromString(aSelectorName);
        //2.sqlite3
        NSString *bSelectorName=[NSString stringWithFormat:@"%@CurRecordTableName",NSStringFromClass(class)];
        SEL bSel = NSSelectorFromString(bSelectorName);
        //0.exception
        NSString *error=[NSString stringWithFormat:@"Cannot find method:(%@ or %@)",aSelectorName,bSelectorName];
        NSAssert(([Configs respondsToSelector:aSel] || [Configs respondsToSelector:bSel]),error);
        if ([Configs respondsToSelector:aSel]) {
            NSString* path = [Configs performSelector:aSel];
            result = [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
        else if ([Configs respondsToSelector:bSel]) {
            NSString* tableName = [Configs performSelector:bSel];
            [[self getFMDBQueue] inDatabase:^(FMDatabase *db){
                BOOL result = [db executeUpdate:@"DELETE FROM META WHERE key = ?",tableName];
            }];
        }
        
        curRecordDic=nil;
        [gCurRecordDicOfClass setValue:curRecordDic forKey:NSStringFromClass(class)];
        
        // 通知当前记录已被删除
        NSString *notificationName=[NSString stringWithFormat:@"%@CurRecordChanged",NSStringFromClass(class)];
        // userInfo = NSDictionary {"action":"add"|"delete"}
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"delete", @"action", nil]];
    }
    return result;
}

#pragma mark load and save history
+ (NSMutableArray *)loadRecordDicArray {
    if (!gRecordDicOfClass) {
        gRecordDicOfClass = [[NSMutableDictionary alloc] init];
    }
    
    Class class = self;
    __block NSMutableArray * recordDicArray=[gRecordDicOfClass valueForKey:NSStringFromClass(class)];
    if (!(recordDicArray && [recordDicArray isKindOfClass:[NSMutableArray class]])) {
        //1.files
        NSString *aSelectorName=[NSString stringWithFormat:@"%@RecordPlistPath",NSStringFromClass(class)];
        SEL aSel = NSSelectorFromString(aSelectorName);
        //2.sqlite3
        NSString *bSelectorName=[NSString stringWithFormat:@"%@RecordTableName",NSStringFromClass(class)];
        SEL bSel = NSSelectorFromString(bSelectorName);
        //0.exception
        NSString *error=[NSString stringWithFormat:@"Cannot find method:(%@ or %@)",aSelectorName,bSelectorName];
        NSAssert(([Configs respondsToSelector:aSel] || [Configs respondsToSelector:bSel]),error);
        if ([Configs respondsToSelector:aSel]) {
            NSString* path = [Configs performSelector:aSel];
            NSArray *records = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
            if (records && [records isKindOfClass:[NSArray class]] && records.count>0) {
                recordDicArray = [NSMutableArray arrayWithArray:records];
            }
            else{
                recordDicArray = [NSMutableArray array];
            }
        }
        else if ([Configs respondsToSelector:bSel]) {
            NSString* tableName = [Configs performSelector:bSel];
            [[self getFMDBQueue] inDatabase:^(FMDatabase *db){
                recordDicArray = [NSMutableArray array];
                NSString *sql=[NSString stringWithFormat:@"SELECT * FROM %@",tableName];
                FMResultSet *rs = [db executeQuery:sql];
                while ([rs next]) {
                    [recordDicArray addObject:[[rs stringForColumn:@"value"] jsonValueDecoded]];
                }
                [rs close];
            }];
        }
        
        [gRecordDicOfClass setValue:recordDicArray forKey:NSStringFromClass(class)];
    }
    
    return recordDicArray;
}

/** 清空记录 */
+ (void)clearHistory{
    if (!gRecordDicOfClass) {
        gRecordDicOfClass = [[NSMutableDictionary alloc] init];
    }
    
    Class class = self;
    NSMutableArray * recordDicArray=[gRecordDicOfClass valueForKey:NSStringFromClass(class)];
    recordDicArray = nil;
    recordDicArray = [NSMutableArray array];
    [gRecordDicOfClass setValue:recordDicArray forKey:NSStringFromClass(class)];
    
    //1.files
    NSString *aSelectorName=[NSString stringWithFormat:@"%@RecordPlistPath",NSStringFromClass(class)];
    SEL aSel = NSSelectorFromString(aSelectorName);
    //2.sqlite3
    NSString *bSelectorName=[NSString stringWithFormat:@"%@RecordTableName",NSStringFromClass(class)];
    SEL bSel = NSSelectorFromString(bSelectorName);
    //0.exception
    NSString *error=[NSString stringWithFormat:@"Cannot find method:(%@ or %@)",aSelectorName,bSelectorName];
    NSAssert(([Configs respondsToSelector:aSel] || [Configs respondsToSelector:bSel]),error);
    if ([Configs respondsToSelector:aSel]) {
        NSString* path = [Configs performSelector:aSel];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    else if ([Configs respondsToSelector:bSel]) {
        NSString* tableName = [Configs performSelector:bSel];
        [[self getFMDBQueue] inDatabase:^(FMDatabase *db){
            NSString *sql=[NSString stringWithFormat:@"DELETE FROM %@",tableName];
            [db executeUpdate:sql];
        }];
    }
}

/** 读取记录，返回NSObject的数组 */
+ (NSMutableArray *)loadHistory{
    Class class = self;
    
    NSArray *records = [self loadRecordDicArray];
    NSMutableArray *history = [NSMutableArray array];
    for (int i=0; i<records.count; i++) {
        NSDictionary *dic = [records objectAtIndex:i];
        if (!dic || ![dic isKindOfClass:[NSDictionary class]]) {
            return nil;
        }
        NSString *record_id = RKMapping([dic valueForKey:@"record_id"]);
        if (record_id && record_id.length>0) {
            if([class instancesRespondToSelector:@selector(initWithDic:)]){
                [history addObject:[[class alloc] initWithDic:dic]];
            }
        }
    }
    
    return history;
}

/** 保存记录 */
+ (void)saveHistoryData{
    if (!gRecordDicOfClass) {
        gRecordDicOfClass = [[NSMutableDictionary alloc] init];
    }
    
    Class class = self;
    NSMutableArray * recordDicArray=[gRecordDicOfClass valueForKey:NSStringFromClass(class)];
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:recordDicArray];
    [self performSelectorInBackground:@selector(saveHistory:) withObject:data];
}

/** 后台保存记录 */
+ (void)saveHistory:(NSData *)data{
    @autoreleasepool {
        @synchronized(data) {//保证此时没有其他线程对self对象进行修改,@synchronized它用来修饰一个方法或者一个代码块的时候，能够保证在同一时刻最多只有一个线程执行该段代码.另一个线程必须等待当前线程执行完这个代码块以后才能执行该代码块
            Class class = self;
            NSString *aSelectorName=[NSString stringWithFormat:@"%@RecordPlistPath",NSStringFromClass(class)];
            SEL sel = NSSelectorFromString(aSelectorName);
            NSString *error=[NSString stringWithFormat:@"Cannot find method:%@",aSelectorName];
            NSAssert([Configs respondsToSelector:sel],error);
            NSString* path = [Configs performSelector:sel];
            [data writeToFile:path atomically:YES];
        }
    }
}

+ (BOOL)addRecord:(id)record inRecordArray:(NSMutableArray *)recordArray {
    Class class = self;
    if (record && [record isKindOfClass:class]) {
        NSAssert([class instancesRespondToSelector:@selector(dic)],@"Cannot find method:dic");
        NSMutableDictionary *dic = [[record dic] mutableCopy];
        
        // 根据record_id比较是否存在，如果存在则先删除后添加
        for (int i=0; i<recordArray.count; i++) {
            NSDictionary *eachRecord = [recordArray objectAtIndex:i];
            NSString *record_id = RKMapping([eachRecord valueForKey:@"record_id"]);
            NSString *recordid=[record valueForKeyPath:@"record_id"];
            if (record_id && record_id.length>0 && [record_id isEqualToString:recordid]) {
                //存在
                [recordArray removeObjectAtIndex:i];
            }
        }
        
        [recordArray addObject:dic];
        dic=nil;
        return YES;
    }
    return NO;
}

/** 添加单条记录 */
+ (BOOL)addRecord:(NSObject *)record{
    Class class = self;
    if (record && [record isKindOfClass:class]) {
        NSMutableArray* records = [self loadRecordDicArray];
        [self addRecord:record inRecordArray:records];
        
        NSString *notificationName=[NSString stringWithFormat:@"%@HistoryChanged",NSStringFromClass(class)];
        // userInfo = NSDictionary {"action":"add"|"delete"|"update"}
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:record,@"record" ,@"add", @"action", nil]];
        
        //1.files
        NSString *aSelectorName=[NSString stringWithFormat:@"%@RecordPlistPath",NSStringFromClass(class)];
        SEL aSel = NSSelectorFromString(aSelectorName);
        //2.sqlite3
        NSString *bSelectorName=[NSString stringWithFormat:@"%@RecordTableName",NSStringFromClass(class)];
        SEL bSel = NSSelectorFromString(bSelectorName);
        //0.exception
        NSString *error=[NSString stringWithFormat:@"Cannot find method:(%@ or %@)",aSelectorName,bSelectorName];
        NSAssert(([Configs respondsToSelector:aSel] || [Configs respondsToSelector:bSel]),error);
        if ([Configs respondsToSelector:aSel]) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(saveHistoryData) object:nil];
            [self performSelector:@selector(saveHistoryData) withObject:nil afterDelay:1.0];
        }
        else if ([Configs respondsToSelector:bSel]) {
            NSString* tableName = [Configs performSelector:bSel];
            [[self getFMDBQueue] inTransaction:^(FMDatabase *db, BOOL *rollback){
                NSString *recordid=[record valueForKeyPath:@"record_id"];
                NSString *sql1=[NSString stringWithFormat:@"DELETE FROM %@ WHERE key = '%@'",tableName,recordid];
                NSString *sql2=[NSString stringWithFormat:@"INSERT INTO %@ (key,value) VALUES ('%@','%@')",tableName,recordid,[NSString safeStringFromObject:[record dic]]];
                [db executeUpdate:sql1];
                [db executeUpdate:sql2];
            }];
        }
        return YES;
    } else {
        return NO;
    }
}

/** 添加多条记录 */
+ (BOOL)addRecords:(NSArray *)records{
    Class class = self;
    NSMutableArray *recordFile = [self loadRecordDicArray];
    for (id record in records) {
        if(![self addRecord:record inRecordArray:recordFile])
            return NO;
    }
    
    //1.files
    NSString *aSelectorName=[NSString stringWithFormat:@"%@RecordPlistPath",NSStringFromClass(class)];
    SEL aSel = NSSelectorFromString(aSelectorName);
    //2.sqlite3
    NSString *bSelectorName=[NSString stringWithFormat:@"%@RecordTableName",NSStringFromClass(class)];
    SEL bSel = NSSelectorFromString(bSelectorName);
    //0.exception
    NSString *error=[NSString stringWithFormat:@"Cannot find method:(%@ or %@)",aSelectorName,bSelectorName];
    NSAssert(([Configs respondsToSelector:aSel] || [Configs respondsToSelector:bSel]),error);
    if ([Configs respondsToSelector:aSel]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(saveHistoryData) object:nil];
        [self performSelector:@selector(saveHistoryData) withObject:nil afterDelay:1.0];
    }
    else if ([Configs respondsToSelector:bSel]) {
        NSString* tableName = [Configs performSelector:bSel];
        [[self getFMDBQueue] inTransaction:^(FMDatabase *db, BOOL *rollback){
            for (id record in records) {
                NSString *recordid=[record valueForKeyPath:@"record_id"];
                NSString *sql1=[NSString stringWithFormat:@"DELETE FROM %@ WHERE key = '%@'",tableName,recordid];
                NSString *sql2=[NSString stringWithFormat:@"INSERT INTO %@ (key,value) VALUES ('%@','%@')",tableName,recordid,[NSString safeStringFromObject:[record dic]]];
                [db executeUpdate:sql1];
                [db executeUpdate:sql2];
            }
        }];
    }
    return YES;
}

+ (BOOL)updateRecord:(id)record inRecordArray:(NSMutableArray *)recordArray {
    Class class = self;
    if (record && [record isKindOfClass:class]) {
        NSAssert([class instancesRespondToSelector:@selector(dic)],@"Cannot find method:dic");
        NSMutableDictionary *dic = [[record dic] mutableCopy];
        
        // 根据record_id比较是否存在，如果存在则先替换
        for (int i=0; i<recordArray.count; i++) {
            NSDictionary *eachRecord = [recordArray objectAtIndex:i];
            NSString *record_id = RKMapping([eachRecord valueForKey:@"record_id"]);
            NSString *recordid=[record valueForKeyPath:@"record_id"];
            if (record_id && record_id.length>0 && [record_id isEqualToString:recordid]) {
                //存在
                [recordArray replaceObjectAtIndex:i withObject:dic];
            }
        }
        
        dic=nil;
        return YES;
    }
    return NO;
}

/** 更新单条记录信息 */
+ (BOOL)updateRecord:(NSObject *)record{
    Class class = self;
    if (record && [record isKindOfClass:class]) {
        NSMutableArray* records = [self loadRecordDicArray];
        [self updateRecord:record inRecordArray:records];
        
        NSString *notificationName=[NSString stringWithFormat:@"%@HistoryChanged",NSStringFromClass(class)];
        // userInfo = NSDictionary {"action":"add"|"delete"|"update"}
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"update", @"action", nil]];
        
        //1.files
        NSString *aSelectorName=[NSString stringWithFormat:@"%@RecordPlistPath",NSStringFromClass(class)];
        SEL aSel = NSSelectorFromString(aSelectorName);
        //2.sqlite3
        NSString *bSelectorName=[NSString stringWithFormat:@"%@RecordTableName",NSStringFromClass(class)];
        SEL bSel = NSSelectorFromString(bSelectorName);
        //0.exception
        NSString *error=[NSString stringWithFormat:@"Cannot find method:(%@ or %@)",aSelectorName,bSelectorName];
        NSAssert(([Configs respondsToSelector:aSel] || [Configs respondsToSelector:bSel]),error);
        if ([Configs respondsToSelector:aSel]) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(saveHistoryData) object:nil];
            [self performSelector:@selector(saveHistoryData) withObject:nil afterDelay:1.0];
        }
        else if ([Configs respondsToSelector:bSel]) {
            NSString* tableName = [Configs performSelector:bSel];
            [[self getFMDBQueue] inDatabase:^(FMDatabase *db){
                NSString *recordid=[record valueForKeyPath:@"record_id"];
                NSString *sql=[NSString stringWithFormat:@"UPDATE %@ SET value = '%@' WHERE key = '%@'",tableName,[NSString safeStringFromObject:[record dic]],recordid];
                [db executeUpdate:sql];
            }];
        }
        return YES;
    } else {
        return NO;
    }
}

/** 删除单条记录 */
+ (BOOL)deleteRecord:(NSObject *)record{
    Class class = self;
    NSMutableArray* records = [self loadRecordDicArray];
    for (int i=0; i<records.count; i++) {
        NSDictionary *dic = [records objectAtIndex:i];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            return NO;
        }
        NSString *record_id = RKMapping([dic valueForKey:@"record_id"]);
        NSString *recordid=[record valueForKeyPath:@"record_id"];
        if (record_id && record_id.length>0 && [record_id isEqualToString:recordid]) {
            //存在
            [records removeObject:dic];
            
            NSString *notificationName=[NSString stringWithFormat:@"%@HistoryChanged",NSStringFromClass(class)];
            // userInfo = NSDictionary {"action":"add"|"delete"}
            [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"delete", @"action", nil]];
            
            //1.files
            NSString *aSelectorName=[NSString stringWithFormat:@"%@RecordPlistPath",NSStringFromClass(class)];
            SEL aSel = NSSelectorFromString(aSelectorName);
            //2.sqlite3
            NSString *bSelectorName=[NSString stringWithFormat:@"%@RecordTableName",NSStringFromClass(class)];
            SEL bSel = NSSelectorFromString(bSelectorName);
            //0.exception
            NSString *error=[NSString stringWithFormat:@"Cannot find method:(%@ or %@)",aSelectorName,bSelectorName];
            NSAssert(([Configs respondsToSelector:aSel] || [Configs respondsToSelector:bSel]),error);
            if ([Configs respondsToSelector:aSel]) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(saveHistoryData) object:nil];
                [self performSelector:@selector(saveHistoryData) withObject:nil afterDelay:1.0];
            }
            else if ([Configs respondsToSelector:bSel]) {
                NSString* tableName = [Configs performSelector:bSel];
                [[self getFMDBQueue] inDatabase:^(FMDatabase *db){
                    NSString *sql=[NSString stringWithFormat:@"DELETE FROM %@ WHERE key = %@",tableName,recordid];
                    [db executeUpdate:sql];
                }];
            }
            return YES;
        }
    }
    
    return NO;
}

/** 是否有此record_id的记录 */
+ (BOOL)hasRecord:(NSString *)_record_id{
    NSMutableArray* records = [self loadRecordDicArray];
    for (int i=0; i<records.count; i++) {
        NSDictionary *dic = [records objectAtIndex:i];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            return NO;
        }
        
        NSString *record_id = RKMapping([dic valueForKey:@"record_id"]);
        if (record_id && record_id.length>0 && [record_id isEqualToString:_record_id]) {
            //存在
            return YES;
        }
    }
    
    return NO;
}

/** 查找指定record_id的记录 */
+ (id)findRecord:(NSString *)_record_id{
    Class class = self;
    NSMutableArray* records = [self loadRecordDicArray];
    for (int i=0; i<records.count; i++) {
        NSDictionary *dic = [records objectAtIndex:i];
        if (![dic isKindOfClass:[NSDictionary class]]) {
            return nil;
        }
        
        NSString *record_id = RKMapping([dic valueForKey:@"record_id"]);
        if (record_id && record_id.length>0 && [record_id isEqualToString:_record_id]) {
            if([class instancesRespondToSelector:@selector(initWithDic:)]){
                return [[class alloc] initWithDic:dic];
            }
        }
    }
    
    return nil;
}

@end
