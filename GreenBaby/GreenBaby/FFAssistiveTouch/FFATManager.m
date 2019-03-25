//
//  FFATManager.m
//  BrcIot
//
//  Created by LiXiangCheng on 2018/10/29.
//  Copyright © 2018年 BRC. All rights reserved.
//

#import "FFATManager.h"
#import "CLogViewController.h"
#import "TestSpecailViewController.h"

@interface FFATManager ()
@property (nonatomic, assign) CGPoint assistiveWindowPoint;
@property (nonatomic, assign) CGPoint coverWindowPoint;
@end

@implementation FFATManager

SINGLETON_IMP(FFATManager)

- (id)init{
    self = [super init];
    if (self) {
        // Initialization code here.
        FFATPluginsViewController *rootViewController = [FFATPluginsViewController new];
        rootViewController.delegate = self;
        _navigationController = [[FFATPadStackViewController alloc] initWithRootViewController:rootViewController];
        _navigationController.delegate = self;
        
        _assistiveWindowPoint = [FFATLayoutAttributes cotentViewDefaultPoint];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Action

- (void)showAssistiveTouch {
    if (!_assistiveWindow) {
        _assistiveWindow = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, [FFATLayoutAttributes itemImageWidth], [FFATLayoutAttributes itemImageWidth])];
        _assistiveWindow.center = _assistiveWindowPoint;
        _assistiveWindow.windowLevel = CGFLOAT_MAX;
        _assistiveWindow.backgroundColor = [UIColor clearColor];
        _assistiveWindow.rootViewController = _navigationController;
//        [self makeVisibleWindow];
    }
    _assistiveWindow.hidden = NO;
}

- (void)dismiss {
    _assistiveWindow.hidden = YES;
}

- (void)makeVisibleWindow {
    UIWindow *keyWindows = [UIApplication sharedApplication].keyWindow;
//    [_assistiveWindow makeKeyAndVisible];
    if (keyWindows) {
        [keyWindows makeKeyWindow];
    }
}

#pragma mark - FFATDelegate

- (NSInteger)numberOfItemsInViewController:(FFATPluginsViewController *)viewController {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"FFAssistiveTouch.bundle/plugins" ofType:@"plist"];
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    
    FFSDCDataModel *sdcModel = [[FFSDCDataModel alloc] initWithDic:dic];
    self.pluginsData = sdcModel;
    return [self.pluginsData.subNode count];
}

- (FFATPluginsView *)viewController:(FFATPluginsViewController *)viewController itemViewAtPosition:(FFATPosition *)position {
    FFSDCDataModel *model = [self.pluginsData.subNode objectAtIndex:position.index];
    FFATPluginsView *pluginsView=[FFATPluginsView itemWithImage:[UIImage imageNamed:model.iconName]];
    pluginsView.nameLbl.text=model.pluginName;
    return pluginsView;
}

- (void)viewController:(FFATPluginsViewController *)viewController didSelectedAtPosition:(FFATPosition *)position {
    FFSDCDataModel *pluginModel = [self.pluginsData.subNode objectAtIndex:position.index];
    NSMutableArray *array = [NSMutableArray new];
    for (int i = 0; i < [pluginModel.subNode count]; i++) {
        FFSDCDataModel *indexModel = [pluginModel.subNode objectAtIndex:i];
        FFATPluginsView *itemView = [FFATPluginsView itemWithImage:[UIImage imageNamed:indexModel.iconName ]];
        [array addObject:itemView];
    }
    
    if ([pluginModel.pluginName isEqualToString:@"日志"]) {
        UIViewController *vc=[[CLogViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [[AppDelegate sharedAppDelegate].window.topViewController.navigationController pushViewController:vc animated:YES];
        
        [_navigationController setNeedsStatusBarAppearanceUpdate];//ios7 刷新状态栏样式
        [self.navigationController shrink];
        return;
    }
    else if([pluginModel.pluginName isEqualToString:@"环境配置"]){
        UIViewController *vc=[[TestSpecailViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [[AppDelegate sharedAppDelegate].window.topViewController.navigationController pushViewController:vc animated:YES];
        
        [_navigationController setNeedsStatusBarAppearanceUpdate];//ios7 刷新状态栏样式
        [self.navigationController shrink];
        return;
    }else if([pluginModel.pluginName isEqualToString:@"FLEX"]) {
        UIViewController *topViewController=[AppDelegate sharedAppDelegate].window.topViewController;
        if([topViewController isKindOfClass:[WebViewController class]]){
            [(WebViewController *)topViewController openDebug];
        }
        else if([topViewController isKindOfClass:[WKWebViewController class]]){
            [(WKWebViewController *)topViewController openDebug];
        }
        else{
            //[[FLEXManager sharedManager] showExplorer];
        }
        [self.navigationController shrink];
        return;
    }else if([pluginModel.pluginName isEqualToString:@"刷新"]) {
        UIViewController *topVc=[AppDelegate sharedAppDelegate].window.topViewController;
        [topVc viewWillAppear:NO];
        [topVc viewDidAppear:NO];
        [self.navigationController shrink];
        return;
    }
//    else if([pluginModel.pluginName isEqualToString:@"性能"]) {
//        //FFFPSPlugin *fps = [FFFPSPlugin sharedFFFPSPlugin];
//        //[fps showFPSView:!fps.isCurrentShowing function:@"Frame"];
//        [self.navigationController shrink];
//        return;
//    }
    
    FFATPluginsViewController *vc = [[FFATPluginsViewController alloc] initWithItems:[array copy]];
    vc.itemsData = pluginModel.subNode;
    [self.navigationController pushViewController:vc atPisition:position];
    
}

#pragma mark - FFATPadStackDelegate

- (void)stack:(FFATPadStackViewController *)stack actionBeginAtPoint:(CGPoint)point {
    _coverWindowPoint = CGPointZero;
    _assistiveWindow.frame = [UIScreen mainScreen].bounds;
    _navigationController.view.frame = [UIScreen mainScreen].bounds;
    [_navigationController moveContentViewToPoint:_assistiveWindowPoint];
}

- (void)stack:(FFATPadStackViewController *)stack actionEndAtPoint:(CGPoint)point {
    _assistiveWindowPoint = point;
    _assistiveWindow.frame = CGRectMake(0, 0, [FFATLayoutAttributes itemImageWidth], [FFATLayoutAttributes itemImageWidth]);
    _assistiveWindow.center = _assistiveWindowPoint;
    CGPoint contentPoint = CGPointMake([FFATLayoutAttributes itemImageWidth] / 2, [FFATLayoutAttributes itemImageWidth] / 2);
    [_navigationController moveContentViewToPoint:contentPoint];
}

#pragma mark - UIKeyboardWillChangeFrameNotification
- (void)keyboardWillChangeFrame:(NSNotification *)notification {
    
    /*因为动画过程中不能实时修改_assistiveWindowRect,
     *所以如果执行点击操作的话,_assistiveTouchView位置会以动画之前的位置为准.
     *如果执行拖动操作则会有跳动效果.所以需要禁止用户操作.*/
    _assistiveWindow.userInteractionEnabled = NO;
    NSDictionary *info = [notification userInfo];
    CGFloat duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect endKeyboardRect = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    //根据实时位置计算于键盘的间距
    CGFloat yOffset = endKeyboardRect.origin.y - CGRectGetMaxY(_assistiveWindow.frame);
    
    //如果键盘弹起给_coverWindowPoint赋值
    if (endKeyboardRect.origin.y < CGRectGetHeight([UIScreen mainScreen].bounds)) {
        _coverWindowPoint = _assistiveWindowPoint;
    }
    
    //根据间距计算移动后的位置viewPoint
    CGPoint viewPoint = _assistiveWindow.center;
    viewPoint.y += yOffset;
    //如果viewPoint在原位置之下,将viewPoint变为原位置
    if (viewPoint.y > _coverWindowPoint.y) {
        viewPoint.y = _coverWindowPoint.y;
    }
    //如果_assistiveWindow被移动,将viewPoint变为移动后的位置
    if (CGPointEqualToPoint(_coverWindowPoint, CGPointZero)) {
        viewPoint.y = _assistiveWindow.center.y;
    }
    
    //根据计算好的位置执行动画
    [UIView animateWithDuration:duration animations:^{
        _assistiveWindow.center = viewPoint;
    } completion:^(BOOL finished) {
        //将_assistiveWindowRect变为移动后的位置并恢复用户操作
        _assistiveWindowPoint = _assistiveWindow.center;
        _assistiveWindow.userInteractionEnabled = YES;
        //使其遮盖键盘
        if ([[UIDevice currentDevice].systemVersion integerValue] < 10) {
            [self makeVisibleWindow];
        }else {
            NSArray *windows = [UIApplication sharedApplication].windows;
            [windows enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if([obj isKindOfClass:NSClassFromString(@"UITextEffectsWindow")]) {
                    if (obj && [obj respondsToSelector:@selector(windowLevel)]) {
                        CGFloat lv = [obj windowLevel];
                        _assistiveWindow.windowLevel = lv + 1;
                    }
                    *stop = YES;
                }
            }];
        }
    }];
}

@end
