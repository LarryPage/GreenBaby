//
//  LSImageItem.m
//  mmy
//
//  Created by Duno iOS on 14-4-22.
//  Copyright (c) 2014年 Duno iOS. All rights reserved.
//

#import "LSImageItem.h"

@implementation LSImageItem
- (id)initImageItemTitle:(NSString *)imageTitle
                imageURL:(NSString *)imageURL
              imageNamed:(NSString *)imageNamed
                imageTag:(NSString *)imageTag
{
    self = [super init];
    if (self) {
        _imageTitle = imageTitle;
        _imageURL = imageURL;
        _imageNamed = imageNamed;
        _imageTag = imageTag;
    }
    return self;
}
@end
