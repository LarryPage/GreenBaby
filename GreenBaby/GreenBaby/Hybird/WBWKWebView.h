//
//  WBWKWebView.h
//  WKWebView+WBWebViewConsole
//
//  Created by 吴天 on 15/2/25.
//
//  Copyright (c) 2014-present, Weibo, Corp.
//  All rights reserved.
//
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import <WebKit/WebKit.h>
#import <WBWebViewConsole/WBWebView.h>

@interface WBWKWebView : WKWebView <WBWebView>

@property (nonatomic, weak) id<WKNavigationDelegate> wb_delegate;

- (void)webDebugLogProvisionalNavigation:(NSURLRequest *)request navigationType:(WKNavigationType)navigationType result:(BOOL)result;
- (void)webDebugLogLoadFailedWithError:(NSError *)error;

@end
