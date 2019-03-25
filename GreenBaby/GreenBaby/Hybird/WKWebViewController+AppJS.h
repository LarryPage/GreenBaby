//
//  WKWebViewController+AppJS.h
//  BrcIot
//
//  Created by LiXiangCheng on 2019/3/24.
//  Copyright © 2019年 BRC. All rights reserved.
//

#import "WKWebViewController.h"

@interface WKWebViewController (AppJS)

- (void)interactWitMethodName:(NSString *)methodName
                    paramsDic:(NSDictionary *)paramsDic
                    completed:(void(^)(id response))callBack;

@end
