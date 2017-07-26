//
//  TimeHeaderView.m
//  CardBump
//
//  Created by 香成 李 on 12-5-2８.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TimeHeaderView.h"

@interface TimeHeaderView (){
    UILabel *_timeLabel;
}
@end

@implementation TimeHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
//    imageView.contentMode = UIViewContentModeCenter;
//    imageView.image = [UIImage imageNamed:@"time_header_bg.png"];
//    [self addSubview:imageView];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, TIME_HEADER_HEIGHT)];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.textColor = [UIColor grayColor];
    _timeLabel.font = [UIFont systemFontOfSize:10];
    [self addSubview:_timeLabel];
}

- (void)showTime:(NSTimeInterval)time {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月dd日HH:mm"];
    _timeLabel.text = [formatter stringFromDate:date];
}

- (void)showDate:(NSString *)date{
    NSDate *time=[NSDate dateWithDateTimeString:date];
    //_timeLabel.text = [time formattedExactRelativeTimestamp];
    
    //仿微信显示日期时间
    if ([time isDateToday]) {
        _timeLabel.text = [NSString stringWithFormat:@"今天 %@",[time formattedDateWithFormatString:@"HH:mm"]];
    }
    else if ([time isDateYesterday]){
        _timeLabel.text = [NSString stringWithFormat:@"昨天 %@",[time formattedDateWithFormatString:@"HH:mm"]];
    }
    else{
        _timeLabel.text = [time formattedDateWithFormatString:@"yyyy年MM月dd日 HH:mm"];
    }
}

@end
