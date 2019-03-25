//
//  WKWebViewController.m
//  BrcIot
//
//  Created by LiXiangCheng on 2019/3/19.
//  Copyright © 2019年 BRC. All rights reserved.
//

#import "WKWebViewController.h"
#import "WKWebViewController+AppJS.h"
#import "ShareSheet.h"

@interface WKWebViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>{
    NSString *_title;
    //分享
    NSString *_shareUrl;
    NSString *_shareTitle;
    NSString *_shareContent;
    UIImage *_shareThumbImage;
}
@end

@implementation WKWebViewController

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithUrl:(NSString *)url title:(NSString *)title{
    if (self = [super initWithNibName:@"WKWebViewController" bundle:nil]) {
        _url = url;
        _urlTag = url;
        _title=title;
        
        _shareThumbImage = [UIImage imageNamed:@"Icon"];
    }
    return self;
}

- (void)dealloc {
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [_progressLayer removeFromSuperlayer];
    _progressLayer = nil;
    
    [_webView stopLoading];
    _webView.navigationDelegate = nil;
    _webView.UIDelegate = nil;
    [_webView removeFromSuperview];
    _webView=nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = _title;
    
    if (!([_url hasPrefix:@"http://"] || [_url hasPrefix:@"https://"] || [_url hasPrefix:@"file://"])) {
        _url = [NSString stringWithFormat:@"http://%@", _url];
    }
    //WBUIWebView
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc]init];
    config.selectionGranularity = WKSelectionGranularityDynamic;
    config.allowsInlineMediaPlayback = YES;
    //设置偏好设置
    config.preferences = [[WKPreferences alloc] init];
    //默认为0
    config.preferences.minimumFontSize = 10;
    //默认认为YES
    config.preferences.javaScriptEnabled = YES;
    //在iOS上默认为NO，表示不能自动通过窗口打开
    config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    //web内容处理池
    config.processPool = [[WKProcessPool alloc] init];
    //通过JS与webview内容交互
    config.userContentController = [[WKUserContentController alloc] init];
    NSString *path =[[NSBundle mainBundle] pathForResource:@"ios_brige" ofType:@"js"];
    NSString *handlerJS = [NSString stringWithContentsOfFile:path encoding:kCFStringEncodingUTF8 error:nil];
    //handlerJS = [handlerJS stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    WKUserScript *usrScript = [[WKUserScript alloc] initWithSource:handlerJS injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    [config.userContentController addUserScript:usrScript];
    //在WKScriptMessageHandler代理中接收到
    [config.userContentController addScriptMessageHandler:self name:@"BRC"];
    
    self.webView = [[WBWKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    self.webView.JSBridge.interfaceName = @"WKWebViewBridge";
    self.webView.JSBridge.readyEventName = @"WKWebViewBridgeReady";
    self.webView.JSBridge.invokeScheme = @"wkwebview-bridge://invoke";
    self.webView.navigationDelegate = self;
    self.webView.UIDelegate = self;
    [self.view addSubview:self.webView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_webView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_webView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_webView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_webView)]];
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    //修复下拉刷新位置错误 代码开始
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        if (self.navBarHidden) {
            UIEdgeInsets insets = self.webView.scrollView.contentInset;
            insets.top = IS_IPHONE_X?-44:-20;
            insets.bottom = -1;
            self.webView.scrollView.contentInset = insets;
            self.webView.scrollView.scrollIndicatorInsets = insets;
        }
    }
    
    //隐藏WKWebView 后面灰背景的方法
    _webView.backgroundColor = [UIColor clearColor];
    _webView.opaque = NO;
    id scroller = [_webView.subviews objectAtIndex:0];
    for (UIView *subView in [scroller subviews])
    {
        if ([[[subView class] description] isEqualToString:@"UIImageView"])
            subView.hidden = YES;
    }
    _webView.backgroundColor=[UIColor clearColor];
    
    /*添加进度条*/
    CGFloat progressHeight = 2.f;
    CGRect progressFrame = CGRectMake(0, 0, SCREEN_WIDTH, progressHeight);
    CALayer *layer = [CALayer layer];
    layer.frame = progressFrame;
    layer.backgroundColor = [UIColor colorWithRed:22.f / 255.f green:126.f / 255.f blue:251.f / 255.f alpha:1.0].CGColor;
    [self.webView.layer addSublayer:layer];
    self.progressLayer = layer;
    
    _webView.scrollView.bounces = NO;
    _webView.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    //[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:_url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];//保证URL每次刷新
    
    //保证URL每次刷新，防止相关网页缓存 8.0
    //urlRequest.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    //自定义UIWebView User-Agent
    //[urlRequest setValue:[NSString stringWithFormat:@"BrcIot_ios %@",kVersion] forHTTPHeaderField: @"User-Agent"];
    //上面方法不起作用http://imtx.me/archives/1883.html
    [_webView loadRequest:urlRequest];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:self.navBarHidden animated:YES];
    
    if (self.navBarBgColor && self.navBarBgColor.length>=6) {
        UIColor *navBarTintColor=[UIColor colorWithHexString:self.navBarBgColor];
        self.navigationController.navigationBar.barTintColor=navBarTintColor;//the bar background
        [self.navigationController.navigationBar setBackgroundImage:[UIImage createImageWithColor:navBarTintColor] forBarMetrics:UIBarMetricsDefault];
    }
    
    //页面显示回调
    NSString *functionJS = @"OnViewResume();";
    [self.webView evaluateJavaScript:functionJS
                   completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                       NSLog(@"%@=====%@",response,error);
                   }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self setNavigationBarAttribute:self.navigationController.navigationBar];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self webDebugAddContextMenuItems];
    
    //BRC_backWebView for7.1
    if(_actionHandler){
        _actionHandler();
        _actionHandler=nil;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self webDebugRemoveContextMenuItems];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey, id> *)change context:(nullable void *)context{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressLayer.opacity = 1;
        if ([change[@"new"] floatValue] <[change[@"old"] floatValue]) {
            return;
        }
        //CGFloat newProgress = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];//=[change[@"new"] floatValue]
        CGRect progressFrame = self.progressLayer.frame;
        self.progressLayer.frame = CGRectMake(progressFrame.origin.x, progressFrame.origin.y, SCREEN_WIDTH*[change[@"new"] floatValue], progressFrame.size.height);
        if ([change[@"new"]floatValue] == 1.0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressLayer.opacity = 0;
                self.progressLayer.frame = CGRectMake(progressFrame.origin.x, progressFrame.origin.y, 0, progressFrame.size.height);
            });
        }
    }
}

#pragma mark Action

- (void)back {
    if (self.leftBtnCallBack.length > 0) {
        //回调
        [self.webView evaluateJavaScript:self.leftBtnCallBack
                       completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                           NSLog(@"%@=====%@",response,error);
                       }];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)rightBtn:(id)sender{
    if (self.rightBtnCallBack.length > 0) {
        //回调
        [self.webView evaluateJavaScript:self.rightBtnCallBack
                       completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                           NSLog(@"%@=====%@",response,error);
                       }];
    }
    else{
        ShareSheet *shareSheet = [ShareSheet initImageNames:@[@"weixin",@"pengyouquan"]
                                                     titles:@[@"微信好友",@"微信朋友圈"]
                                                 completion:^(NSInteger buttonIndex, id welkSelf){
                                                     if (![WXApi isWXAppSupportApi]) {
                                                         [[TKAlertCenter defaultCenter] postAlertWithMessage:@"当前微信的版本不支持OpenApi"];
                                                     }
                                                     else{
                                                         WXMediaMessage *message = [WXMediaMessage message];
                                                         message.title = _shareTitle;
                                                         message.description = _shareContent;
                                                         [message setThumbImage:_shareThumbImage];
                                                         WXWebpageObject *ext = [WXWebpageObject object];
                                                         ext.webpageUrl = _shareUrl;
                                                         message.mediaObject = ext;
                                                         
                                                         SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
                                                         req.bText = NO;
                                                         req.message = message;
                                                         req.scene = buttonIndex == 0 ? WXSceneSession : WXSceneTimeline;
                                                         [WXApi sendReq:req];
                                                     }
                                                 }];
        shareSheet.tipLbl.text = @"分享广播通知到";
        [shareSheet show];
    }
}

- (void)updateShareContent:(NSDictionary *)param{
    _shareUrl = [param objectForKey:@"pageUrl"];
    _shareTitle = [param objectForKey:@"title"];
    _shareContent = [param objectForKey:@"content"];
    NSURL *url=[NSURL URLWithString:[param objectForKey:@"imageUrl"]];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager loadImageWithURL:url
                      options:SDWebImageRetryFailed
                     progress:nil
                    completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                        if (image) {
                            // do something with image
                            _shareThumbImage=image;
                        }
                    }];
}

- (void)openDebug{
    WBWebDebugConsoleViewController * controller = [[WBWebDebugConsoleViewController alloc] initWithConsole:_webView.console];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)webDebugAddContextMenuItems
{
    UIMenuItem * item = [[UIMenuItem alloc] initWithTitle:@"Inspect Element" action:@selector(webDebugInspectCurrentSelectedElement:)];
    [[UIMenuController sharedMenuController] setMenuItems:@[item]];
}

- (void)webDebugRemoveContextMenuItems
{
    [[UIMenuController sharedMenuController] setMenuItems:nil];
}

- (void)webDebugInspectCurrentSelectedElement:(id)sender
{
    NSString * variable = @"WeiboConsoleLastSelection";
    
    [self.webView.console storeCurrentSelectedElementToJavaScriptVariable:variable completion:^(BOOL success) {
        if (success)
        {
            WBWebDebugConsoleViewController * consoleViewController = [[WBWebDebugConsoleViewController alloc] initWithConsole:self.webView.console];
            consoleViewController.initialCommand = variable;
            
            [self.navigationController pushViewController:consoleViewController animated:YES];
        }
        else
        {
            [UIAlertController alert:nil title:@"Can not get current selected element" bTitle:@"确定"];
        }
    }];
}

#pragma mark WKNavigationDelegate

//对于即将跳转的HTTP信息来决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    BOOL result = YES;
    
    if ([self.webView.JSBridge handleWebViewRequest:navigationAction.request]) {
        result = NO;
    }
    else{
        NSURL *url = navigationAction.request.URL;
        if ([FFRouteManager supportSchemeURL:url]) {//APPInScheme:内部跳转Scheme
            if([FFRouteManager canRouteURL:url]){
                [FFRouteManager routeURL:url];
            }
            else{
                [FFRouteManager routeReduceURL:url];
            }
            result = NO;
        }
    }
    
    if (result) {
        [self.webView webDebugLogProvisionalNavigation:navigationAction.request navigationType:navigationAction.navigationType result:result];
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

//接收到服务器重新配置请求之后再执行
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
}

//页面开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

//页面正在加载当中:页面内容到达main frame时回调
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation{
}

//页面加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    //html页面载入完成回调
    NSString *functionJS = @"onViewLoad();";
    [self.webView evaluateJavaScript:functionJS
                   completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                       NSLog(@"%@=====%@",response,error);
                   }];
}

//页面加载失败
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self.webView webDebugLogLoadFailedWithError:error];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    [self.webView webDebugLogLoadFailedWithError:error];
}

#pragma mark WKUIDelegate

// js调用alert:获取js 里面的提示
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
}

// js调用prompt:可输入的文本
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable result))completionHandler{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:prompt message:defaultText preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor redColor];
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler([[alert.textFields lastObject] text]);
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
}

// js调用confirm:信息的交流
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
}

#pragma mark WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    WEAKSELF
    if ([message.name isEqualToString:@"BRC"]){
        NSDictionary *wrapDic=[NSDictionary safeDictionaryFromObject:message.body];
        NSString *methodName = [NSString safeStringFromObject:[wrapDic objectForKey:@"method"]];
        NSDictionary *paramsDic = [NSDictionary safeDictionaryFromObject:[wrapDic objectForKey:@"params"]];
        NSString *callbackName = [NSString safeStringFromObject:[wrapDic objectForKey:@"callback"]];
        if (paramsDic && paramsDic.count==0) {
            paramsDic=nil;
        }
        if (callbackName && callbackName.length==0) {
            callbackName=nil;
        }
        
        if (callbackName) {
            [self interactWitMethodName:methodName
                              paramsDic:paramsDic
                              completed:^(id response) {
                                  NSString *functionJS = [NSString stringWithFormat:@"setTimeout(%@(%@),0);",callbackName,response];
                                  [weakSelf.webView evaluateJavaScript:functionJS
                                                     completionHandler:^(id _Nullable response, NSError * _Nullable error) {
                                                         NSLog(@"%@=====%@",response,error);
                                                     }];
                              }];
        }else{
            [self interactWitMethodName:methodName paramsDic:paramsDic completed:nil];
        }
    }
}

@end
