//  MLSelectPhotoBrowserViewController.m
//  MLSelectPhoto
//
//  Created by LiXiangCheng on 15/4/23.
//  Copyright (c) 2015年 com.Ideal.www. All rights reserved.
//

#import "MLSelectPhotoBrowserViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIView+MLExtension.h"
#import "MLSelectPhotoPickerBrowserPhotoScrollView.h"
#import "MLSelectPhotoCommon.h"
#import "UIImage+MLTint.h"

// 分页控制器的高度
static NSInteger ZLPickerColletionViewPadding = 20;
static NSString *_cellIdentifier = @"collectionViewCell";

@interface MLSelectPhotoBrowserViewController () <UIScrollViewDelegate,ZLPhotoPickerPhotoScrollViewDelegate,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate>

// 控件
@property (strong,nonatomic)    UIButton         *deleleBtn;
@property (weak,nonatomic)      UIButton         *backBtn;
@property (weak,nonatomic)      UICollectionView *collectionView;

// 标记View
@property (strong,nonatomic)    UIToolbar *toolBar;
@property (weak,nonatomic)      UILabel *makeView;
@property (strong,nonatomic)    UIButton *doneBtn;

// 是否是编辑模式
@property (assign,nonatomic) BOOL isEditing;

@property (assign,nonatomic) BOOL isShowShowSheet;
@end

@implementation MLSelectPhotoBrowserViewController

#pragma mark - getter
#pragma mark collectionView
-(NSMutableDictionary *)deleteAssets{
    if (!_deleteAssets) {
        _deleteAssets = [NSMutableDictionary dictionary];
    }
    return _deleteAssets;
}

- (NSMutableArray *)doneAssets{
    if (!_doneAssets) {
        _doneAssets = [NSMutableArray array];
    }
    return _doneAssets;
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = ZLPickerColletionViewPadding;
        flowLayout.itemSize = self.view.ml_size;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.ml_width + ZLPickerColletionViewPadding,self.view.ml_height) collectionViewLayout:flowLayout];
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.pagingEnabled = YES;
        collectionView.dataSource = self;
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.bounces = YES;
        collectionView.delegate = self;
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:_cellIdentifier];
        
        [self.view addSubview:collectionView];
        self.collectionView = collectionView;
        
        _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_collectionView]-x-|" options:0 metrics:@{@"x":@(-20)} views:@{@"_collectionView":_collectionView}]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_collectionView]-0-|" options:0 metrics:nil views:@{@"_collectionView":_collectionView}]];
        
        if (self.isEditing) {
            self.makeView.hidden = !(self.doneAssets.count && self.isEditing);
            // 初始化底部ToorBar
            [self setupToorBar];
        }
    }
    return _collectionView;
}

#pragma mark Get View
#pragma mark makeView 红点标记View
- (UILabel *)makeView{
    if (!_makeView) {
        UILabel *makeView = [[UILabel alloc] init];
        makeView.textColor = [UIColor whiteColor];
        makeView.textAlignment = NSTextAlignmentCenter;
        makeView.font = CFont(13);
        makeView.frame = CGRectMake(-20, 12, 20, 20);
        makeView.hidden = YES;
        makeView.layer.cornerRadius = makeView.frame.size.height / 2.0;
        makeView.clipsToBounds = YES;
        makeView.backgroundColor = UIColorFromRGB(0xff9600);
        [self.view addSubview:makeView];
        self.makeView = makeView;
        
    }
    return _makeView;
}

- (UIButton *)doneBtn{
    if (!_doneBtn) {
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setTitleColor:UIColorFromRGB(0xff9600) forState:UIControlStateNormal];
        rightBtn.enabled = YES;
        rightBtn.titleLabel.font = CFont(17);
        rightBtn.frame = CGRectMake(0, 0, 45, 45);
        [rightBtn setTitle:self.doneText forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
        [rightBtn addSubview:self.makeView];
        self.doneBtn = rightBtn;
    }
    return _doneBtn;
}

#pragma mark deleleBtn
- (UIButton *)deleleBtn{
    if (!_deleleBtn) {
        UIButton *deleleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleleBtn.titleLabel.font = CFont(15);
        [deleleBtn setImage:[UIImage imageNamed:MLSelectPhotoSrcName(@"AssetsPickerChecked")] forState:UIControlStateNormal];
        deleleBtn.frame = CGRectMake(0, 0, 23, 23);
        [deleleBtn addTarget:self action:@selector(deleteAsset) forControlEvents:UIControlEventTouchUpInside];
        self.deleleBtn = deleleBtn;
    }
    return _deleleBtn;
}

#pragma mark - setter
- (void)setDoneText:(NSString *)doneText{
    _doneText = doneText;
    [_doneBtn setTitle:_doneText forState:UIControlStateNormal];
}

- (void)setPhotos:(NSArray *)photos{
    _photos = photos;
    _doneAssets = [NSMutableArray arrayWithArray:photos];
}

//modify by lxc
- (void)updateUI{
    [self reloadData];
    self.makeView.hidden = !(self.doneAssets.count && self.isEditing);
    self.makeView.text = [NSString stringWithFormat:@"%ld",self.doneAssets.count];
}

- (void)setSheet:(UIActionSheet *)sheet{
    _sheet = sheet;
    if (!sheet) {
        self.isShowShowSheet = NO;
    }
}

#pragma mark - Life cycle
- (void)dealloc{
    self.isShowShowSheet = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    //modify by lxc
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 44.0f, 44.0f);
    [backBtn setImage:[UIImage imageNamed:@"Btn_Back"] forState:UIControlStateNormal];
    [backBtn setImage:[UIImage imageNamed:@"Btn_Back_hl"] forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    UIBarButtonItem *leftSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    leftSeperator.width = -20;//此处修改到边界的距离，请自行测试
    [self.navigationItem setLeftBarButtonItems:@[leftSeperator,leftBarItem]];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.barTintColor = nil;
    navBar.shadowImage = nil;
    [navBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, DefaultNavTitleFont, NSFontAttributeName, nil]];
    navBar.tintColor=[UIColor whiteColor];
    UIBarButtonItem * barItemInNavigationBarAppearanceProxy = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil];
    [barItemInNavigationBarAppearanceProxy setTitleTextAttributes:[NSDictionary
                                                                   dictionaryWithObjectsAndKeys:DefaultNavBarButtonFont, NSFontAttributeName,nil] forState:UIControlStateNormal];
    
    navBar.translucent = YES;
    navBar.barStyle = UIBarStyleBlackTranslucent;
    if ([[UINavigationBar class] respondsToSelector:@selector(appearance)]) {
        [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [navBar setBackgroundImage:nil forBarMetrics:UIBarMetricsCompact];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.barTintColor = DefaultNavbarTintColor;
    [navBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:DefaultNavTitleColor, NSForegroundColorAttributeName, DefaultNavTitleFont, NSFontAttributeName, nil]];
    navBar.tintColor=DefaultNavTintColor;
    UIBarButtonItem * barItemInNavigationBarAppearanceProxy = [UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil];
    [barItemInNavigationBarAppearanceProxy setTitleTextAttributes:[NSDictionary
                                                                   dictionaryWithObjectsAndKeys:DefaultNavBarButtonFont, NSFontAttributeName,nil] forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:PICKER_REFRESH_DONE object:nil userInfo:@{@"assets":self.doneAssets}];
    
    self.navigationController.navigationBar.hidden = NO;
    self.toolBar.hidden = NO;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -初始化底部ToorBar
- (void) setupToorBar{
    UIToolbar *toorBar = [[UIToolbar alloc] init];
    toorBar.barTintColor = nil;
    toorBar.tintColor=[UIColor whiteColor];
    if ([[UIToolbar class] respondsToSelector:@selector(appearance)]) {
        [toorBar setBackgroundImage:nil forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        [toorBar setBackgroundImage:nil forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsCompact];
    }
    toorBar.barStyle = UIBarStyleBlackTranslucent;
    toorBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:toorBar];
    self.toolBar = toorBar;
    
    NSDictionary *views = NSDictionaryOfVariableBindings(toorBar);
    NSString *widthVfl =  @"H:|-0-[toorBar]-0-|";
    NSString *heightVfl = @"V:[toorBar(44)]-0-|";
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:widthVfl options:0 metrics:0 views:views]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:heightVfl options:0 metrics:0 views:views]];
    
    // 左视图 中间距 右视图
    UIBarButtonItem *fiexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:self.doneBtn];
    
    toorBar.items = @[fiexItem,rightItem];
}

- (void)deleteAsset{
    //动画
    CAKeyframeAnimation *scaoleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaoleAnimation.duration = 0.25;
    scaoleAnimation.autoreverses = YES;
    scaoleAnimation.values = @[[NSNumber numberWithFloat:1.0],[NSNumber numberWithFloat:1.2],[NSNumber numberWithFloat:1.0]];
    scaoleAnimation.fillMode = kCAFillModeForwards;
    
    NSString *currentPage = [NSString stringWithFormat:@"%ld",self.currentPage];
    if ([_deleteAssets valueForKeyPath:currentPage] == nil) {
        [self.deleteAssets setObject:@YES forKey:currentPage];
        [self.deleleBtn setImage:[UIImage imageNamed:MLSelectPhotoSrcName(@"AssetsPickerCheck")] forState:UIControlStateNormal];
        
        if ([self.doneAssets containsObject:[self.photos objectAtIndex:self.currentPage]]) {
            [self.doneAssets removeObject:[self.photos objectAtIndex:self.currentPage]];
        }
    }else{
        if (self.doneAssets.count >= self.maxCount) {
            NSString *format = [NSString stringWithFormat:@"最多只能选择%zd张图片",self.maxCount];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:format delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
            [alertView show];
            return ;
        }
        
        //动画
        [self.deleleBtn.layer removeAllAnimations];
        [self.deleleBtn.layer addAnimation:scaoleAnimation forKey:@"transform.rotate"];
        
        [self.deleleBtn setImage:[UIImage imageNamed:MLSelectPhotoSrcName(@"AssetsPickerChecked")] forState:UIControlStateNormal];
        if (![self.doneAssets containsObject:[self.photos objectAtIndex:self.currentPage]]) {
            [self.doneAssets addObject:[self.photos objectAtIndex:self.currentPage]];
        }
        [self.deleteAssets removeObjectForKey:currentPage];
        [self.deleleBtn setImage:[UIImage imageNamed:MLSelectPhotoSrcName(@"AssetsPickerChecked") ] forState:UIControlStateNormal];
    }
    
    self.makeView.hidden = !(self.doneAssets.count && self.isEditing);
    self.makeView.text = [NSString stringWithFormat:@"%ld",self.doneAssets.count];
    [self.makeView.layer removeAllAnimations];
    [self.makeView.layer addAnimation:scaoleAnimation forKey:@"transform.rotate"];
}

#pragma mark - reloadData
- (void) reloadData{
    
    [self.collectionView reloadData];
    
    if (self.currentPage >= 0) {
        CGFloat attachVal = 0;
        if (self.currentPage == self.photos.count - 1 && self.currentPage > 0) {
            attachVal = ZLPickerColletionViewPadding;
        }
        
        self.collectionView.ml_x = -attachVal;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(00.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.currentPage) {
                self.collectionView.contentOffset = CGPointMake(self.currentPage * self.collectionView.ml_width, self.collectionView.contentOffset.y);
            }
            else{//第0个
                [self scrollViewDidScroll:self.collectionView];
            }
        });
    }
    
    // 添加自定义View
    [self setPageLabelPage:self.currentPage];
}

- (void)setIsEditing:(BOOL)isEditing{
    _isEditing = isEditing;
    
    if (isEditing) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.deleleBtn];
    }
}

#pragma mark - <UICollectionViewDataSource>
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.photos.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_cellIdentifier forIndexPath:indexPath];
    
    if (self.photos.count) {
        cell.backgroundColor = [UIColor clearColor];
        MLSelectPhotoAssets *photo = self.photos[indexPath.item]; //[self.dataSource photoBrowser:self photoAtIndex:indexPath.item];
        
        if([[cell.contentView.subviews lastObject] isKindOfClass:[UIView class]]){
            [[cell.contentView.subviews lastObject] removeFromSuperview];
        }
        
        UIView *scrollBoxView = [[UIView alloc] init];
        scrollBoxView.frame = cell.bounds;
        scrollBoxView.ml_y = cell.ml_y;
        [cell.contentView addSubview:scrollBoxView];
        
        MLSelectPhotoPickerBrowserPhotoScrollView *scrollView =  [[MLSelectPhotoPickerBrowserPhotoScrollView alloc] init];
        if (self.sheet || self.isShowShowSheet == YES) {
            scrollView.sheet = self.sheet;
        }
        scrollView.backgroundColor = [UIColor clearColor];
        // 为了监听单击photoView事件
        scrollView.frame = [UIScreen mainScreen].bounds;
        scrollView.photoScrollViewDelegate = self;
        scrollView.photo = photo;
        
        [scrollBoxView addSubview:scrollView];
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    return cell;
}
// 单击调用
- (void) pickerPhotoScrollViewDidSingleClick:(MLSelectPhotoPickerBrowserPhotoScrollView *)photoScrollView{
    self.navigationController.navigationBar.hidden = !self.navigationController.navigationBar.isHidden;
    
    if (self.isEditing) {
        self.toolBar.hidden = !self.toolBar.isHidden;
    }
}

#pragma mark - <UIScrollViewDelegate>
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGRect tempF = self.collectionView.frame;
    NSInteger currentPage = (NSInteger)((scrollView.contentOffset.x / scrollView.ml_width) + 0.5);
    if (tempF.size.width < [UIScreen mainScreen].bounds.size.width){
        tempF.size.width = [UIScreen mainScreen].bounds.size.width;
    }
    
    if ((currentPage < self.photos.count -1) || self.photos.count == 1) {
        tempF.origin.x = 0;
    }else if (currentPage == self.photos.count - 1 && self.photos.count > 1) {//modify by lxc
        if (self.view.tag==0) {
            tempF.origin.x = 0;
            self.view.tag=1;
        }
        else{
            tempF.origin.x = -ZLPickerColletionViewPadding;
        }
    }else if(scrollView.isDragging){
        tempF.origin.x = -ZLPickerColletionViewPadding;
    }
    
    if([[self.deleteAssets allValues] count] == 0 || [self.deleteAssets valueForKeyPath:[NSString stringWithFormat:@"%ld",(currentPage)]] == nil){
        [self.deleleBtn setImage:[UIImage imageNamed:MLSelectPhotoSrcName(@"AssetsPickerChecked") ] forState:UIControlStateNormal];
    }else{
        [self.deleleBtn setImage:[UIImage imageNamed:MLSelectPhotoSrcName(@"AssetsPickerCheck") ] forState:UIControlStateNormal];
    }
    
    self.collectionView.frame = tempF;
}

- (void)done{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:PICKER_TAKE_DONE object:nil userInfo:@{@"selectAssets":self.doneAssets}];
    });
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setPageLabelPage:(NSInteger)page{
    self.title = [NSString stringWithFormat:@"%ld / %ld",page + 1, self.photos.count];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat pageWidth = scrollView.ml_width;
    NSInteger currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if (currentPage == self.photos.count - 1 && currentPage != self.currentPage && [[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0) {
        self.collectionView.contentOffset = CGPointMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y);
    }
    self.currentPage = currentPage;
    [self setPageLabelPage:currentPage];
}

@end
