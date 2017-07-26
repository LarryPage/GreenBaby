//
//  ChatTableView.m
//  CardBump
//
//  Created by 香成 李 on 12-5-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ChatTableView.h"

@interface ChatTableView ()
@property (nonatomic, copy) void (^actionHandler)(void);
@end

@implementation ChatTableView

- (void)addActionHandler:(void (^)(void))actionHandler{
    self.actionHandler=actionHandler;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    if(_actionHandler)
        _actionHandler();
}

@end
