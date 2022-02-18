//
//  RegionModel.m
//  GreenBaby
//
//  Created by LiXiangCheng on 15/7/29.
//  Copyright (c) 2015年 LiXiangCheng. All rights reserved.
//

#import "RegionModel.h"

@JSONImplementation(RegionModel)

#pragma mark override

- (id)initWithDic:(NSDictionary *)dic{
    self = [super initWithDic:dic];
    
    self.record_id = [NSString stringWithFormat:@"%@",@(self.regionid)];
    return self;
}

- (NSDictionary *)dic{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[super dic]];
    
    [dic setValue:(self.record_id?self.record_id:@"") forKey:@"record_id"];
    return dic;
}

//数组属性中需要转换的记录类型(优先使用模型定义中标明的数组属性元素类型，否则用此方法标明,同时解决swift引用类嵌套问题）
+(NSDictionary *)objectClassInArray{
    return @{
        @"citys" : [CityModel class]
    };
}

@end
