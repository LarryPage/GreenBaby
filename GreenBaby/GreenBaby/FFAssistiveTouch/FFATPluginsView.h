//
//  FFATPluginsView.h
//  BrcIot
//
//  Created by LiXiangCheng on 2018/10/29.
//  Copyright © 2018年 BRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FFATLayoutAttributes.h"
#import "FFATPosition.h"

typedef NS_ENUM(NSInteger, FFATPluginViewType){
    
    FFATPluginViewTypeNone = 0, //! 无样式
    FFATPluginViewTypeSystem = 1, //! 系统圆点样式
    FFATPluginViewTypeBack = 2, //! 回退样式
    FFATPluginViewTypeStar = 3, //! 五角星样式
    FFATPluginViewTypeCount = 4, //! 数字样式
    FFATPluginViewTypeCustom = 5 //! 自定义是要带图片的
};


typedef NS_ENUM(NSInteger, FFATInnerCircle) {
    FFATInnerCircleSmall,
    FFATInnerCircleMiddle,
    FFATInnerCircleLarge
};


@interface FFATPluginsView : UIView

- (instancetype _Nonnull )initWithLayer:(nullable CALayer *)layer NS_DESIGNATED_INITIALIZER;
+ (instancetype _Nonnull )itemWithType:(FFATPluginViewType)type customImg:(NSString *_Nonnull)imageName;
+ (instancetype _Nonnull )itemWithLayer:(CALayer *_Nonnull)layer;
+ (instancetype _Nonnull )itemWithImage:(UIImage *_Nonnull)image;

@property (nonatomic, strong, nonnull) FFATPosition *position;
@property (nonatomic, strong, nonnull) UILabel *nameLbl;


@end
