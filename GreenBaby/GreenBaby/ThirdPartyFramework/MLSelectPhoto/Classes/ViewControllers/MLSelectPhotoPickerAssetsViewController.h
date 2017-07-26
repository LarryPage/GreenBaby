//  ZLPhotoPickerAssetsViewController.h
//  ZLAssetsPickerDemo
//
//  Created by LiXiangCheng on 14-11-12.
//  Copyright (c) 2014年 com.Ideal.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLSelectPhotoCommon.h"
#import "MLSelectPhotoPickerGroupViewController.h"

@class MLSelectPhotoPickerGroup;

@interface MLSelectPhotoPickerAssetsViewController : UIViewController

@property (weak ,nonatomic) MLSelectPhotoPickerGroupViewController *groupVc;
@property (nonatomic , assign) PickerViewShowStatus status;
@property (nonatomic , strong) MLSelectPhotoPickerGroup *assetsGroup;
@property (nonatomic , assign) NSInteger maxCount;
// 选择完成后的文案:发送|完成
@property (nonatomic , strong) NSString *doneText;
// 需要记录选中的值的数据
@property (strong,nonatomic) NSArray *selectPickerAssets;
// 置顶展示图片
@property (assign,nonatomic) BOOL topShowPhotoPicker;

@end
