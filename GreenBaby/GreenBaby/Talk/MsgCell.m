//
//  MsgCell.m
//  InterestingExchange
//
//  Created by LiXiangCheng on 15/8/14.
//  Copyright (c) 2015年 LiXiangCheng. All rights reserved.
//

#import "MsgCell.h"

@interface MsgCell (){
}
@end

@implementation MsgCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.avatarIV.layer.cornerRadius = self.avatarIV.frame.size.width/2;
    self.avatarIV.layer.masksToBounds = YES;
    
    _unreadLabel.font=[UIFont systemFontOfSize:11];
    _unreadLabel.backgroundColor = [UIColor redColor];
    _unreadLabel.textColor = [UIColor whiteColor];
    _unreadLabel.textAlignment = NSTextAlignmentCenter;
    _unreadLabel.layer.cornerRadius = 10;
    _unreadLabel.clipsToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    if (![_unreadLabel isHidden]) {
        _unreadLabel.backgroundColor = [UIColor redColor];
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        [self setBackgroundColor:MKRGBA(245,245,245,255)];
        //[self setBackgroundColor:[UIColor blackColor]];
        //positionNameLabel.textColor=[UIColor grayColor];
    }
    else{
        //[self setBackgroundColor:MKRGBA(236,236,235,255)];
        [self setBackgroundColor:[UIColor whiteColor]];
        //positionNameLabel.textColor=[UIColor whiteColor];
    }
    
    if (![_unreadLabel isHidden]) {
        _unreadLabel.backgroundColor = [UIColor redColor];
    }
}

#pragma mark - Actions

- (void)showMessage:(MessageDetail *)record{
    UserInfo *user = [UserInfo loadCurRecord];
    
    NSString *fromname=(user.user_id==record.fromuid)?record.touname:record.fromuname;
    fromname=(fromname && fromname.length>0)?fromname:@" ";
    //[self.avatarIV sd_setImageWithURL:[NSURL URLWithString:record.avatar] placeholderImage:[UIImage imageWithString:[[fromname substringToIndex:1] uppercaseString] ToSize:self.avatarIV.frame.size]];
    [self.avatarIV sd_setImageWithURL:[NSURL URLWithString:record.avatar] placeholderImage:[UIImage imageNamed:@"avatarDefault"]];
    
    self.nameLbl.text=fromname;
    
    NSInteger unreadCount = record.unread;
    if (unreadCount > 0) {
        if (unreadCount < 9) {
            _unreadLabel.font = [UIFont systemFontOfSize:13];
        }else if(unreadCount > 9 && unreadCount < 99){
            _unreadLabel.font = [UIFont systemFontOfSize:12];
        }else{
            _unreadLabel.font = [UIFont systemFontOfSize:10];
        }
        [_unreadLabel setHidden:NO];
        _unreadLabel.text = [NSString stringWithFormat:@"%@",@(unreadCount)];
    }else{
        [_unreadLabel setHidden:YES];
    }
    
    NSDate *time=[NSDate dateWithDateTimeString:record.time];
    //self.timeLbl.text=[time formattedExactRelativeTimestamp];
    self.timeLbl.text=[time formattedTime];
    
    self.contentLbl.text=record.title;
}

+ (NSInteger)calcCellHeight:(MessageDetail *)record{
    return 72;
}

@end
