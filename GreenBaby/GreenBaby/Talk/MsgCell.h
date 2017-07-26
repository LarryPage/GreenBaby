//
//  MsgCell.h
//  InterestingExchange
//
//  Created by LiXiangCheng on 15/8/14.
//  Copyright (c) 2015年 LiXiangCheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageDetail.h"

@interface MsgCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *avatarIV;
@property (nonatomic, weak) IBOutlet UILabel *nameLbl;
@property (nonatomic, weak) IBOutlet UILabel *timeLbl;
@property (nonatomic, weak) IBOutlet UILabel *contentLbl;
@property (nonatomic, weak) IBOutlet UILabel *unreadLabel;

- (void)showMessage:(MessageDetail *)record;
+ (NSInteger)calcCellHeight:(MessageDetail *)record;

@end
