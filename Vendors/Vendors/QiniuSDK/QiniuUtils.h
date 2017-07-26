//
//  QiniuUtils.h
//  QiniuSDK
//
//  Created by Qiniu Developers 2013
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

#define kQiniuErrorKey     @"error"
#define kQiniuErrorDomain  @"QiniuErrorDomain"

NSError *qiniuError(int errorCode, NSString *errorDescription);

NSError *qiniuErrorWithRequest(ASIHTTPRequest *request);