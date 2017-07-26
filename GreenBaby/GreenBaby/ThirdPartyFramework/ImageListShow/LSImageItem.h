//
//  LSImageItem.h
//  mmy
//
//  Created by Duno iOS on 14-4-22.
//  Copyright (c) 2014年 Duno iOS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSImageItem : NSObject
@property (nonatomic, strong, readonly) NSString *imageTitle;
@property (nonatomic, strong, readonly) NSString *imageURL;
@property (nonatomic, strong, readonly) NSString *imageNamed;
@property (nonatomic, strong, readonly) NSString *imageTag;
- (id)initImageItemTitle:(NSString *)imageTitle
                imageURL:(NSString *)imageURL
              imageNamed:(NSString *)imageNamed
                imageTag:(NSString *)imageTag;
@end
