//
//  RegionModel.h
//  GreenBaby
//
//  Created by LiXiangCheng on 15/7/29.
//  Copyright (c) 2015年 LiXiangCheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CityModel.h"

//省份
@JSONInterface(RegionModel) : NSObject

@property (nonatomic, assign) NSInteger regionid;
@property (nonatomic, strong) NSString *regionname;
//@property (nonatomic, strong) JSONMutableArray(CityModel) *citys;

@property (nonatomic, strong) NSString *record_id;//PK,用于数据存储

@end
