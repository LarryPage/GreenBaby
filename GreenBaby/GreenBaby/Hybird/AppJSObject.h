//
//  AppJSObject.h
//  BrcIot
//
//  Created by LiXiangCheng on 2018/11/30.
//  Copyright © 2018年 BRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol AppJSObjectDelegate <JSExport>
@end

@interface AppJSObject : NSObject<AppJSObjectDelegate>

@property(nonatomic,weak) id<AppJSObjectDelegate> delegate;

@end
