//  ZLAssets.m
//  ZLAssetsPickerDemo
//
//  Created by LiXiangCheng on 15-1-3.
//  Copyright (c) 2015年 com.Ideal.www. All rights reserved.
//

#import "MLSelectPhotoAssets.h"

@implementation MLSelectPhotoAssets

- (UIImage *)thumbImage{
    return [UIImage imageWithCGImage:[self.asset aspectRatioThumbnail]];
}

- (UIImage *)originImage{
    return [UIImage imageWithCGImage:[[self.asset defaultRepresentation] fullScreenImage]];
}

- (BOOL)isVideoType{
    NSString *type = [self.asset valueForProperty:ALAssetPropertyType];
    //媒体类型是视频
    return [type isEqualToString:ALAssetTypeVideo];
}

- (NSURL *)assetURL{
    return [[self.asset defaultRepresentation] url];
}

@end
