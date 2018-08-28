//
//  NSObject+AutoParser.h
//  AutoParser
//
//  Created by LiXiangCheng on 16/9/16.
//  Copyright (c) 2016年 Wanda Inc All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "FMDB.h"
#import "SafeCategories.h"
#import "Configs.h"

#define JSONInterface(klass) protocol klass <NSObject> @end\
@interface klass

#define JSONImplementation(klass) implementation klass \
- (void)encodeWithCoder:(NSCoder *)aCoder{ \
NSDictionary *propertysDic = [[self class] propertiesOfObject:self]; \
NSDictionary *ignoredPropertyNames = [[self class] ignoredPropertyNamesOfClass:[self class]]; \
[propertysDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) { \
PropertyNameState propertyNameState=[[ignoredPropertyNames valueForKey:key] integerValue]; \
if (!(propertyNameState & PropertyNameStateIgnoredCoding)) { \
id value=[self valueForKeyPath:key]; \
if (value!=nil) { \
[aCoder encodeObject:value forKey:key]; \
} \
} \
}]; \
} \
- (id)initWithCoder:(NSCoder *)aDecoder{ \
self = [self init]; \
NSDictionary *propertysDic = [[self class] propertiesOfObject:self]; \
NSDictionary *ignoredPropertyNames = [[self class] ignoredPropertyNamesOfClass:[self class]]; \
[propertysDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) { \
PropertyNameState propertyNameState=[[ignoredPropertyNames valueForKey:key] integerValue]; \
if (!(propertyNameState & PropertyNameStateIgnoredCoding)) { \
id value=[aDecoder decodeObjectForKey:key]; \
if (value!=nil) { \
[self setValue:value forKeyPath:key]; \
} \
} \
}]; \
return self; \
} \
- (id)copyWithZone:(NSZone *)zone{ \
id copy=[[self class] new]; \
NSDictionary *propertysDic = [[self class] propertiesOfObject:copy]; \
[propertysDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) { \
id value=[self valueForKeyPath:key]; \
if (value!=nil) { \
[copy setValue:[value copyWithZone:zone] forKeyPath:key]; \
} \
}]; \
return copy; \
}

#define JSONArray(type) NSArray<type>
#define JSONMutableArray(type) NSMutableArray<type>

#define JSONSet(type) NSSet<type>
#define JSONMutableSet(type) NSMutableSet<type>

#define JSONOrderedSet(type) NSOrderedSet<type>
#define JSONMutableOrderedSet(type) NSMutableOrderedSet<type>

@protocol NSNumber <NSObject> @end
@protocol NSString <NSObject> @end
@protocol NSMutableString <NSObject> @end
@protocol NSDictionary <NSObject> @end
@protocol NSMutableDictionary <NSObject> @end

/*!
 *  @brief 属性名被忽略类型
 *  @since 4.0
 */
typedef NS_ENUM(NSInteger, PropertyNameState) {
    PropertyNameStateDefault = 0,//属性名即进行dic、json和model的解析转换，又进行归档
    PropertyNameStateIgnoredParser = 1 << 0,//属性名被忽略,不进行dic、json和model的解析转换
    PropertyNameStateIgnoredCoding = 1 << 1//属性名被忽略,不进行归档
};

@interface NSObject (Helper)
- (id)performSelector:(SEL)selector withObjects:(NSArray *)objects;
@end

///------------------------------
/// @LiXiangCheng 20150327
/// readme:http://adhoc.qiniudn.com/README.html
/// GitHub:https://github.com/LarryPage/AutoParser
/// 最大缓存500个Model定义,1个model按10个左右属性，大约0.1K，500个model点内存50K
/// 实现 dictionary<->model json<->model
/// 实现 模型序列化存储、读取、copy 【NSCoding NSCopying】
/// 使用 WDSafeCategories保证每条数据安全解析
/// 实现 memoryDB->serializable files、sqlite3
///------------------------------

/**
 support :variable type

 double
 float
 int
 bool
 BOOL，不建议用
 NSInteger
 NSUInteger
 NSNumber *
 NSString * NSMutableString *
 NSDictionary * NSMutableDictionary *
 NSArray * NSMutableArray *
 NSSet * NSMutableSet *
 NSOrderedSet * NSMutableOrderedSet *
 ...
 and 除了以上其它被认为自定义类
 */
// notificationName (ClassName)CurRecordChanged
// userInfo = NSDictionary {"newRecord":record, "oldRecord":record, "action":"add"|"delete"}
// notificationName (ClassName)HistoryChanged
// userInfo = NSDictionary {"record":record,"action":"add"|"delete"|"update"}
@interface NSObject (KVC)

/*!
 *  @brief dic转model
 *  readme:http://adhoc.qiniudn.com/README.html
 *
 *  @param dic  字典
 *
 *  @return model对象
 *
 *  @since 1.0
 */
- (id)initWithDic:(NSDictionary *)dic;


/*!
 *  @brief model转dic
 *  readme:http://adhoc.qiniudn.com/README.html
 *
 *  @return 字典
 *
 *  @since 1.0
 */
- (NSDictionary *)dic;


/*!
 *  @brief json字符串转model
 *
 *  @param json  json字符串
 *
 *  @return model对象
 *
 *  @since 1.0
 */
- (id)initWithJson:(NSString *)json;


/*!
 *  @brief model转json字符串
 *
 *  @return json字符串
 *
 *  @since 1.0
 */
- (NSString *)json;


/*!
 *  @brief 在propertyName与josnKeyName不一致时，要设置此类函数
 *
 *  @return 字典映射replacedKeyMap：{propertyName:jsonKeyName}
 *
 *  @since 1.0
 */
+ (NSDictionary *)replacedKeyMap;


/*!
 *  @brief 这个数组中的属性名将会被忽略：不进行dic、json和model的转换
 *
 *  @return 属性名数组ignoredPropertyNames：[propertyName]
 *
 *  @since 4.0
 */
+ (NSArray *)ignoredParserPropertyNames;


/*!
 *  @brief 这个数组中的属性名将会被忽略：不进行归档
 *
 *  @return 属性名数组ignoredCodingPropertyNames：[propertyName]
 *
 *  @since 4.0
 */
+ (NSArray *)ignoredCodingPropertyNames;


/*!
 *  @brief model对象转属性字典
 *
 *  @param object  model对象
 *
 *  @return model属性字典
 *
 *  @since 1.0
 */
+ (NSDictionary *) propertiesOfObject:(id)object;


/*!
 *  @brief model类转属性字典
 *
 *  @param klass  model类
 *
 *  @return model属性字典
 *
 *  @since 1.0
 */
+ (NSDictionary *) propertiesOfClass:(Class)klass;


/*!
 *  @brief model类的子类转属性字典，支持递归(recursive)
 *
 *  @param klass  model类
 *
 *  @return model的子类属性字典
 *
 *  @since 1.0
 */
+ (NSDictionary *) propertiesOfSubclass:(Class)klass;


/*!
 *  @brief model类的被忽略属性名称集，支持递归(recursive)
 *
 *  @param klass  model类
 *
 *  @return model的被忽略属性名称集
 *
 *  @since 4.0
 */
+ (NSDictionary *) ignoredPropertyNamesOfClass:(Class)klass;


/*!
 *  @brief dic数组转model数组
 *
 *  @param dics  dic数组
 *
 *  @return model数组
 *
 *  @since 2.0
 */
+ (NSMutableArray *)modelsFromDics:(NSArray *)dics;


/*!
 *  @brief model数组转dic数组
 *
 *  @param models  model数组
 *
 *  @return model数组
 *
 *  @since 2.0
 */
+ (NSMutableArray *)dicsFromModels:(NSArray *)models;

#pragma mark sqlite3
/**  Tables:注value存储为dic的josn字符串 */
/**  1.META (key TEXT PRIMARY KEY  NOT NULL,value TEXT) */
/**  {(ClassName)CurRecordTableName,[NSString safeStringFromObject:dic]} */
/**  2.(ClassName)RecordTableName(key TEXT PRIMARY KEY  NOT NULL,value TEXT) */
/**  {record_id,[NSString safeStringFromObject:dic]} */
/**  sql语名:http://www.runoob.com/sqlite/sqlite-tutorial.html */
+ (FMDatabaseQueue *)getFMDBQueue;

#pragma mark load and save CurRecord
/** 清空当前记录 */
+(void)clearCurRecord;
/** 读取当前记录 */
+ (id)loadCurRecord;
/** 保存当前记录 */
+ (BOOL)saveCurRecord:(NSObject *)record;

#pragma mark load and save history
/** 读取记录，返回Dic的数组 */
+ (NSMutableArray *)loadRecordDicArray;
/** 清空记录 */
+ (void)clearHistory;
/** 读取记录，返回NSObject的数组 */
+ (NSMutableArray *)loadHistory;
/** 保存记录 */
+ (void)saveHistoryData;
/** 后台保存记录 */
+ (void)saveHistory:(NSData *)data;
/** 添加单条记录 */
+ (BOOL)addRecord:(NSObject *)record;
/** 添加多条记录 */
+ (BOOL)addRecords:(NSArray *)records;
/** 更新单条记录信息 */
+ (BOOL)updateRecord:(NSObject *)record;
/** 删除单条记录 */
+ (BOOL)deleteRecord:(NSObject *)record;
/** 是否有此record_id的记录 */
+ (BOOL)hasRecord:(NSString *)_record_id;
/** 查找指定record_id的记录 */
+ (id)findRecord:(NSString *)_record_id;

@end
