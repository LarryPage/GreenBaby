//
//  APIQN.h
//  本类用于对七年的API进行一层封装，方便各处调用
//
//  Created by LiXiangCheng on 15/7/30.
//  Copyright (c) 2015年 LiXiangCheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "API.h"

/**
 *  七牛上传图片的回调Block
 *
 *  @param error 返回的错误信息，如果调用成功则为nil，调用失败则通过error.domain获取错误信息
 *  @param filePath 返回上传的文件fullpath
 *  @param resp 返回的数据，resp[@"key"]
 */
typedef void (^QNUpCompletion)(NSError *error, NSString *filePath, NSDictionary *resp);

@interface APIQN : NSObject

/*
 *  七牛上传图片
[APIQN uploadFile:[Configs PathForBundleResource:@"AppIcon29x29@2x.png"]
              key:@"Btn_Back"
            scope:QiniuBucketNameImg
            extra:nil
         progress:nil
         complete:^(NSError *error, NSString *filePath, NSDictionary *resp) {
         }];
 */
+ (void)uploadFile:(NSString *)filePath
               key:(NSString *)key
             scope:(NSString *)scope//QiniuBucketNameImg
             extra:(QiniuPutExtra *)extra//默认传nil
     progressBlock:(APIProgress)progressBlock
   completionBlock:(QNUpCompletion)completionBlock;

@end
