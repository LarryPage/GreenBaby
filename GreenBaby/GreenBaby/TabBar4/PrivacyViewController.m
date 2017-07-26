//
//  PrivacyViewController.m
//  Whok
//
//  Created by LiXiangCheng on 14-9-2.
//  Copyright (c) 2014年 LiXiangCheng. All rights reserved.
//

#import "PrivacyViewController.h"

@interface PrivacyViewController ()
@property(nonatomic, weak) IBOutlet UIWebView *webView;
@end

@implementation PrivacyViewController

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title=@"用户协议";
    
    //	NSMutableString* urlStr = [[NSMutableString alloc] initWithFormat:HELPHTMLTEXT];
    //	[self.webView loadHTMLString:urlStr baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
    //	[urlStr release];
    
    //加载帮助
    //方法1
    /*
     NSURL *aURL = [NSURL URLWithString:@"http://www.shufa.net/Help.htm"];
     NSURLRequest *aRequest = [NSURLRequest requestWithURL:aURL];
     [_webView loadRequest:aRequest];
	 */
    //方法2
    NSString *inHtml = [[NSString alloc] initWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"xieyi.html"]  encoding:NSUTF8StringEncoding error:nil];
    inHtml = [inHtml stringByReplacingOccurrencesOfString:@"src=\"images/" withString:@"src=\""];
    NSBundle* bundle = [NSBundle mainBundle];
    [_webView loadHTMLString:inHtml baseURL:[NSURL fileURLWithPath:[bundle bundlePath]]];
    //webView.delegate = self;
    //方法3:针对html5
    /*
     NSString* startFilePath = [self pathForResource:@"help.html"];
     NSURL* appURL = [NSURL fileURLWithPath:startFilePath];
     NSURLRequest* appReq = [NSURLRequest requestWithURL:appURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
     [webView loadRequest:appReq];
     */
    
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
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end