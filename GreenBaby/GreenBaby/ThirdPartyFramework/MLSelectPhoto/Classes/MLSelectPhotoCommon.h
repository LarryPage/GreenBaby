//  ZLPhotoPickerCommon.h
//  ZLAssetsPickerDemo
//
//  Created by LiXiangCheng on 14-11-19.
//  Copyright (c) 2014年 com.Ideal.www. All rights reserved.
//

#ifndef MLSelectPhoto_h
#define MLSelectPhoto_h

// 图片最多显示9张，超过9张取消单击事件
static NSInteger const KPhotoShowMaxCount = 9;
// 是否开启拍照自动保存图片
static BOOL const isCameraAutoSavePhoto = YES;
// HUD提示框动画执行的秒数
static CGFloat KHUDShowDuration = 1.0;

#define iOS7gt ([[UIDevice currentDevice].systemVersion doubleValue] >= 7.0)

// NSNotification
static NSString *PICKER_TAKE_DONE = @"PICKER_TAKE_DONE";
static NSString *PICKER_REFRESH_DONE = @"PICKER_REFRESH_DONE";

// 图片路径
#define MLSelectPhotoSrcName(file) [@"MLSelectPhoto.bundle" stringByAppendingPathComponent:file]

#endif
