//
//  DownloadManager.m
//  IAsk
//
//  Created by 香成 李 on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DownloadManager.h"
#import "Reachability.h"

@interface DownloadManager ()<UIAlertViewDelegate,CustomIOS7AlertViewDelegate>{
    
}
@property (nonatomic, retain) NSURLConnection *URLConnection;
@end

@implementation DownloadManager

+ (id)sharedManager{
    static DownloadManager *instance = nil;
    if (!instance)
    {
        instance = [[DownloadManager alloc] init];
    }
    return instance;
}

#pragma mark init

-(id) init{
    self = [super init];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark Action

- (UIView *)createProgressContainerView {
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 280, 90)];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(containerView.frame), 30)];
    titleLabel.text = _title;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = [UIFont systemFontOfSize:16.0f];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [containerView addSubview:titleLabel];
    
    // Create the progress bar and add it to the alert
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(30.0f, 40.0f, 220.0f, 3.0f)];
    [_progressView setProgressViewStyle:UIProgressViewStyleBar];
    _progressView.backgroundColor=[UIColor clearColor];
    _progressView.trackTintColor = [UIColor grayColor]; //UIProgressView显示颜色（轨道颜色）
    _progressView.progressTintColor = [UIColor blueColor]; //进度条的颜色
    [containerView addSubview:_progressView];
    _progressView.progress = 0.0;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, 50.0f, 220.0f, 30.0f)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:12.0f];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"";
    label.tag = 100;
    [containerView addSubview:label];
    
    return containerView;
}

- (void)createProgressionAlert
{
    _currentSize=0;
    _totalFileSize=0;
    
    if (!_progressAlertView) {
#if (defined(__IPHONE_7_0))
        _progressAlertView = [[CustomIOS7AlertView alloc] init];
        _progressAlertView.tag=101;
        
        // Add some custom content to the alert view
        [_progressAlertView setContainerView:[self createProgressContainerView]];
        
        // Modify the parameters
        //[alertView setButtonTitles:@[@"确定"]];
        [_progressAlertView setButtonTitles:[NSMutableArray arrayWithObjects:@"取消", nil]];
        
        [_progressAlertView setDelegate:self];
        // You may use a Block, rather than a delegate.
//        [_progressAlertView setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, NSInteger buttonIndex) {
//            CLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, [alertView tag]);
//            [_progressAlertView close];
//        }];
        
        [_progressAlertView setUseMotionEffects:YES];
        
        // And launch the dialog
        [_progressAlertView show];
#else
        _progressAlertView = [[UIAlertView alloc] initWithTitle:_title
                                                        message:NSLocalizedString(@"请等待...",nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"取消",nil)
                                              otherButtonTitles:nil];
        _progressAlertView.tag=101;
        
        // Create the progress bar and add it to the alert
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(30.0f, 95.0f, 225.0f, 90.0f)];
        [_progressView setProgressViewStyle:UIProgressViewStyleBar];
        [_progressAlertView addSubview:_progressView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(90.0f, 100.0f, 225.0f, 40.0f)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:12.0f];
        label.text = @"";
        label.tag = 100;
        [_progressAlertView addSubview:label];
        
        [_progressAlertView show];
#endif
    }
    else{
        _progressView.progress = 0;
        UILabel *label = (UILabel *)[self.progressAlertView viewWithTag:100];
        label.text=@"";
        [_progressAlertView show];
    }
}

- (void)downloadProcessStart
{
	if (_fileURL == nil) {
		[UIAlertView alert:NSLocalizedString(@"url不存在",nil) title:nil bTitle:nil];
		return;
	}
	
    //检测网络状态
    Reachability *r =[Reachability reachabilityWithHostName:[_fileURL host]];
    if ([r currentReachabilityStatus] == NotReachable) {
        [UIAlertView alert:NSLocalizedString(@"Cannot connect to Download Server",nil) title:nil bTitle:nil];
        return ;
    }
	
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:_fileURL];
    [req addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    //[req addValue:@"application/x-apple-aspen-config" forHTTPHeaderField:@"Content-Type"];
	//[req setHTTPMethod:@"POST"];
	
    if (_URLConnection) {
        _URLConnection=nil;
    }
	_URLConnection = [[NSURLConnection alloc] initWithRequest:req delegate:self];
	if (_URLConnection) {
		[self createProgressionAlert];
	} else {
		// inform the user that the download could not be made
	}
    
	kNetActivityOn;
}

-(void)cancelLoadAction{
	kNetActivityOff;
    
	[_URLConnection cancel];
	
#if (defined(__IPHONE_7_0))
	[self.progressAlertView close];
#else
    [self.progressAlertView dismissWithClickedButtonIndex:0 animated:YES];
#endif
    
    NSError *error;
	if([[NSFileManager defaultManager] fileExistsAtPath:_filePath]){
		[[NSFileManager defaultManager] removeItemAtPath:_filePath error:&error];
	}
    
	[UIAlertView alert:NSLocalizedString(@"下载取消",nil) title:nil bTitle:nil];
}

-(void)writeToFile:(NSData *)data{
	if([[NSFileManager defaultManager] fileExistsAtPath:_filePath] == NO){
		[[NSFileManager defaultManager] createFileAtPath:_filePath contents:nil attributes:nil];
	}
	FILE *file = fopen([_filePath UTF8String], [@"ab+" UTF8String]);
	if(file != NULL){
		fseek(file, 0, SEEK_END);
	}
	NSUInteger readSize = [data length];
	fwrite((const void *)[data bytes], readSize, 1, file);
	fclose(file);
}

#pragma mark CustomIOS7AlertViewDelegate

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex{
//    CLog(@"Delegate: Button at position %d is clicked on alertView %d.", buttonIndex, [alertView tag]);
//    [alertView close];
    
    switch ([alertView tag]) {
        case 101:
        {
            if (buttonIndex==0) {//取消
                [self cancelLoadAction];
                return;
            }
            break;
        }
        default:
            break;
    }
    
    [alertView close];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 101:
        {
            if (buttonIndex == alertView.cancelButtonIndex) {
                [self cancelLoadAction];
                return;
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark NSURLConnection callbacks

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
	_currentSize = 0;
    
    _totalFileSize=[response expectedContentLength];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
    _currentSize = _currentSize + [data length];
	[self writeToFile:data];
	NSNumber *resourceLength = [NSNumber numberWithUnsignedInteger:_currentSize];
    NSNumber *totalFileLength = [NSNumber numberWithLongLong:_totalFileSize];
	
    NSNumber *progress = [NSNumber numberWithFloat:([resourceLength floatValue] / [totalFileLength floatValue])];
    self.progressView.progress = [progress floatValue];
	
    const unsigned int bytes = 1024 ;
    UILabel *label = (UILabel *)[self.progressAlertView viewWithTag:100];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setPositiveFormat:@"##0.00"];
    NSNumber *partial = [NSNumber numberWithFloat:([resourceLength floatValue] / bytes)];
    NSNumber *total = [NSNumber numberWithFloat:([totalFileLength floatValue] / bytes)];
    label.text = [NSString stringWithFormat:@"%@ KB / %@ KB", [formatter stringFromNumber:partial], [formatter stringFromNumber:total]];
    CLog(@"process:%@",label.text);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error 
{
    kNetActivityOff;
    
#if (defined(__IPHONE_7_0))
	[self.progressAlertView close];
#else
    [self.progressAlertView dismissWithClickedButtonIndex:0 animated:YES];
#endif
	[UIAlertView alert:NSLocalizedString(@"下载失败",nil) title:nil bTitle:nil];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	kNetActivityOff;
	
    // 结束下载后处理压缩文件
	if(_delegate)
	{
        [_delegate downloadManager:self didFinishWithFilePath:_filePath];
	}
    
//#if (defined(__IPHONE_7_0))
//	[self.progressAlertView close];
//#else
//    [self.progressAlertView dismissWithClickedButtonIndex:0 animated:YES];
//#endif
//    [UIAlertView alert:NSLocalizedString(@"Download successful",nil) title:nil bTitle:nil];
	
}

@end
