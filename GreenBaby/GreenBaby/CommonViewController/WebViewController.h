//
//  WebViewController.h
//  CardBump
//
//  Created by 香成 李 on 12-01-29.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface WebViewController : BaseViewController

@property (nonatomic, assign) BOOL navBarHidden;//1:打开页面时隐藏上导航条,0:打开页面显示上导航条，默认0
@property (nonatomic, strong) NSString *navBarBgColor;//上导航条颜色,默认:9870FE
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *urlTag;
@property (nonatomic, copy) void (^actionHandler)(void);

- (id)initWithUrl:(NSString *)url title:(NSString *)title;

@end
