//
//  FFRouteImp.h
//  GreenBaby
//
//  Created by LiXiangCheng on 2017/8/11.
//  Copyright © 2017年 LiXiangCheng. All rights reserved.
//

#import <Foundation/Foundation.h>

/*Scheme定义:https://bitbucket.org/rrlt/huijiame_wiki/wiki/doc/Scheme定义
 http://phab.51meilin.com/w/开发文档/app/hybrid交互接口定义/
 http://phab.51meilin.com/w/开发文档/app/schema定义/
 调试：http://192.168.1.14:12345/svn/dev/common/2.1/dev数据/MyTest.html
 */
//建议使用：greenbaby://huijiame.com//common/web?url=url&title=网页名&navbarhidden=1&navbarbgcolor=9870FE

#define COMMON_WEB                  @"*/common/web"

@interface FFRouteImp : NSObject<FFRouteImpProtocol>

@end
