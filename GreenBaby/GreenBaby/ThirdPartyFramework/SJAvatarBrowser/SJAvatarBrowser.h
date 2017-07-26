//
//  SJAvatarBrowser.h
//
//  Created by LiXiangCheng on 15/8/26.
//  Copyright (c) 2015年 MeiLin. All rights reserved.//

#import <Foundation/Foundation.h>
//调用方法：[SJAvatarBrowser showImage:(UIImageView*)sender.view];

@interface SJAvatarBrowser : NSObject
/**
 *	@brief	浏览头像
 *
 *	@param 	oldImageView 	头像所在的imageView
 */
+(void)showImage:(UIImageView*)avatarImageView;

@end
