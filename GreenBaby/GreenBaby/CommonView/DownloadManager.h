//
//  DownloadManager.h
//  IAsk
//
//  Created by 香成 李 on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//  例用图片：cancel.png
//

#import <Foundation/Foundation.h>
#import "CustomIOS7AlertView.h"

@class DownloadManager;
@protocol DownloadManagerDelegate <NSObject>
- (void)downloadManager:(DownloadManager *)downloadManager didFinishWithFilePath:(NSString *)filePath;
@end

@interface DownloadManager : NSObject {
}

@property (nonatomic, weak) id<DownloadManagerDelegate> delegate;
@property (nonatomic, strong) NSString	*title;
@property (nonatomic, strong) NSURL		*fileURL;
@property (nonatomic, strong) NSString	*filePath;//本地文件路径

@property (nonatomic) NSUInteger currentSize;
@property (nonatomic) long long totalFileSize;
@property (nonatomic, strong) UIProgressView *progressView;
#if (defined(__IPHONE_7_0))
@property (nonatomic, strong) CustomIOS7AlertView *progressAlertView;
#else
@property (nonatomic, strong) UIAlertView *progressAlertView;
#endif

+ (id)sharedManager;
- (void)downloadProcessStart;
- (void)writeToFile:(NSData *)data;

@end
