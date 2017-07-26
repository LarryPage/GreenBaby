//
//  FriendTalkViewController.h
//  Hunt
//
//  Created by LiXiangCheng on 14/12/26.
//  Copyright (c) 2014年 LiXiangCheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageDetail.h"

@interface FriendTalkViewController : BaseViewController

@property (nonatomic, strong) NSMutableArray *searchList;//搜索结果:[MessageDetail]

- (id)initWithMsg:(MessageDetail *)msg;
@end
