//  PickerCollectionViewCell.h
//
//  Created by LiXiangCheng on 14-11-11.
//  Copyright (c) 2014年 com.Ideal.www. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UICollectionView;

@interface MLSelectPhotoPickerCollectionViewCell : UICollectionViewCell
+ (instancetype) cellWithCollectionView : (UICollectionView *) collectionView cellForItemAtIndexPath:(NSIndexPath *) indexPath;

@property (nonatomic , strong) UIImage *cellImage;

@end
