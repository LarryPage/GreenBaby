//
//  WKWebViewController.h
//  BrcIot
//
//  Created by LiXiangCheng on 2019/3/19.
//  Copyright © 2019年 BRC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "WBWKWebView.h"
#import <WBWebViewConsole/WBWebViewConsole.h>
#import <WBWebViewConsole/WBWebDebugConsoleViewController.h>

@interface WKWebViewController : BaseViewController

@property (nonatomic, assign) BOOL navBarHidden;//1:打开页面时隐藏上导航条,0:打开页面显示上导航条，默认0
@property (nonatomic, strong) NSString *navBarBgColor;//上导航条颜色,默认:9870FE
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *urlTag;
@property (nonatomic, copy) void (^actionHandler)(void);
@property (nonatomic, strong) WBWKWebView *webView;
@property (nonatomic,   weak) CALayer *progressLayer;//网页加载进度条
@property (nonatomic, strong) NSString *leftBtnCallBack;
@property (nonatomic, strong) NSString *rightBtnCallBack;

- (id)initWithUrl:(NSString *)url title:(NSString *)title;
- (void)updateShareContent:(NSDictionary *)param;
- (void)openDebug;
@end
