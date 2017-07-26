//
//  CitySelectViewController.h
//  Hunt
//
//  Created by LiXiangCheng on 14/12/11.
//  Copyright (c) 2014年 LiXiangCheng. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^SelectCompletion)(NSString *selectId);

@interface CitySelectViewController : BaseViewController

@property (nonatomic, assign) NSString *curSelectId;
@property (nonatomic, copy) SelectCompletion selectCompletion;

@end
