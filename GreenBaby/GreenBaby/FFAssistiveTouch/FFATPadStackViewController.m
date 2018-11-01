//
//  FFATPadStackViewController.m
//  BrcIot
//
//  Created by LiXiangCheng on 2018/10/29.
//  Copyright © 2018年 BRC. All rights reserved.
//

#import "FFATPadStackViewController.h"
#import "UIView+WhenTappedBlocks.h"

@interface FFATPadStackViewController ()

@property (nonatomic, strong) NSMutableArray<FFATPosition *> *pushPosition;
@property (nonatomic, strong) FFATPluginsView *contentItem;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, assign) CGPoint contentPoint;
@property (nonatomic, assign) CGFloat contentAlpha;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL show;

@end

@implementation FFATPadStackViewController

//for ios7
- (UIStatusBarStyle)preferredStatusBarStyle{
    UIViewController *topVc=[AppDelegate sharedAppDelegate].window.topViewController;
    return topVc.preferredStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden {
    UIViewController *topVc=[AppDelegate sharedAppDelegate].window.topViewController;
    return topVc.prefersStatusBarHidden;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [self initWithRootViewController:nil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithRootViewController:nil];
}

- (instancetype)initWithRootViewController:(nullable FFATPluginsViewController *)viewController {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        if (!viewController) {
            viewController = [FFATPluginsViewController new];
        }
        FFATPluginsViewController *rootViewController = viewController;
        rootViewController.navigationController = self;
        _viewControllers = [NSMutableArray arrayWithObject:rootViewController];
        _pushPosition = [NSMutableArray array];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    _contentPoint = [FFATLayoutAttributes cotentViewDefaultPoint];
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [FFATLayoutAttributes itemImageWidth], [FFATLayoutAttributes itemImageWidth])];
    _contentView.center = _contentPoint;
    _contentView.layer.cornerRadius = 14;
    [self.view addSubview:_contentView];
    
    _effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    _effectView.frame = _contentView.bounds;
    _effectView.layer.cornerRadius = [FFATLayoutAttributes cornerRadius];
    _effectView.layer.masksToBounds = YES;
    [_contentView addSubview:_effectView];
    
    _contentItem = [FFATPluginsView itemWithType:FFATPluginViewTypeSystem customImg:@""];
    _contentItem.center = _contentPoint;
    [self.view addSubview:_contentItem];
    
    self.view.frame = CGRectMake(0, 0, [FFATLayoutAttributes itemImageWidth], [FFATLayoutAttributes itemImageWidth]);
    self.contentAlpha = [FFATLayoutAttributes inactiveAlpha];
    self.contentPoint = CGPointMake([FFATLayoutAttributes itemImageWidth] / 2, [FFATLayoutAttributes itemImageWidth] / 2);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *spreadGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(spread)];
    UITapGestureRecognizer *shrinkGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shrink)];
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    [self.contentItem addGestureRecognizer:spreadGestureRecognizer];
    [self.view addGestureRecognizer:shrinkGestureRecognizer];
    [self.contentItem addGestureRecognizer:panGestureRecognizer];
}

#pragma mark - Accessor

- (void)moveContentViewToPoint:(CGPoint)point {
    self.contentPoint = point;
}

- (void)setContentPoint:(CGPoint)contentPoint {
    if (!self.isShow) {
        _contentPoint = contentPoint;
        _contentView.center = _contentPoint;
        _contentItem.center = _contentPoint;
    }
}

- (void)setContentAlpha:(CGFloat)contentAlpha {
    if (!self.isShow) {
        _contentAlpha = contentAlpha;
        _contentView.alpha = _contentAlpha;
        _contentItem.alpha = _contentAlpha;
    }
}

- (void)setViewControllers:(NSMutableArray<FFATPluginsViewController *> *)viewControllers {
    _viewControllers = viewControllers;
}

#pragma mark - Animition

- (void)spread {
    if (self.isShow) {
        return;
    }
    [self stopTimer];
    [self invokeActionBeginDelegate];
    [self setShow:YES];
    NSUInteger count = _viewControllers.firstObject.items.count;
    for (int i = 0; i < count; i++) {
        FFATPluginsView *item = _viewControllers.firstObject.items[i];
        item.alpha = 0;
        item.center = _contentPoint;
        [self.view addSubview:item];
        [UIView animateWithDuration:[FFATLayoutAttributes animationDuration] animations:^{
            item.center = [FFATPosition positionWithCount:count index:i].center;
            item.alpha = 1;
        }];
    }
    
    [UIView animateWithDuration:[FFATLayoutAttributes animationDuration] animations:^{
        _contentView.frame = [FFATLayoutAttributes contentViewSpreadFrame];
        _effectView.frame = _contentView.bounds;
        _contentView.alpha = 1;
        _contentItem.center = [FFATPosition positionWithCount:count index:count - 1].center;
        _contentItem.alpha = 0;
    }];
}

- (void)shrink {
    if (!self.isShow) {
        return;
    }
    [self beginTimer];
    [self setShow:NO];
    for (FFATPluginsView *item in _viewControllers.lastObject.items) {
        [UIView animateWithDuration:[FFATLayoutAttributes animationDuration] animations:^{
            item.center = _contentPoint;
            item.alpha = 0;
        }];
    }
    [UIView animateWithDuration:[FFATLayoutAttributes animationDuration] animations:^{
        _viewControllers.lastObject.backItem.center = _contentPoint;
        _viewControllers.lastObject.backItem.alpha = 0;
    }];
    
    [UIView animateWithDuration:[FFATLayoutAttributes animationDuration] animations:^{
        _contentView.frame = CGRectMake(0, 0, [FFATLayoutAttributes itemImageWidth], [FFATLayoutAttributes itemImageWidth]);
        _contentView.center = _contentPoint;
        _effectView.frame = _contentView.bounds;
        _contentItem.alpha = 1;
        _contentItem.center = _contentPoint;
    } completion:^(BOOL finished) {
        for (FFATPluginsViewController *viewController in _viewControllers) {
            [viewController.items makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [viewController.backItem removeFromSuperview];
        }
        _viewControllers = [NSMutableArray arrayWithObject:_viewControllers.firstObject];
        [self invokeActionEndDelegate];
    }];
}

- (void)pushViewController:(FFATPluginsViewController *)viewController atPisition:(FFATPosition *)position {
    FFATPluginsViewController *oldViewController = _viewControllers.lastObject;
    for (FFATPluginsView *item in oldViewController.items) {
        [UIView animateWithDuration:[FFATLayoutAttributes animationDuration] animations:^{
            item.alpha = 0;
        }];
    }
    [UIView animateWithDuration:[FFATLayoutAttributes animationDuration] animations:^{
        oldViewController.backItem.alpha = 0;
    }];
    
    NSUInteger count = viewController.items.count;
    for (int i = 0; i < count; i++) {
        FFATPluginsView *item = viewController.items[i];
        FFSDCDataModel *itemData = viewController.itemsData[i];
        [item whenTapped:^{
            if ([itemData.pluginName isEqualToString:@"吸颜色"]) {
//                FFMagnifierPlugin *magnifier = [FFMagnifierPlugin sharedFFMagnifierPlugin];
//                [magnifier showMagnifier:!magnifier.isCurrentBorderShowing];
            }
            else if([itemData.pluginName isEqualToString:@"边框"]) {
//                FFBorderPlugin *borderPlugin = [FFBorderPlugin sharedFFBorderPlugin];
//                [borderPlugin showBorder:!borderPlugin.isCurrentBorderShowing];
            }
            else if([itemData.pluginName isEqualToString:@"帧率"]) {
//                FFFPSPlugin *fps = [FFFPSPlugin sharedFFFPSPlugin];
//                [fps showFPSView:!fps.isCurrentShowing function:@"Frame"];
            }
            else if([itemData.pluginName isEqualToString:@"CPU"]) {
//                FFFPSPlugin *fps = [FFFPSPlugin sharedFFFPSPlugin];
//                [fps showFPSView:!fps.isCurrentShowing function:@"CPU"];
            }
            else if([itemData.pluginName isEqualToString:@"内存"]) {
//                FFFPSPlugin *fps = [FFFPSPlugin sharedFFFPSPlugin];
//                [fps showFPSView:!fps.isCurrentShowing function:@"Memory"];
            }
            else if([itemData.pluginName isEqualToString:@"崩溃信息"]) {
//                FFSCrashReprortPlugin *crash = [FFSCrashReprortPlugin sharedFFSCrashReprortPlugin];
//                [crash showCrashHistPage];
            }
            [self shrink];
        }];
        item.alpha = 0;
        item.center = position.center;
        item.nameLbl.text=itemData.pluginName;
        [self.view addSubview:item];
        [UIView animateWithDuration:[FFATLayoutAttributes animationDuration] animations:^{
            item.center = [FFATPosition positionWithCount:count index:i].center;
            item.alpha = 1;
        }];
    }
    viewController.backItem.alpha = 0;
    viewController.backItem.center = position.center;
    [self.view addSubview:viewController.backItem];
    [UIView animateWithDuration:[FFATLayoutAttributes animationDuration] animations:^{
        viewController.backItem.center = self.view.center;
        viewController.backItem.alpha = 1;
    }];
    
    viewController.navigationController = self;
    [_viewControllers addObject:viewController];
    [_pushPosition addObject:position];
}

- (void)popViewController {
    if (_pushPosition.count > 0) {
        FFATPosition *position = _pushPosition.lastObject;
        for (FFATPluginsView *item in _viewControllers.lastObject.items) {
            [UIView animateWithDuration:[FFATLayoutAttributes animationDuration] animations:^{
                item.center = position.center;
                item.alpha = 0;
            }];
        }
        [UIView animateWithDuration:[FFATLayoutAttributes animationDuration] animations:^{
            _viewControllers.lastObject.backItem.center = position.center;
            _viewControllers.lastObject.backItem.alpha = 0;
        } completion:^(BOOL finished) {
            [_viewControllers.lastObject.items makeObjectsPerformSelector:@selector(removeFromSuperview)];
            [_viewControllers.lastObject.backItem removeFromSuperview];
            [_viewControllers removeLastObject];
            for (FFATPluginsView *item in _viewControllers.lastObject.items) {
                [UIView animateWithDuration:[FFATLayoutAttributes animationDuration] animations:^{
                    item.alpha = 1;
                }];
            }
            [UIView animateWithDuration:[FFATLayoutAttributes animationDuration] animations:^{
                _viewControllers.lastObject.backItem.alpha = 1;
            }];
        }];
    }
}

#pragma mark - Timer

- (void)beginTimer {
    _timer = [NSTimer timerWithTimeInterval:[FFATLayoutAttributes activeDuration] target:self selector:@selector(timerFired) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    [_timer invalidate];
    _timer = nil;
}

- (void)timerFired {
    [UIView animateWithDuration:[FFATLayoutAttributes animationDuration] animations:^{
        self.contentAlpha = [FFATLayoutAttributes inactiveAlpha];
    }];
    [self stopTimer];
}

#pragma mark - Action

- (void)panGestureAction:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.view];
    
    static CGPoint pointOffset;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pointOffset = [gestureRecognizer locationInView:self.contentItem];
    });
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self invokeActionBeginDelegate];
        [self stopTimer];
        [UIView animateWithDuration:[FFATLayoutAttributes animationDuration] animations:^{
            self.contentAlpha = 1;
        }];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        self.contentPoint = CGPointMake(point.x + [FFATLayoutAttributes itemImageWidth] / 2 - pointOffset.x, point.y  + [FFATLayoutAttributes itemImageWidth] / 2 - pointOffset.y);
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded
               || gestureRecognizer.state == UIGestureRecognizerStateCancelled
               || gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        [UIView animateWithDuration:[FFATLayoutAttributes animationDuration] animations:^{
            self.contentPoint = [self stickToPointByHorizontal];
        } completion:^(BOOL finished) {
            [self invokeActionEndDelegate];
            onceToken = NO;
            [self beginTimer];
        }];
    }
}

#pragma mark - StickToPoint

- (CGPoint)stickToPointByHorizontal {
    CGRect screen = [UIScreen mainScreen].bounds;
    CGPoint center = self.contentPoint;
    if (center.y < center.x && center.y < -center.x + screen.size.width) {
        CGPoint point = CGPointMake(center.x, [FFATLayoutAttributes margin] + [FFATLayoutAttributes itemImageWidth] / 2);
        point = [self makePointValid:point];
        return point;
    } else if (center.y > center.x + screen.size.height - screen.size.width
               && center.y > -center.x + screen.size.height) {
        CGPoint point = CGPointMake(center.x, CGRectGetHeight(screen) - [FFATLayoutAttributes itemImageWidth] / 2 - [FFATLayoutAttributes margin]);
        point = [self makePointValid:point];
        return point;
    } else {
        if (center.x < screen.size.width / 2) {
            CGPoint point = CGPointMake([FFATLayoutAttributes margin] + [FFATLayoutAttributes itemImageWidth] / 2, center.y);
            point = [self makePointValid:point];
            return point;
        } else {
            CGPoint point = CGPointMake(CGRectGetWidth(screen) - [FFATLayoutAttributes itemImageWidth] / 2 - [FFATLayoutAttributes margin], center.y);
            point = [self makePointValid:point];
            return point;
        }
    }
}

- (CGPoint)makePointValid:(CGPoint)point {
    CGRect screen = [UIScreen mainScreen].bounds;
    if (point.x < [FFATLayoutAttributes margin] + [FFATLayoutAttributes itemImageWidth] / 2) {
        point.x = [FFATLayoutAttributes margin] + [FFATLayoutAttributes itemImageWidth] / 2;
    }
    if (point.x > CGRectGetWidth(screen) - [FFATLayoutAttributes itemImageWidth] / 2 - [FFATLayoutAttributes margin]) {
        point.x = CGRectGetWidth(screen) - [FFATLayoutAttributes itemImageWidth] / 2 - [FFATLayoutAttributes margin];
    }
    if (point.y < [FFATLayoutAttributes margin] + [FFATLayoutAttributes itemImageWidth] / 2) {
        point.y = [FFATLayoutAttributes margin] + [FFATLayoutAttributes itemImageWidth] / 2;
    }
    if (point.y > CGRectGetHeight(screen) - [FFATLayoutAttributes itemImageWidth] / 2 - [FFATLayoutAttributes margin]) {
        point.y = CGRectGetHeight(screen) - [FFATLayoutAttributes itemImageWidth] / 2 - [FFATLayoutAttributes margin];
    }
    return point;
}

#pragma mark - Private

- (void)invokeActionBeginDelegate {
    if (!self.isShow && _delegate && [_delegate respondsToSelector:@selector(stack:actionBeginAtPoint:)]) {
        [_delegate stack:self actionBeginAtPoint:self.contentPoint];
    }
}

- (void)invokeActionEndDelegate {
    if (_delegate && [_delegate respondsToSelector:@selector(stack:actionEndAtPoint:)]) {
        [_delegate stack:self actionEndAtPoint:self.contentPoint];
    }
}

@end

static const void *navigationControllerKey = &navigationControllerKey;

@implementation FFATPluginsViewController (AttachNavigator)

@dynamic navigationController;

- (FFATPadStackViewController *)navigationController {
    return objc_getAssociatedObject(self, navigationControllerKey);
}

- (void)setNavigationController:(FFATPadStackViewController *)navigationController {
    objc_setAssociatedObject(self, navigationControllerKey, navigationController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
