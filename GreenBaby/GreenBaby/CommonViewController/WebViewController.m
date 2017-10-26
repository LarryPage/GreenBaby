//
//  WebViewController.m
//  CardBump
//
//  Created by 香成 李 on 12-01-29.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WebViewController.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "ShareSheet.h"

@interface WebViewController ()<UIWebViewDelegate,NJKWebViewProgressDelegate>{
    NSString *_title;
    NSString *_content;
    UIImage *_thumbImage;
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
}
@property (nonatomic, strong) WBUIWebView *webView;
@property (nonatomic, strong, readwrite) JSContext *jsContext;
@end

@implementation WebViewController

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
    if (self = [super initWithNibName:@"WebViewController" bundle:nil]) {
        _url = url;
        _urlTag = @"";
        _title=title;
        _thumbImage = [UIImage imageNamed:@"Icon"];
    }
    return self;
}

- (void)dealloc {
    _progressProxy.webViewProxyDelegate = nil;
    _progressProxy.progressDelegate = nil;
    _progressProxy = nil;
    _progressView = nil;
    [_webView stopLoading];
    _webView.delegate = nil;
    _webView=nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //self.title = url;
    
    if (!([_url hasPrefix:@"http://"] || [_url hasPrefix:@"https://"])) {
        _url = [NSString stringWithFormat:@"http://%@", _url];
    }
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = YES;
    //WBUIWebView
    self.webView = [[WBUIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    self.webView.JSBridge.interfaceName = @"UIWebViewBridge";
    self.webView.JSBridge.readyEventName = @"UIWebViewBridgeReady";
    self.webView.JSBridge.invokeScheme = @"uiwebview-bridge://invoke";
    self.webView.wb_delegate = self;
    [self.view addSubview:self.webView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_webView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_webView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_webView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_webView)]];
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotationGesture:)];
    [self.webView addGestureRecognizer:rotationGesture];
    /*添加进度条*/
    _progressProxy = [[NJKWebViewProgress alloc] init];
    _webView.wb_delegate = _progressProxy;
    _progressProxy.webViewProxyDelegate = self;
    _progressProxy.progressDelegate = self;
    CGFloat progressBarHeight = 2.f;
    CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
    _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    //隐藏uiwebview 后面灰背景的方法
    _webView.backgroundColor = [UIColor clearColor];
    _webView.opaque = NO;
    id scroller = [_webView.subviews objectAtIndex:0];
    for (UIView *subView in [scroller subviews])
    {
        if ([[[subView class] description] isEqualToString:@"UIImageView"])
            subView.hidden = YES;
    }
    _webView.backgroundColor=[UIColor clearColor];
    
//    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    _webView.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    //[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:_url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:60];//保证URL每次刷新
    
    //保证URL每次刷新，防止相关网页缓存 8.0
    //urlRequest.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    //自定义UIWebView User-Agent
    //[urlRequest setValue:[NSString stringWithFormat:@"GreenBaby_ios %@",kVersion] forHTTPHeaderField: @"User-Agent"];
    //上面方法不起作用http://imtx.me/archives/1883.html
    [_webView loadRequest:urlRequest];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:self.navBarHidden animated:YES];
    [self.navigationController.navigationBar addSubview:_progressView];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_progressView removeFromSuperview];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self webDebugAddContextMenuItems];
    
    //HJM_backWebView for7.1
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

#pragma mark Action

//2.JavaScriptCore，IOS7以后才开放的API,注意weakSelf(内存释放)
//交互
//http://blog.csdn.net/woaifen3344/article/details/42742893
- (void)setJSContext{  //Js 使用
    _jsContext = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    _jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        CLog(@"异常信息：%@", exceptionValue);
    };
    WEAKSELF
    _jsContext[@"HJM_userInfo"] = ^{
        UserModel *user = [UserModel loadCurRecord];
        if (user && user.user_id) {
            NSString *authString = [NSString stringWithFormat:@"%@:%@", user.username, user.password];
            user.basicAuth = [NSString base64encode:authString];
        } else {
            user.basicAuth = @"";
        }
        NSString *myUserStr=[[user dic] JSONRepresentation];
        return myUserStr;
    };
    _jsContext[@"HJM_sharePage"] = ^(NSDictionary *param) {
        CLog(@"param:%@", param);  //分享
        [weakSelf updateShareContent:param];
    };
    /*
     sharePage
     {
     isShare = 1;  //可以分享  0 不可以分享
     content = "\U9875\U9762\U5185\U5bb9";
     imageUrl = "http://test.huijiame.com/huijia/styles/images/icon/home.png";
     pageUrl = "http://test.huijiame.com/huijia/community_share_list.html";
     title = "\U6211\U5206\U4eab\U7684\U9875\U9762";
     }
     */
    //页面跳转的控制
    _jsContext[@"HJM_pushWebView"] = ^(NSString *url, NSString *title, NSInteger isCreate) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isCreate) {
                NSURL *Url=[NSURL URLWithString:url];
                [[AppDelegate sharedAppDelegate] handleUrl:Url title:title];
            }
            else{
                NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:url]];
                [weakSelf.webView loadRequest:urlRequest];
            }
        });
    };
    _jsContext[@"HJM_popWebView"] = ^() {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        });
    };
    _jsContext[@"HJM_backWebView"] = ^(NSString *tag, NSString *newUrl, NSString *newTitle) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([tag isEqualToString:@""]) {
                UIViewController *vc=weakSelf.navigationController.viewControllers[weakSelf.navigationController.viewControllers.count-2];
                if ([vc isKindOfClass:[WebViewController class]]) {
                    WebViewController *findVC=(WebViewController *)vc;
                    if (newUrl && newUrl.length>0) {
                        findVC.actionHandler=^{
                            NSURL *Url=[NSURL URLWithString:newUrl];
                            [[AppDelegate sharedAppDelegate] handleUrl:Url title:newTitle];
                        };
                    }
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
            else{
                NSInteger idx=-1;
                for (NSInteger i=weakSelf.navigationController.viewControllers.count-1; i>=0; i--) {
                    UIViewController *vc=weakSelf.navigationController.viewControllers[i];
                    if ([vc isKindOfClass:[WebViewController class]]) {
                        WebViewController *findVC=(WebViewController *)vc;
                        if ([findVC.urlTag isEqualToString:tag]) {
                            idx=i;
                            if (newUrl && newUrl.length>0) {
                                findVC.actionHandler=^{
                                    NSURL *Url=[NSURL URLWithString:newUrl];
                                    [[AppDelegate sharedAppDelegate] handleUrl:Url title:newTitle];
                                };
                            }
                            break;
                        }
                    }
                }
                
                if (idx!=-1) {
                    WebViewController *lastVc = weakSelf.navigationController.viewControllers.lastObject;
                    
                    NSMutableArray *navigationArray = [NSMutableArray array];
                    for (NSInteger i = 0; i <= idx; i++) {
                        UIViewController *vc = [weakSelf.navigationController.viewControllers objectAtIndex:i];
                        [navigationArray addObject:vc];
                    }
                    
                    if (![navigationArray containsObject:lastVc]) {
                        [navigationArray addObject:lastVc];
                    }
                    weakSelf.navigationController.viewControllers = navigationArray;
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
                else{
                    if (newUrl && newUrl.length>0) {
                        NSURL *Url=[NSURL URLWithString:newUrl];
                        [[AppDelegate sharedAppDelegate] handleUrl:Url title:newTitle];
                    }
                }
            }
        });
    };
    _jsContext[@"HJM_setWebViewTag"] = ^(NSString *tag) {
        weakSelf.urlTag=tag;
    };
    _jsContext[@"HJM_checkWebView"] = ^(NSString *tag) {
        NSInteger idx=-1;
        for (NSInteger i=weakSelf.navigationController.viewControllers.count-1; i>=0; i--) {
            UIViewController *vc=weakSelf.navigationController.viewControllers[i];
            if ([vc isKindOfClass:[WebViewController class]]) {
                WebViewController *findVC=(WebViewController *)vc;
                if ([findVC.urlTag isEqualToString:tag]) {
                    idx=i;
                    break;
                }
            }
        }
        
        return (idx!=-1)?1:0;
    };
    //cache相关
    _jsContext[@"HJM_writeCache"] = ^(NSString *key,NSString *value) {
        NSMutableDictionary *dic=[NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"UIWebViewCache"]];
        [dic setValue:value forKey:key];
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"UIWebViewCache"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    };
    _jsContext[@"HJM_readCache"] = ^(NSString *key) {
        NSMutableDictionary *dic=[NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"UIWebViewCache"]];
        NSString *value=[dic objectForKey:key];
        if (!value) {
            value=@"";
        }
        return value;
    };
    _jsContext[@"HJM_removeCache"] = ^(NSString *keyList) {
        __block NSMutableDictionary *dic=[NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"UIWebViewCache"]];
        
        NSArray *keys=[keyList componentsSeparatedByString:@","];
        [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *key = obj;
            [dic removeObjectForKey:key];
        }];
        
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"UIWebViewCache"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    };
    _jsContext[@"HJM_removeAllCache"] = ^() {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UIWebViewCache"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    };
}

//旋转手势触发方法
-(void)rotationGesture:(id)sender
{
    UIRotationGestureRecognizer *gesture = sender;
    if(gesture.state==UIGestureRecognizerStateChanged)
    {
        if (gesture.rotation>3.14 || gesture.rotation<-3.14) {
            WBWebDebugConsoleViewController * controller = [[WBWebDebugConsoleViewController alloc] initWithConsole:_webView.console];
            
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
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

- (void)rightBtn:(UIButton *)sender{
    ShareSheet *shareSheet = [ShareSheet initImageNames:@[@"weixin",@"pengyouquan"]
                                                 titles:@[@"微信好友",@"微信朋友圈"]
                                             completion:^(NSInteger buttonIndex, id welkSelf){
                                                 if (![WXApi isWXAppSupportApi]) {
                                                     [[TKAlertCenter defaultCenter] postAlertWithMessage:@"当前微信的版本不支持OpenApi"];
                                                 }
                                                 else{
                                                     WXMediaMessage *message = [WXMediaMessage message];
                                                     message.title = _title;
                                                     message.description = _content;
                                                     [message setThumbImage:_thumbImage];
                                                     WXWebpageObject *ext = [WXWebpageObject object];
                                                     ext.webpageUrl = _url;
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

- (void)updateShareContent:(NSDictionary *)param
{
    NSInteger isShare = [[param objectForKey:@"isShare"] integerValue];
    if (isShare) {
        // Create a custom right button
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.frame = CGRectMake(0, 0, 44, 44);
        [rightBtn setImage:[UIImage imageNamed:@"Btn_Action"] forState:UIControlStateNormal];
        [rightBtn setImage:[UIImage imageNamed:@"Btn_Action_hl"] forState:UIControlStateHighlighted];
        [rightBtn addTarget:self action:@selector(rightBtn:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
        
        UIBarButtonItem *rightSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        rightSeperator.width = -20;//此处修改到边界的距离，请自行测试
        [self.navigationItem setRightBarButtonItems:@[rightSeperator, rightBarItem]];
    }
    
    _title = [param objectForKey:@"title"];
    _content = [param objectForKey:@"content"];
    _url = [param objectForKey:@"pageUrl"];
    NSURL *url=[NSURL URLWithString:[param objectForKey:@"imageUrl"]];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager downloadImageWithURL:url
                          options:SDWebImageRetryFailed
                         progress:nil
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                            if (image) {
                                // do something with image
                                _thumbImage=image;
                            }
                        }];
}

#pragma mark UIWebViewDelegate


//通过js来调用objc http://blog.csdn.net/xdonx/article/details/6973521
//ehomeapp:apply:succeed
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSURL *url = [request URL];
    if ([FFRouteManager supportSchemeURL:url]) {//APPInScheme:内部跳转Scheme
        if([FFRouteManager canRouteURL:url]){
            [FFRouteManager routeURL:url];
        }
        else{
            [FFRouteManager routeReduceURL:url];
        }
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    /*1注入到js中,再打开第二个网页将失效,建议使用2
    UserInfo *user = [UserInfo loadCurRecord];
    if (user && user.user_id) {
        NSString *authString = [NSString stringWithFormat:@"%@:%@", user.username, user.password];
        user.basicAuth = [NSString base64encode:authString];
    } else {
        user.basicAuth = @"";
    }
    NSString *myUserStr=[[[[user dic] JSONRepresentation] stringByReplacingOccurrencesOfString:@"'" withString:@"&#39;"]stringByReplacingOccurrencesOfString:@"\\\"" withString:@"&quot;"];//注入js屏蔽'"
    
    NSMutableString *_getUserCode=[[NSMutableString alloc]init];
    [_getUserCode appendFormat:@"var script = document.createElement('script');"];
    [_getUserCode appendFormat:@"script.type = 'text/javascript';"];
    [_getUserCode appendFormat:@"script.text = 'var HJM={};HJM.userInfo = function(){ return %@ }';",myUserStr];
    //[_getUserCode appendFormat:@"script.text = 'HJM_USER=%@';",myUserStr];
    [_getUserCode appendString:@"document.getElementsByTagName('head')[0].appendChild(script);"];
    [self.webView stringByEvaluatingJavaScriptFromString:_getUserCode];
    */
    
    //2.JavaScriptCore，IOS7以后才开放的API,注意weakSelf(内存释放)
    [self setJSContext];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
//    NSString *JsToGetHTMLSource = @"document.getElementsByTagName('html')[0].innerHTML";
//    NSString *HTMLSource = [webView stringByEvaluatingJavaScriptFromString:JsToGetHTMLSource];
//    NSLog(@"%@",HTMLSource);
    
    id userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    CLog(@"userAgent:%@", userAgent);
    
    //2第二种方式  主动调用JS方法
//    NSString *functionJS = [NSString stringWithFormat:@"test(%@);",myUserStr];
//    [self.webView stringByEvaluatingJavaScriptFromString:functionJS];
    
    [self setJSContext];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - NJKWebViewProgressDelegate
-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress{
    [_progressView setProgress:progress animated:YES];
}

@end
