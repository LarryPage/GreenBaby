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

@property (nonatomic, assign) BOOL navBarHidden;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *urlTag;
@property (nonatomic, copy) void (^actionHandler)(void);

- (id)initWithUrl:(NSString *)url title:(NSString *)title;

@end
