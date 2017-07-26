//
//  ShareSheet.h
//  EHome
//
//  Created by 香成 李 on 12-1-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ShareCompletion)(NSInteger index, id object);

@interface ShareSheet : UIView

@property (nonatomic, strong) IBOutlet UILabel *tipLbl;

+ (ShareSheet *)initImageNames:(NSArray *)imageNames
                          titles:(NSArray *)titles
                      completion:(ShareCompletion)completion;  //Index 0  表示关闭 Cancel
- (void)show;
@end
