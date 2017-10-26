//
//  UserModel.m
//  EHome
//
//  Created by LiXiangCheng on 15/7/28.
//  Copyright (c) 2015年 LiXiangCheng. All rights reserved.
//

#import "UserModel.h"

@JSONImplementation(UserModel)

#pragma mark override

+ (NSDictionary *)replacedKeyMap{
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    //[map safeSetObject:@"jsonKeyName" forKey:@"propertyName"];
    return map;
    
//    return @{@"propertyName" : @"jsonKeyName",
//             @"desc" : @"desciption"
//             };
}

//+ (NSArray *)ignoredParserPropertyNames{
//    return [NSArray arrayWithObjects:@"basicAuth", nil];
//}
//
//+ (NSArray *)ignoredCodingPropertyNames{
//    return [NSArray arrayWithObjects:@"basicAuth", nil];
//}

@end
