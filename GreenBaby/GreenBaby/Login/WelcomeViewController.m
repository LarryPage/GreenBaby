//
//  WelcomeViewController.m
//  Hunt
//
//  Created by LiXiangCheng on 15/1/23.
//  Copyright (c) 2015年 LiXiangCheng. All rights reserved.
//

#import "WelcomeViewController.h"
#import "StartViewController.h"

@interface WelcomeViewController ()<UIScrollViewDelegate>{
    
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIView *pageView;
@property (strong, nonatomic) UIButton *enterButton;
@end

@implementation WelcomeViewController

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.statusBarHidden=YES;
    }
    return self;
}

- (void)dealloc {
}

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    _scrollView.bounces = NO;
    _scrollView.bouncesZoom = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.scrollsToTop = NO;
    
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    
    _scrollView.userInteractionEnabled = YES;
    _scrollView.delegate = self;
    
    NSInteger cx = 0;
    NSInteger height = _scrollView.frame.size.height;
    for (int i = 0; i < 4; i++) {
        
        UIImageView *imgIV = [[UIImageView alloc] init];
        NSString *imgstr=[NSString stringWithFormat:@"guide%d@2x.jpg",i+1];
        
        CGFloat bottom=80;
        if (IS_IPHONE_4_OR_LESS) {
            imgstr=[NSString stringWithFormat:@"guide%d@2x.jpg",i+1];
            bottom=80;
        }
        else if (IS_IPHONE_5){
            imgstr=[NSString stringWithFormat:@"guide%d-568h@2x.jpg",i+1];
            bottom=85;
        }
        else if (IS_IPHONE_6_7_8){
            imgstr=[NSString stringWithFormat:@"guide%d-667h@2x.jpg",i+1];
            bottom=98;
        }
        else if (IS_IPHONE_6P_6SP_7P_8P){
            imgstr=[NSString stringWithFormat:@"guide%d-736h@3x.jpg",i+1];
            bottom=105;
        }
        else if (IS_IPHONE_X){
            imgstr=[NSString stringWithFormat:@"guide%d-812h@3x.jpg",i+1];
            bottom=105;
        }
        else if (IS_IPAD){
            imgstr=[NSString stringWithFormat:@"guide%d-ipad.jpg",i+1];
            bottom=80;
        }
        imgIV.image = [UIImage imageNamed:imgstr];
        imgIV.tag=i+1;
        imgIV.contentMode = UIViewContentModeScaleToFill;
        //imgIV.frame = CGRectMake(0,0,320,290);
        
        CGRect frame = imgIV.frame;
        frame.size.height = _scrollView.frame.size.height;
        frame.origin.x = cx;
        frame.origin.y = 0;
        frame.size.width = _scrollView.frame.size.width;
        imgIV.frame = frame;
        
        [_scrollView addSubview:imgIV];
        
        //add button
        switch (i) {
            case 3:
            {
                _enterButton = [UIButton buttonWithType:UIButtonTypeCustom];
                _enterButton.frame = CGRectMake(cx+([[UIScreen mainScreen] bounds].size.width-217)/2,[[UIScreen mainScreen] bounds].size.height-bottom,217,45);
                _enterButton.backgroundColor=[UIColor clearColor];
                [_enterButton setImage:[UIImage imageNamed:@"enter_normal"] forState:UIControlStateNormal];
                [_enterButton setImage:[UIImage imageNamed:@"enter_pressed"] forState:UIControlStateHighlighted];
                [_enterButton addTarget:self action:@selector(enterBtn:) forControlEvents:UIControlEventTouchUpInside];
                [_scrollView addSubview:_enterButton];
                //[_enterButton enableEventTracking];//自动埋点
            }
                break;
            default:
                break;
        }
        
        cx += _scrollView.frame.size.width;
    }
    
    [_scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width * 4, height)];
    
    _pageView=[[UIView alloc] initWithFrame:CGRectMake(0, _scrollView.frame.size.height-5, _scrollView.frame.size.width/4, 5)];
    _pageView.backgroundColor=MKRGBA(217,217,217,255);
    _pageView.tag=0;//当前页
    [self.view addSubview:_pageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Action

- (IBAction)enterBtn:(id)sender{
    if ([[AppDelegate sharedAppDelegate].window.rootViewController isKindOfClass:[CustomTabBarController class]]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        BOOL showedGuidInVersion=TRUE;
        [[NSUserDefaults standardUserDefaults] setBool:showedGuidInVersion forKey:[NSString stringWithFormat:@"showedGuidInVersion%@",kVersion]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        UserModel *user = [UserModel loadCurRecord];
        if (user && user.user_id) {
            CustomTabBarController *mtabBarController = [[CustomTabBarController alloc] init];
            [AppDelegate sharedAppDelegate].window.rootViewController = mtabBarController;
        } else {//登录/注册
            UIViewController *vc = [[StartViewController alloc] init];
            UINavigationController *nc = [[NavRootViewController alloc] initWithRootViewController:vc];
            //UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
            nc.navigationBar.translucent = NO;
            [AppDelegate sharedAppDelegate].window.rootViewController = nc;
        }
    }
}

#pragma mark UIScrollViewDelegate
//滚动中
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = _scrollView.frame.size.width;
    NSUInteger currentPage = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    CGRect frame=_pageView.frame;
    frame.origin.x=_scrollView.contentOffset.x/_scrollView.contentSize.width*_scrollView.frame.size.width;
    _pageView.frame=frame;
    _pageView.tag=currentPage;
}

//滚动开始
// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
}

//滚动结束
- (void)scrollViewDidEndDecelerating:(UIScrollView *)sender{
}

@end
