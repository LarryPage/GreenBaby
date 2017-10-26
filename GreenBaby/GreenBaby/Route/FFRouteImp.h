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
//greenbaby://huijiame.com/common/web?data=josnstring
//宝贝详情: taobao://item.taobao.com/item.htm?id=12688928896
//建议使用：greenbaby://huijiame.com/common/web?url=url&title=网页名&hide_navbar=1

#define COMMON_WEB                  @"common/web"

@interface FFRouteImp : NSObject<FFRouteImpProtocol>

@end
