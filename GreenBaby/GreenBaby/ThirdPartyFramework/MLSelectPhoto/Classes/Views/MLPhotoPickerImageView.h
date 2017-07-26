//  PickerImageView.h
//
//  Created by LiXiangCheng on 14-11-11.
//  Copyright (c) 2014年 com.Ideal.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLPhotoPickerImageView : UIImageView

/**
 *  是否有蒙版层
 */
@property (nonatomic , assign , getter=isMaskViewFlag) BOOL maskViewFlag;
/**
 *  是否有右上角打钩的按钮
 */
@property (nonatomic , assign) BOOL animationRightTick;
/**
 *  是否视频类型
 */
@property (assign,nonatomic) BOOL isVideoType;

/**
 预览按纽
 */
@property (nonatomic , weak) UIButton *previewBtn;//modify by lxc

@end
