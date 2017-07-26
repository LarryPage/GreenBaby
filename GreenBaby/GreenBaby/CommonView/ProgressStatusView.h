//
//  ProgressStatusView.h
//  SuperResume
//
//  Created by Li XiangCheng on 13-10-29.
//  Copyright (c) 2013年 Li XiangCheng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, ProgressStatus) {
    ProgressStatusSuccess = 0,
    ProgressStatusFail,
    ProgressStatusLoading
};

@interface ProgressStatusView : UIView

@property (nonatomic) ProgressStatus status;

- (void)reset;

@end
