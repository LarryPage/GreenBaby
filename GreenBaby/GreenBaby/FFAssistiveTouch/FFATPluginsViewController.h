//
//  FFATPluginsViewController.h
//  BrcIot
//
//  Created by LiXiangCheng on 2018/10/29.
//  Copyright © 2018年 BRC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFATPluginsView.h"
#import "FFSDCDataModel.h"

@class FFATPluginsViewController;

@protocol FFATDelegate <NSObject>
//! 有多少个插件
- (NSInteger)numberOfItemsInViewController:(FFATPluginsViewController *_Nonnull)viewController;
//! 具体某个插件
- (FFATPluginsView *_Nonnull)viewController:(FFATPluginsViewController *_Nonnull)viewController itemViewAtPosition:(FFATPosition *_Nonnull)position;
//! 选中某个插件
- (void)viewController:(FFATPluginsViewController *_Nonnull)viewController didSelectedAtPosition:(FFATPosition *_Nonnull)position;
@end

@interface FFATPluginsViewController : UIResponder

@property (nonatomic, strong, nonnull) FFATPluginsView *backItem;
@property (nonatomic, strong, nonnull) NSArray<FFATPluginsView *> *items;
@property (nonatomic, weak, nullable) id<FFATDelegate> delegate;
@property (nonatomic, strong, nonnull) NSMutableArray<FFSDCDataModel> *itemsData;

- (instancetype _Nonnull )initWithItems:(nullable NSArray<FFATPluginsView *> *)items NS_DESIGNATED_INITIALIZER;
- (void)loadUI;

@end
