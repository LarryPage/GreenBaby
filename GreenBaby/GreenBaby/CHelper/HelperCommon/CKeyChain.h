//
//  CKeyChain.h
//  GreenBaby
//
//  Created by LiXiangCheng on 16/8/16.
//  Copyright © 2016年 LiXiangCheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface CKeyChain : NSObject

+ (NSMutableDictionary *)keychainStorageDataWithKey:(NSString *)key;

+ (void)saveWithKey:(NSString *)key data:(id)data;

+ (id)loadDataWithKey:(NSString *)key;

+ (void)deleteDataWithKey:(NSString *)key;

@end
