//
//  FFATPadStackViewController.h
//  BrcIot
//
//  Created by LiXiangCheng on 2018/10/29.
//  Copyright © 2018年 BRC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFATPluginsViewController.h"

@class FFATPadStackViewController;

@protocol FFATPadStackDelegate <NSObject>
- (void)stack:(FFATPadStackViewController *_Nonnull)stack actionBeginAtPoint:(CGPoint)point;
- (void)stack:(FFATPadStackViewController *_Nonnull)stack actionEndAtPoint:(CGPoint)point;
@end

@interface FFATPadStackViewController : UIViewController

@property (nonatomic, strong, readonly, nonnull) NSMutableArray<FFATPluginsViewController *> *viewControllers;
@property (nonatomic, assign, readonly, getter=isShow) BOOL show;
@property (nonatomic, weak, nullable) id<FFATPadStackDelegate> delegate;

- (instancetype _Nonnull )initWithRootViewController:(nullable FFATPluginsViewController *)viewController NS_DESIGNATED_INITIALIZER;

- (void)spread;//展开
- (void)shrink;//收缩
- (void)pushViewController:(FFATPluginsViewController *_Nonnull)viewController atPisition:(FFATPosition *_Nonnull)position;
- (void)popViewController;

- (void)moveContentViewToPoint:(CGPoint)point;

@end

@interface FFATPluginsViewController (AttachNavigator)
@property (nonatomic, weak, nullable) FFATPadStackViewController *navigationController;
@end
