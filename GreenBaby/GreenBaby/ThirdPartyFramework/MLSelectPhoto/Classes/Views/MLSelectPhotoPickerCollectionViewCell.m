//  PickerCollectionViewCell.m
//
//  Created by LiXiangCheng on 14-11-11.
//  Copyright (c) 2014年 com.Ideal.www. All rights reserved.
//

#import "MLSelectPhotoPickerCollectionViewCell.h"

static NSString *const _cellIdentifier = @"cell";

@implementation MLSelectPhotoPickerCollectionViewCell

+ (instancetype)cellWithCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    MLSelectPhotoPickerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_cellIdentifier forIndexPath:indexPath];
    
    if ([[cell.contentView.subviews lastObject] isKindOfClass:[UIImageView class]]) {
        [[cell.contentView.subviews lastObject] removeFromSuperview];
    }
    
    return cell;
}
@end
