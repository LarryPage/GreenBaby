//
//  FFATManager.h
//  BrcIot
//
//  Created by LiXiangCheng on 2018/10/29.
//  Copyright © 2018年 BRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FFATLayoutAttributes.h"
#import "FFATPosition.h"
#import "FFATPadStackViewController.h"

@interface FFATManager : NSObject<FFATDelegate, FFATPadStackDelegate>

@property (nonatomic, strong) UIWindow *assistiveWindow;
@property (nonatomic, strong) FFATPadStackViewController *navigationController;
@property (nonatomic, strong) FFSDCDataModel *pluginsData;

SINGLETON_DEF(FFATManager)

- (void)showAssistiveTouch;

- (void)dismiss;

@end
