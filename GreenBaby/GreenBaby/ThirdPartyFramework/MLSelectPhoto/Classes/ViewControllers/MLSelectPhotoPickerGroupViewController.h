//  ZLPhotoPickerGroupViewController.h
//  ZLAssetsPickerDemo
//
//  Created by LiXiangCheng on 14-11-11.
//  Copyright (c) 2014年 com.Ideal.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLSelectPhotoPickerViewController.h"

@interface MLSelectPhotoPickerGroupViewController : UIViewController

@property (nonatomic, weak) id<ZLPhotoPickerViewControllerDelegate> delegate;
@property (nonatomic, assign) PickerViewShowStatus status;
@property (nonatomic, assign) NSInteger maxCount;
// 选择完成后的文案:发送|完成
@property (nonatomic , strong) NSString *doneText;
// 记录选中的值
@property (strong,nonatomic) NSArray *selectAsstes;
@property (assign,nonatomic) BOOL topShowPhotoPicker;

@end
