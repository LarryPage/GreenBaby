//  ZLAssets.h
//  ZLAssetsPickerDemo
//
//  Created by LiXiangCheng on 15-1-3.
//  Copyright (c) 2015年 com.Ideal.www. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface MLSelectPhotoAssets : NSObject

@property (strong,nonatomic) ALAsset *asset;
/**
 *  缩略图
 */
- (UIImage *)thumbImage;
/**
 *  原图
 */
- (UIImage *)originImage;
/**
 *  获取是否是视频类型, Default = false
 */
@property (assign,nonatomic) BOOL isVideoType;
/**
 *  获取图片的URL
 */
- (NSURL *)assetURL;

@end
