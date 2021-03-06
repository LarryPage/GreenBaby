//
//  APIParseErrorViewController.m
//  EHome
//
//  Created by LiXiangCheng on 15/5/11.
//  Copyright (c) 2015年 MeiLin. All rights reserved.
//

#import "APIParseErrorViewController.h"

@interface APIParseErrorViewController ()<UIWebViewDelegate>{
    NSString *_html;
    NSString *_title;
}
@property(nonatomic, strong) UIWebView *webView;
@end

@implementation APIParseErrorViewController

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithHtml:(NSString *)html title:(NSString *)title{
    if (self = [super initWithNibName:nil bundle:nil]) {
        _html=html;
        _title=title;
    }
    return self;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    _webView.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title =_title;
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(leftBtn:)];
    self.navigationItem.rightBarButtonItems=nil;
    
    self.webView=[[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.webView];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_webView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_webView)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_webView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_webView)]];
    
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
    
    _webView.delegate = self;
    _webView.scalesPageToFit = YES;
    NSBundle* bundle = [NSBundle mainBundle];
    [_webView loadHTMLString:_html baseURL:[NSURL fileURLWithPath:[bundle bundlePath]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action

- (IBAction)leftBtn:(id)sender{
    if (self.presentingViewController){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

//http://blog.csdn.net/xn4545945/article/details/36487407
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
}

@end
