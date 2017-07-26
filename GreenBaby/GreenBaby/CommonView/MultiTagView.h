//
//  MultiTagView.h
//  MobileResume
//
//  Created by Li XiangCheng on 13-11-25.
//  Copyright (c) 2013年 人人猎头. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kMaxTagCount 9

@interface MultiTagView : UITableView

@property (nonatomic) NSUInteger tagCount; // 标签的个数，最大值为 kMaxTagCount
@property (nonatomic, strong) NSMutableArray *tags;
@property (nonatomic, strong) NSMutableArray *tagLabels;
@property (nonatomic, strong) UIFont *font; // 标签的字体 默认为: System 12
@property (nonatomic) NSLineBreakMode lineBreakMode; // 标签内文字的截断方式 默认为：NSLineBreakByClipping

@property (nonatomic, retain) NSMutableDictionary *relatedCellIndexPaths DEPRECATED_ATTRIBUTE; // 相关联的Cell的IndexPath
@property (nonatomic, retain) NSMutableDictionary *relatedCellLevels DEPRECATED_ATTRIBUTE;

#pragma mark - Add / Remove Tag

/** 
 添加一个标签
 */
- (void)addTag:(NSString *)tag;
- (void)addTag:(NSString *)tag relatedCellIndexPath:(NSIndexPath *)indexPath DEPRECATED_ATTRIBUTE;
- (void)addTag:(NSString *)tag relatedCellIndexPath:(NSIndexPath *)indexPath level:(NSUInteger)level DEPRECATED_ATTRIBUTE;

/**
 删除一个标签
 */
- (void)removeTag:(NSString *)tag;

@end
