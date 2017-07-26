//  MLSelectPhotoBrowserViewController.h
//  MLSelectPhoto
//
//  Created by LiXiangCheng on 15/4/23.
//  Copyright (c) 2015年 com.Ideal.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLSelectPhotoBrowserViewController : UIViewController
// 展示的图片 MLSelectAssets
@property (strong,nonatomic) NSArray *photos;
@property (strong,nonatomic) NSMutableArray *doneAssets;
@property (strong,nonatomic) NSMutableDictionary *deleteAssets;

// 长按图片弹出的UIActionSheet
@property (strong,nonatomic) UIActionSheet *sheet;
// 当前提供的分页数
@property (nonatomic , assign) NSInteger currentPage;
@property (nonatomic , assign) NSInteger maxCount;
// 选择完成后的文案:发送|完成
@property (nonatomic , strong) NSString *doneText;

- (void)updateUI;//modify by lxc

@end
