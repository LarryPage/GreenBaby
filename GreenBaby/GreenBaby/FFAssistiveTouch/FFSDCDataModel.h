//
//  FFSDCDataModel.h
//  BrcIot
//
//  Created by LiXiangCheng on 2018/10/29.
//  Copyright © 2018年 BRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@JSONInterface(FFSDCDataModel) : NSObject

@property (nonatomic, assign) BOOL hasSub;//! 是否有子节点
@property (nonatomic, strong) NSMutableArray<FFSDCDataModel> *subNode;//! 子节点
@property (nonatomic, strong) NSString *pluginName;//! 节点名
@property (nonatomic, strong) NSString *pluginId;//! 节点ID
@property (nonatomic, strong) NSString *iconName;//! 节点ICON 图片名
@property (nonatomic, strong) NSString *url;//! 该节点 跳转URL
@property (nonatomic, strong) NSString *vcName;//! 该节点 VC 名字
@property (nonatomic, strong) NSMutableDictionary *params;//! 页面参数
@property (nonatomic, strong) NSString *formConfigName;//! 如果是动态表单就有这个值

@end
