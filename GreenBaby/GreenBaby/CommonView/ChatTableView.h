//
//  ChatTableView.h
//  CardBump
//
//  Created by 香成 李 on 12-5-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatTableView : UITableView

- (void)addActionHandler:(void (^)(void))actionHandler;

@end