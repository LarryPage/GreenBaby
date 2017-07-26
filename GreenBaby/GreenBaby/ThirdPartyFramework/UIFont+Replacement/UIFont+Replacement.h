//
//  UIFont+Replacement.h
//  FontReplacer
//
//  Created by Cédric Luthi on 2011-08-08.
//  Copyright (c) 2011 Cédric Luthi. All rights reserved.
//
//统一替换第三方字体
//[UIFont setReplacementDictionary:[UIFont replacementDictionary]];
//替换系统的font,在ios7下 UIActionSheet会报错

#import <UIKit/UIKit.h>

@interface UIFont (Replacement)

+ (NSDictionary *) replacementDictionary;
+ (void) setReplacementDictionary:(NSDictionary *)aReplacementDictionary;

@end
