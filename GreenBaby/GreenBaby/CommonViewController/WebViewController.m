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

static NSMutableDictionary *gSessionOfUIWebView = nil;//缓存HTML5相关Session变量

@interface WebViewController ()<UIWebViewDelegate,NJKWebViewProgressDelegate>{
    NSString *_title;
    NSString *_content;
    UIImage *_thumbImage;
    NJKWebViewProgressView *_progressView;
    NJKWebViewProgress *_progressProxy;
}
@property (nonatomic, strong) WBUIWebView *webView;
@property (nonatomic, strong, readwrite) JSContext *jsContext;
@property (nonatomic, strong) NSString *leftBtnCallBackFunction;
@property (nonatomic, strong) NSString *rightBtnCallBackFunction;
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
    
    if (self.navBarBgColor && self.navBarBgColor.length>=6) {
        UIColor *navBarTintColor=[UIColor colorWithHexString:self.navBarBgColor];
        self.navigationController.navigationBar.barTintColor=navBarTintColor;//the bar background
        [self.navigationController.navigationBar setBackgroundImage:[UIImage createImageWithColor:navBarTintColor] forBarMetrics:UIBarMetricsDefault];
    }
    
    //页面显示回调
    NSString *functionJS = @"viewOnResume();";
    [self.webView stringByEvaluatingJavaScriptFromString:functionJS];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_progressView removeFromSuperview];
    
    [self setNavigationBarAttribute:self.navigationController.navigationBar];
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

- (void)back {
    if (self.leftBtnCallBackFunction.length > 0) {
        //回调
        [self.webView stringByEvaluatingJavaScriptFromString:self.leftBtnCallBackFunction];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)rightBtn:(id)sender{
    if (self.rightBtnCallBackFunction.length > 0) {
        //回调
        [self.webView stringByEvaluatingJavaScriptFromString:self.rightBtnCallBackFunction];
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
}

//2.JavaScriptCore，IOS7以后才开放的API,注意weakSelf(内存释放)
//交互
//http://blog.csdn.net/woaifen3344/article/details/42742893
- (void)setJSContext{  //Js 使用
    _jsContext = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    _jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        context.exception = exceptionValue;
        NSLog(@"异常信息：%@", exceptionValue);
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
        NSString *myUserStr=[NSString safeStringFromObject:[user dic]];
        return myUserStr;
    };
    _jsContext[@"HJM_sharePage"] = ^(NSDictionary *param) {
        NSLog(@"param:%@", param);  //分享
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
    // 登录成功后回调
    _jsContext[@"HJM_loginResult"] = ^(NSString *token) {
        // token 回调给app
        JSValue *function = weakSelf.jsContext[@"testCallback"];//js里的全局方法：testCallback
        [function callWithArguments:@[token]];
    };
    //页面跳转的控制
    _jsContext[@"HJM_pushWebView"] = ^(NSString *url, NSString *title, NSInteger isCreate) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSURL *Url=[NSURL URLWithString:url];
            if (isCreate) {
                [[AppDelegate sharedAppDelegate] handleUrl:Url title:title];
            }
            else{
                NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL: Url];
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
    //功能性接口
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
    _jsContext[@"setBounces"] = ^(BOOL yesNO){
        weakSelf.webView.scrollView.bounces = !yesNO;
    };
    _jsContext[@"execHttpRequest"] = ^(NSString *path, NSString *params, NSString *method, NSString *successFunName, NSString *failureFunName) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *paramDic=[NSDictionary safeDictionaryFromObject:params];
            ApiType apiType=kApiTypePost;
            if ([method isEqualToString:@"get"]) {
                apiType=kApiTypeGet;
            }
            else if ([method isEqualToString:@"post"]) {
                apiType=kApiTypePost;
            }
            else if ([method isEqualToString:@"delete"]) {
                apiType=kApiTypeDelete;
            }
            else if ([method isEqualToString:@"put"]) {
                apiType=kApiTypePut;
            }
            [API executeRequestWithPath:path paramDic:paramDic auth:YES apiType:apiType formdataBlock:nil progressBlock:nil completionBlock:^(NSError *error, id response) {
                if (!error) {
                    NSString *arg=[NSString safeStringFromObject:response];
                    JSValue *function = weakSelf.jsContext[successFunName];
                    [function callWithArguments:@[arg]];
                }
                else{
                    JSValue *function = weakSelf.jsContext[failureFunName];
                    NSMutableDictionary *errorDic=[NSMutableDictionary dictionary];
                    [errorDic setObject:@(error.code) forKey:@"code"];
                    [errorDic setObject:error.domain forKey:@"domain"];
                    [errorDic setObject:error.userInfo forKey:@"userInfo"];
                    NSString *arg=[NSString safeStringFromObject:errorDic];
                    [function callWithArguments:@[arg]];
                }
            }];
        });
    };
    //上导航相关
    _jsContext[@"showTitleBar"] = ^(NSInteger isShow) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.navBarHidden=isShow==0?YES:NO;
            if (weakSelf.navBarHidden) {
                UIEdgeInsets insets = weakSelf.webView.scrollView.contentInset;
                insets.top = IS_IPHONE_X?-44:-20;
                insets.bottom = -1;
                weakSelf.webView.scrollView.contentInset = insets;
                weakSelf.webView.scrollView.scrollIndicatorInsets = insets;
            }
            [weakSelf.navigationController setNavigationBarHidden:weakSelf.navBarHidden animated:YES];
        });
    };
    _jsContext[@"setTitleBar"] = ^(NSString *strJson) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *param=[NSDictionary safeDictionaryFromObject:strJson];
            NSString *navbarbgcolor = [param objectForKey:@"navbarbgcolor"];
            NSString *title = [param objectForKey:@"title"];
            NSString *titleColor = [param objectForKey:@"titleColor"];
            
            weakSelf.navBarBgColor=navbarbgcolor;
            if (weakSelf.navBarBgColor && weakSelf.navBarBgColor.length>=6) {
                UIColor *navBarTintColor=[UIColor colorWithHexString:weakSelf.navBarBgColor];
                weakSelf.navigationController.navigationBar.barTintColor=navBarTintColor;//the bar background
                [weakSelf.navigationController.navigationBar setBackgroundImage:[UIImage createImageWithColor:navBarTintColor] forBarMetrics:UIBarMetricsDefault];
            }
            
            UILabel *titleLabel = (UILabel *)weakSelf.navigationItem.titleView;
            titleLabel.text = title;
            
            if (titleColor && titleColor.length>=6){
                UIColor *navBarTitleColor=[UIColor colorWithHexString:titleColor];
                titleLabel.textColor=navBarTitleColor;
            }
        });
    };
    
    _jsContext[@"setLeftButton"] = ^(NSString *strJson) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (strJson.length == 0) {
                weakSelf.backBtn.hidden = YES;
                weakSelf.leftBtnCallBackFunction = nil;
            } else {
                weakSelf.rightBtn.hidden = NO;
                NSDictionary *param=[NSDictionary safeDictionaryFromObject:strJson];
                NSString *icon = [param objectForKey:@"icon"];
                NSString *title = [param objectForKey:@"title"];
                NSString *titleColor = [param objectForKey:@"titleColor"];
                NSString *callback = [param objectForKey:@"callback"];
                
                if (icon.length > 0) {
                    if (icon.isUrl) {
                        CGFloat sizeWH = 44*KUIScale;
                        NSString *iconUrl = [NSString stringWithFormat:@"%@?imageView/1/w/%@/h/%@/q/100",icon,@(sizeWH),@(sizeWH)];
                        NSURL *url=[NSURL URLWithString:iconUrl];
                        SDWebImageManager *manager = [SDWebImageManager sharedManager];
                        [manager loadImageWithURL:url
                                          options:SDWebImageRetryFailed
                                         progress:nil
                                        completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                            if (image) {
                                                // do something with image
                                                [weakSelf.backBtn setImage:image forState:UIControlStateNormal];
                                                [weakSelf.backBtn setImage:image forState:UIControlStateHighlighted];
                                                [weakSelf.backBtn setTitle:nil forState:UIControlStateNormal];
                                                [weakSelf.backBtn setTitle:nil forState:UIControlStateHighlighted];
                                            }
                                        }];
                    }
                    else{
                        [weakSelf.backBtn setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
                        [weakSelf.backBtn setImage:[UIImage imageNamed:icon] forState:UIControlStateHighlighted];
                        [weakSelf.backBtn setTitle:nil forState:UIControlStateNormal];
                        [weakSelf.backBtn setTitle:nil forState:UIControlStateHighlighted];
                    }
                } else {
                    [weakSelf.backBtn setImage:nil forState:UIControlStateNormal];
                    [weakSelf.backBtn setImage:nil forState:UIControlStateHighlighted];
                    [weakSelf.backBtn setTitle:title forState:UIControlStateNormal];
                    [weakSelf.backBtn setTitle:title forState:UIControlStateHighlighted];
                    
                    if (titleColor.length>=6) {
                        [weakSelf.backBtn setTitleColor:[UIColor colorWithHexString:titleColor] forState:UIControlStateNormal];
                    }
                }
                weakSelf.leftBtnCallBackFunction = callback;
            }
        });
    };
    
    _jsContext[@"setRightButton"] = ^(NSString *strJson) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (strJson.length == 0) {
                weakSelf.rightBtn.hidden = YES;
                weakSelf.rightBtnCallBackFunction = nil;
            } else {
                weakSelf.rightBtn.hidden = NO;
                NSDictionary *param=[NSDictionary safeDictionaryFromObject:strJson];
                NSString *icon = [param objectForKey:@"icon"];
                NSString *title = [param objectForKey:@"title"];
                NSString *titleColor = [param objectForKey:@"titleColor"];
                NSString *callback = [param objectForKey:@"callback"];
                
                if (icon.length > 0) {
                    if (icon.isUrl) {
                        CGFloat sizeWH = 44*KUIScale;
                        NSString *iconUrl = [NSString stringWithFormat:@"%@?imageView/1/w/%@/h/%@/q/100",icon,@(sizeWH),@(sizeWH)];
                        NSURL *url=[NSURL URLWithString:iconUrl];
                        SDWebImageManager *manager = [SDWebImageManager sharedManager];
                        [manager loadImageWithURL:url
                                          options:SDWebImageRetryFailed
                                         progress:nil
                                        completed:^(UIImage *image, NSData *data, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                            if (image) {
                                                // do something with image
                                                [weakSelf.rightBtn setImage:image forState:UIControlStateNormal];
                                                [weakSelf.rightBtn setImage:image forState:UIControlStateHighlighted];
                                                [weakSelf.rightBtn setTitle:nil forState:UIControlStateNormal];
                                                [weakSelf.rightBtn setTitle:nil forState:UIControlStateHighlighted];
                                            }
                                        }];
                    }
                    else{
                        [weakSelf.rightBtn setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
                        [weakSelf.rightBtn setImage:[UIImage imageNamed:icon] forState:UIControlStateHighlighted];
                        [weakSelf.rightBtn setTitle:nil forState:UIControlStateNormal];
                        [weakSelf.rightBtn setTitle:nil forState:UIControlStateHighlighted];
                    }
                } else {
                    [weakSelf.rightBtn setImage:nil forState:UIControlStateNormal];
                    [weakSelf.rightBtn setImage:nil forState:UIControlStateHighlighted];
                    [weakSelf.rightBtn setTitle:title forState:UIControlStateNormal];
                    [weakSelf.rightBtn setTitle:title forState:UIControlStateHighlighted];
                    
                    if (titleColor.length>=6) {
                        [weakSelf.rightBtn setTitleColor:[UIColor colorWithHexString:titleColor] forState:UIControlStateNormal];
                    }
                }
                weakSelf.rightBtnCallBackFunction = callback;
            }
        });
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
    //Session相关
    _jsContext[@"HJM_writeSession"] = ^(NSString *key,NSString *value) {
        //memory缓存
        if (!gSessionOfUIWebView) {
            gSessionOfUIWebView = [[NSMutableDictionary alloc] init];
        }
        
        [gSessionOfUIWebView setValue:value forKey:key];
        
    };
    _jsContext[@"HJM_readSession"] = ^(NSString *key) {
        //memory缓存
        if (!gSessionOfUIWebView) {
            gSessionOfUIWebView = [[NSMutableDictionary alloc] init];
        }
        
        NSString *value=[gSessionOfUIWebView objectForKey:key];
        if (!value) {
            value=@"";
        }
        return value;
    };
    _jsContext[@"HJM_removeSession"] = ^(NSString *keyList) {
        //memory缓存
        if (!gSessionOfUIWebView) {
            gSessionOfUIWebView = [[NSMutableDictionary alloc] init];
        }
        
        NSArray *keys=[keyList componentsSeparatedByString:@","];
        [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *key = obj;
            [gSessionOfUIWebView removeObjectForKey:key];
        }];
    };
    _jsContext[@"HJM_removeAllSession"] = ^() {
        //memory缓存
        gSessionOfUIWebView = [[NSMutableDictionary alloc] init];
    };
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

- (void)updateShareContent:(NSDictionary *)param
{
    NSInteger isShare = [[param objectForKey:@"isShare"] integerValue];
    self.rightBtn.hidden=!isShare;
    
    _title = [param objectForKey:@"title"];
    _content = [param objectForKey:@"content"];
    _url = [param objectForKey:@"pageUrl"];
    NSURL *url=[NSURL URLWithString:[param objectForKey:@"imageUrl"]];
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager loadImageWithURL:url
                      options:SDWebImageRetryFailed
                     progress:nil
                    completed:^(UIImage *image, NSData * data,NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
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
    NSString *myUserStr=[[[NSString safeStringFromObject:[user dic]] stringByReplacingOccurrencesOfString:@"'" withString:@"&#39;"]stringByReplacingOccurrencesOfString:@"\\\"" withString:@"&quot;"];//注入js屏蔽'"
    
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
//    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
//    NSString *JsToGetHTMLSource = @"document.getElementsByTagName('html')[0].innerHTML";
//    NSString *HTMLSource = [webView stringByEvaluatingJavaScriptFromString:JsToGetHTMLSource];
//    NSLog(@"%@",HTMLSource);
    
    id userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSLog(@"userAgent:%@", userAgent);
    
    //2第二种方式  主动调用JS方法
//    NSString *functionJS = [NSString stringWithFormat:@"test(%@);",myUserStr];
//    [self.webView stringByEvaluatingJavaScriptFromString:functionJS];
    
    //html页面载入完成回调
    NSString *functionJS = @"viewDidLoad();";
    [self.webView stringByEvaluatingJavaScriptFromString:functionJS];
    
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
