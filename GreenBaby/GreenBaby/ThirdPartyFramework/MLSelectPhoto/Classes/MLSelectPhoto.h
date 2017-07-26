//  ZLPicker.h
//  ZLAssetsPickerDemo
//
//  Created by LiXiangCheng on 14-12-17.
//  Copyright (c) 2014年 com.Ideal.www. All rights reserved.
//

#ifndef ZLAssetsPickerDemo_ZLPicker_h
#define ZLAssetsPickerDemo_ZLPicker_h

#import "MLSelectPhotoPickerViewController.h"
#import "MLSelectPhotoAssets.h"

/**
 *
 
 // Use
 ZLPhotoPickerViewController *pickerVc = [[ZLPhotoPickerViewController alloc] init];
 // 默认显示相册里面的内容SavePhotos
 pickerVc.status = PickerViewShowStatusCameraRoll;
 // 选择图片的最小数，默认是9张图片
 pickerVc.minCount = 4;
 // 选择完成后的文案:发送|完成
 picker.doneText = @"发送";
 // 设置代理回调
 pickerVc.delegate = self;
 // 展示控制器
 [pickerVc showPickerVc:self];
 
 第一种回调方法：- (void)pickerViewControllerDoneAsstes:(NSArray *)assets
 第二种回调方法pickerVc.callBack = ^(NSArray *assets){
 // TODO 回调结果，可以不用实现代理
 };
 
 */
#endif
