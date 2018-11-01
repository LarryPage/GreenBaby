//
//  FFATPluginsViewController.m
//  BrcIot
//
//  Created by LiXiangCheng on 2018/10/29.
//  Copyright © 2018年 BRC. All rights reserved.
//

#import "FFATPluginsViewController.h"
#import "FFATPadStackViewController.h"

@implementation FFATPluginsViewController

@synthesize items = _items;

- (instancetype)initWithItems:(nullable NSArray<FFATPluginsView *> *)items {
    self = [super init];
    if (self) {
        self.items = items;
        _backItem = [FFATPluginsView itemWithType:FFATPluginViewTypeBack customImg:@""];
        UITapGestureRecognizer *backGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backGesture:)];
        [_backItem addGestureRecognizer:backGesture];
    }
    return self;
}

- (instancetype)init {
    return [self initWithItems:nil];
}

#pragma mark - Accessor
- (NSArray<FFATPluginsView *> *)items {
    if (!_items) {
        [self loadUI];
    }
    return _items;
}

- (void)setItems:(NSArray<FFATPluginsView *> *)items {
    if (items.count > [FFATLayoutAttributes maxCount]) {
        _items = [items subarrayWithRange:NSMakeRange(0, [FFATLayoutAttributes maxCount])];
    } else {
        _items = items;
    }
    for (int i = 0; i < MIN(_items.count, _items.count); i++) {
        FFATPluginsView *item = _items[i];
        item.position = [FFATPosition positionWithCount:_items.count index:i];
    }
}

#pragma mark - Action

- (void)backGesture:(UITapGestureRecognizer *)backGesture {
    [self.navigationController popViewController];
}

#pragma mark - loadUI
- (void)loadUI {
    NSMutableArray<FFATPluginsView *> *itemsArray = [NSMutableArray array];
    NSInteger count = 0;
    if (_delegate && [_delegate respondsToSelector:@selector(numberOfItemsInViewController:)]) {
        count = [_delegate numberOfItemsInViewController:self];
        count = MIN(MAX(0, count), [FFATLayoutAttributes maxCount]);
    }
    for (int i = 0; i < count; i++) {
        FFATPluginsView *item;
        if (_delegate && [_delegate respondsToSelector:@selector(viewController:itemViewAtPosition:)]) {
            item = [_delegate viewController:self itemViewAtPosition:[FFATPosition positionWithCount:count index:i]];
        }
        item = item? item: [FFATPluginsView new];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
        [item addGestureRecognizer:tapGestureRecognizer];
        [itemsArray addObject:item];
    }
    self.items = itemsArray;
}

#pragma mark - Action
- (void)tapGestureAction:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (_delegate && [_delegate respondsToSelector:@selector(viewController:didSelectedAtPosition:)]) {
        FFATPluginsView *item = (FFATPluginsView *)tapGestureRecognizer.view;
        [_delegate viewController:self didSelectedAtPosition:item.position];
    }
}

@end
