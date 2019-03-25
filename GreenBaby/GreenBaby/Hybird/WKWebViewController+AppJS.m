//
//  WKWebViewController+AppJS.m
//  BrcIot
//
//  Created by LiXiangCheng on 2019/3/24.
//  Copyright © 2019年 BRC. All rights reserved.
//

#import "WKWebViewController+AppJS.h"

static NSMutableDictionary *gSessionOfWKWebView = nil;//缓存HTML5相关Session变量

@implementation WKWebViewController (AppJS)

#pragma mark private

- (void)interactWitMethodName:(NSString *)methodName
                    paramsDic:(NSDictionary *)paramsDic
                    completed:(void(^)(id response))callBack{
    
    if (paramsDic) {
        methodName = [NSString stringWithFormat:@"%@:",methodName];
        if (callBack) {
            methodName = [NSString stringWithFormat:@"%@:",methodName];
            SEL selector =NSSelectorFromString(methodName);
            NSArray *paramArray =@[paramsDic,callBack];
            if ([self respondsToSelector:selector]) {
                [self lxcPerformSelector:selector withObjects:paramArray];
            }
        }else{
            SEL selector =NSSelectorFromString(methodName);
            NSArray *paramArray =@[paramsDic];
            if ([self respondsToSelector:selector]) {
                [self lxcPerformSelector:selector withObjects:paramArray];
            }
        }
    }else{
        if (callBack) {
            methodName = [NSString stringWithFormat:@"%@:",methodName];
            SEL selector =NSSelectorFromString(methodName);
            NSArray *paramArray =@[callBack];
            if ([self respondsToSelector:selector]) {
                [self lxcPerformSelector:selector withObjects:paramArray];
            }
        }else{
            SEL selector =NSSelectorFromString(methodName);
            if ([self respondsToSelector:selector]) {
                [self lxcPerformSelector:selector withObjects:nil];
            }
        }
    }
}

- (id)lxcPerformSelector:(SEL)aSelector withObjects:(NSArray *)objects {
    NSMethodSignature *signature = [self methodSignatureForSelector:aSelector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:self];
    [invocation setSelector:aSelector];
    
    NSUInteger i = 1;
    for (id object in objects) {
        id tempObject = object;
        [invocation setArgument:&tempObject atIndex:++i];
    }
    [invocation invoke];
    
    if ([signature methodReturnLength]) {
        id data;
        [invocation getReturnValue:&data];
        return data;
    }
    return nil;
}

#pragma mark AppJsFunction

#pragma mark 1.页面跳转的控制
- (void)pushWebView:(NSDictionary *)paramsDic{
    NSString *url = [NSString safeStringFromObject:[paramsDic objectForKey:@"url"]];
    NSString *title = [NSString safeStringFromObject:[paramsDic objectForKey:@"title"]];
    NSInteger isCreate = [[paramsDic objectForKey:@"isCreate"] integerValue];
    
    WEAKSELF
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
}

- (void)popWebView:(NSDictionary *)paramsDic{
    NSInteger pageNum = [[paramsDic objectForKey:@"pageNum"] integerValue];
    
    WEAKSELF
    dispatch_async(dispatch_get_main_queue(), ^{
        if (pageNum>1 && pageNum<weakSelf.navigationController.viewControllers.count) {
            UIViewController *lastVc = weakSelf.navigationController.viewControllers.lastObject;
            
            NSMutableArray *navigationArray = [NSMutableArray array];
            for (NSInteger i = 0; i < pageNum-1; i++) {
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
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    });
}

- (void)backWebView:(NSDictionary *)paramsDic{
    NSString *tag = [NSString safeStringFromObject:[paramsDic objectForKey:@"tag"]];
    NSString *newUrl = [NSString safeStringFromObject:[paramsDic objectForKey:@"newUrl"]];
    NSString *newTitle = [NSString safeStringFromObject:[paramsDic objectForKey:@"newTitle"]];
    
    WEAKSELF
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([tag isEqualToString:@""]) {
            UIViewController *vc=weakSelf.navigationController.viewControllers[weakSelf.navigationController.viewControllers.count-2];
            if ([vc isKindOfClass:[WKWebViewController class]]) {
                WKWebViewController *findVC=(WKWebViewController *)vc;
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
                if ([vc isKindOfClass:[WKWebViewController class]]) {
                    WKWebViewController *findVC=(WKWebViewController *)vc;
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
                WKWebViewController *lastVc = weakSelf.navigationController.viewControllers.lastObject;
                
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
}

#pragma mark 2.功能性接口
- (void)setWebViewTag:(NSDictionary *)paramsDic{
    NSString *tag = [NSString safeStringFromObject:[paramsDic objectForKey:@"tag"]];
    WEAKSELF
    weakSelf.urlTag=tag;
}

- (void)checkWebView:(NSDictionary *)paramsDic :(void(^)(id response))callBack{
    NSString *tag = [NSString safeStringFromObject:[paramsDic objectForKey:@"tag"]];
    WEAKSELF
    
    NSInteger idx=-1;
    for (NSInteger i=weakSelf.navigationController.viewControllers.count-1; i>=0; i--) {
        UIViewController *vc=weakSelf.navigationController.viewControllers[i];
        if ([vc isKindOfClass:[WKWebViewController class]]) {
            WKWebViewController *findVC=(WKWebViewController *)vc;
            if ([findVC.urlTag isEqualToString:tag]) {
                idx=i;
                break;
            }
        }
    }
    
    NSMutableDictionary *resultDic=[NSMutableDictionary dictionary];
    [resultDic setObject:(idx!=-1)?@"1":@"0" forKey:@"isExist"];
    NSString *arg=[NSString safeStringFromObject:resultDic];
    callBack(arg);
}

- (void)setBounces:(NSDictionary *)paramsDic{
    BOOL bounces = [[paramsDic objectForKey:@"bounces"] boolValue];
    WEAKSELF
    weakSelf.webView.scrollView.bounces = bounces;
}

- (void)getUserInfo:(void(^)(id response))callBack{
    UserModel *user = [UserModel loadCurRecord];
    if (user && user.user_id) {
        NSString *authString = [NSString stringWithFormat:@"%@:%@", user.username, user.password];
        user.basicAuth = [NSString base64encode:authString];
    } else {
        user.basicAuth = @"";
    }
    NSString *arg=[NSString safeStringFromObject:[user dic]];
    callBack(arg);
}

- (void)showLogin{
    //发送一个退出登通知录，便于其他业务处理退出时候需要执行的操作
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IMS_OPENACCOUNT_USER_LOGOUT_OUT" object:self];
}

- (void)execApiRequest:(NSDictionary *)paramsDic :(void(^)(id response))callBack{
    NSString *path = [NSString safeStringFromObject:[paramsDic objectForKey:@"path"]];
    NSDictionary *paramDic = [NSDictionary safeDictionaryFromObject:[paramsDic objectForKey:@"params"]];
    NSString *method = [NSString safeStringFromObject:[paramsDic objectForKey:@"method"]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSString *arg=[NSString safeStringFromObject:response];
                    callBack(arg);
                });
            }
            else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSMutableDictionary *errorDic=[NSMutableDictionary dictionary];
                    [errorDic setObject:@(error.code) forKey:@"code"];
                    [errorDic setObject:error.domain forKey:@"domain"];
                    [errorDic setObject:error.localizedDescription forKey:@"userInfo"];
                    NSString *arg=[NSString safeStringFromObject:errorDic];
                    callBack(arg);
                });
            }
        }];
    });
}

#pragma mark 3.cache相关
- (void)writeCache:(NSDictionary *)paramsDic{
    NSString *key = [NSString safeStringFromObject:[paramsDic objectForKey:@"key"]];
    NSString *value = [NSString safeStringFromObject:[paramsDic objectForKey:@"value"]];
    
    NSMutableDictionary *dic=[NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"WKWebViewCache"]];
    [dic setValue:value forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"WKWebViewCache"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)readCache:(NSDictionary *)paramsDic :(void(^)(id response))callBack{
    NSString *key = [NSString safeStringFromObject:[paramsDic objectForKey:@"key"]];
    
    NSMutableDictionary *dic=[NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"WKWebViewCache"]];
    NSString *value=[dic objectForKey:key];
    if (!value) {
        value=@"";
    }
    
    NSMutableDictionary *resultDic=[NSMutableDictionary dictionary];
    [resultDic setObject:value forKey:@"value"];
    NSString *arg=[NSString safeStringFromObject:resultDic];
    callBack(arg);
}

- (void)removeCache:(NSDictionary *)paramsDic{
    NSString *keyList = [NSString safeStringFromObject:[paramsDic objectForKey:@"keyList"]];
    
    __block NSMutableDictionary *dic=[NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:@"WKWebViewCache"]];
    
    NSArray *keys=[keyList componentsSeparatedByString:@","];
    [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *key = obj;
        [dic removeObjectForKey:key];
    }];
    
    [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"WKWebViewCache"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeAllCache{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"WKWebViewCache"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark 4.Session相关
- (void)writeSession:(NSDictionary *)paramsDic{
    NSString *key = [NSString safeStringFromObject:[paramsDic objectForKey:@"key"]];
    NSString *value = [NSString safeStringFromObject:[paramsDic objectForKey:@"value"]];
    
    //memory缓存
    if (!gSessionOfWKWebView) {
        gSessionOfWKWebView = [[NSMutableDictionary alloc] init];
    }
    
    [gSessionOfWKWebView setValue:value forKey:key];
}

- (void)readSession:(NSDictionary *)paramsDic :(void(^)(id response))callBack{
    NSString *key = [NSString safeStringFromObject:[paramsDic objectForKey:@"key"]];
    
    //memory缓存
    if (!gSessionOfWKWebView) {
        gSessionOfWKWebView = [[NSMutableDictionary alloc] init];
    }
    
    NSString *value=[gSessionOfWKWebView objectForKey:key];
    if (!value) {
        value=@"";
    }
    
    NSMutableDictionary *resultDic=[NSMutableDictionary dictionary];
    [resultDic setObject:value forKey:@"value"];
    NSString *arg=[NSString safeStringFromObject:resultDic];
    callBack(arg);
}

- (void)removeSession:(NSDictionary *)paramsDic{
    NSString *keyList = [NSString safeStringFromObject:[paramsDic objectForKey:@"keyList"]];
    
    //memory缓存
    if (!gSessionOfWKWebView) {
        gSessionOfWKWebView = [[NSMutableDictionary alloc] init];
    }
    
    NSArray *keys=[keyList componentsSeparatedByString:@","];
    [keys enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *key = obj;
        [gSessionOfWKWebView removeObjectForKey:key];
    }];
}

- (void)removeAllSession{
    //memory缓存
    gSessionOfWKWebView = [[NSMutableDictionary alloc] init];
}

#pragma mark 5.上导航 Title Bar
- (void)showTitleBar:(NSDictionary *)paramsDic{
    NSInteger isShow = [[paramsDic objectForKey:@"isShow"] integerValue];
    WEAKSELF
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.navBarHidden=isShow==0?YES:NO;
        if (weakSelf.navBarHidden) {
            UIEdgeInsets insets = weakSelf.webView.scrollView.contentInset;
            insets.top = IS_IPHONE_X?-44:-20;
            insets.bottom = -1;
            weakSelf.webView.scrollView.contentInset = insets;
            weakSelf.webView.scrollView.scrollIndicatorInsets = insets;
        }
        else{
            UIEdgeInsets insets = weakSelf.webView.scrollView.contentInset;
            insets.top = 0;
            insets.bottom = -1;
            weakSelf.webView.scrollView.contentInset = insets;
            weakSelf.webView.scrollView.scrollIndicatorInsets = insets;
        }
        [weakSelf.navigationController setNavigationBarHidden:weakSelf.navBarHidden animated:YES];
    });
}

- (void)setTitleBar:(NSDictionary *)paramsDic{
    NSString *navbarbgcolor = [NSString safeStringFromObject:[paramsDic objectForKey:@"navbarbgcolor"]];
    NSString *title = [NSString safeStringFromObject:[paramsDic objectForKey:@"title"]];
    NSString *titleColor = [NSString safeStringFromObject:[paramsDic objectForKey:@"titleColor"]];
    
    WEAKSELF
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.navBarBgColor=navbarbgcolor;
        if (weakSelf.navBarBgColor && weakSelf.navBarBgColor.length>=6) {
            UIColor *navBarTintColor=[UIColor colorWithHexString:weakSelf.navBarBgColor];
            weakSelf.navigationController.navigationBar.barTintColor=navBarTintColor;//the bar background
            [weakSelf.navigationController.navigationBar setBackgroundImage:[UIImage createImageWithColor:navBarTintColor] forBarMetrics:UIBarMetricsDefault];
        }
        
        UILabel *titleLabel = (UILabel *)weakSelf.navigationItem.titleView;
        titleLabel.text = title;
        [titleLabel sizeToFit];
        
        if (titleColor && titleColor.length>=6){
            UIColor *navBarTitleColor=[UIColor colorWithHexString:titleColor];
            titleLabel.textColor=navBarTitleColor;
        }
    });
}

- (void)setLeftButton{
    self.backBtn.hidden = YES;
    self.leftBtnCallBack = nil;
}

- (void)setLeftButton:(NSDictionary *)paramsDic{
    NSString *icon = [NSString safeStringFromObject:[paramsDic objectForKey:@"icon"]];
    NSString *title = [NSString safeStringFromObject:[paramsDic objectForKey:@"title"]];
    NSString *titleColor = [NSString safeStringFromObject:[paramsDic objectForKey:@"titleColor"]];
    NSString *callback = [NSString safeStringFromObject:[paramsDic objectForKey:@"callback"]];
    
    WEAKSELF
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.rightBtn.hidden = NO;
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
        weakSelf.leftBtnCallBack = callback;
    });
}

- (void)setRightButton{
    self.rightBtn.hidden = YES;
    self.rightBtnCallBack = nil;
}

- (void)setRightButton:(NSDictionary *)paramsDic{
    NSString *icon = [NSString safeStringFromObject:[paramsDic objectForKey:@"icon"]];
    NSString *title = [NSString safeStringFromObject:[paramsDic objectForKey:@"title"]];
    NSString *titleColor = [NSString safeStringFromObject:[paramsDic objectForKey:@"titleColor"]];
    NSString *callback = [NSString safeStringFromObject:[paramsDic objectForKey:@"callback"]];
    
    WEAKSELF
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.rightBtn.hidden = NO;
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
        weakSelf.rightBtnCallBack = callback;
    });
}

- (void)setRightButtonShare:(NSDictionary *)paramsDic{
    [self updateShareContent:paramsDic];
    self.rightBtn.hidden = NO;
    self.rightBtnCallBack = nil;
}

@end
