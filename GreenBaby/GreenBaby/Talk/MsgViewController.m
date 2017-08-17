//
//  MsgViewController.m
//  InterestingExchange
//
//  Created by LiXiangCheng on 15/8/14.
//  Copyright (c) 2015年 LiXiangCheng. All rights reserved.
//

#import "MsgViewController.h"
#import "MsgCell.h"
#import "FriendTalkViewController.h"

@interface MsgViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,UIViewControllerPreviewingDelegate>{
    id <UIViewControllerPreviewing> _previewingContext;
}
@property (nonatomic, strong) NSError *error;//nil:正常返回 error.code:0-请求中，-1-网络异常
@property (nonatomic, assign) int pagecount;//每页数
@property (nonatomic, assign) int page;//第几页，初始值1
@property (nonatomic, assign) BOOL loadingMore;// 加载状态
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) NSInteger startid;//第一页对话记录的最大id
@property (nonatomic, weak)   IBOutlet UITableView *resultTable;
@property (nonatomic, strong) NSMutableArray *searchList;//搜索结果
@end

@implementation MsgViewController

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _error=[NSError errorWithDomain:@"正在获取数据"
                                   code:0
                               userInfo:nil];
        self.searchList=[NSMutableArray array];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (_previewingContext)
        [self unregisterForPreviewingWithContext:_previewingContext];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title=@"信箱";
    self.backBtn.hidden=YES;
    
    //ios7
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets=NO;//ios7 deltas for resultTable
    }
    
    //修复下拉刷新位置错误 代码开始
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        UIEdgeInsets insets = self.resultTable.contentInset;
        insets.top = -1;
        insets.bottom = -1;
        self.resultTable.contentInset = insets;
        self.resultTable.scrollIndicatorInsets = insets;
    }
    
    // setup the pull-to-refresh view
    WEAKSELF
    [self.resultTable addPullToRefreshWithActionHandler:^{
        weakSelf.page=1;
        weakSelf.pagecount=10;
        weakSelf.startid=0;
        [weakSelf performSelector:@selector(getMsgList) withObject:nil afterDelay:0.0];
    }];
    //[self.resultTable.pullToRefreshView triggerRefresh];
    
    //[self setTableViewInsets];
    
    _page=1;
    _pagecount=10;
    _startid=0;
    //[self performSelector:@selector(getMsgList) withObject:nil afterDelay:0.0];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageReceiveCount:) name:MessageReceiveCount object:nil];
    
    if ([self respondsToSelector:@selector(registerForPreviewingWithDelegate:sourceView:)])
        _previewingContext = [self registerForPreviewingWithDelegate:self sourceView:self.resultTable];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self messageReceiveCount:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark custom Notification

//消息接收
- (void)messageReceiveCount:(NSNotification *)n {
    _page=1;
    _pagecount=self.searchList.count>0?ceilf(self.searchList.count/10.0)*10:10;//ceilf:上限
    _startid=0;
    
    //[self.searchList removeAllObjects];
    self.resultTable.tableFooterView = nil;
    //[self.resultTable reloadData];
    [self performSelector:@selector(getMsgList) withObject:nil afterDelay:0.0];
}

#pragma mark Action

- (IBAction)reLoadBtn:(id)sender{
    [self showHudInView:self.view hint:@"请稍等..."];
    
    _page=1;
    _pagecount=10;
    _startid=0;
    [self performSelector:@selector(getMsgList) withObject:nil afterDelay:0.0];
}

#pragma mark - UIViewControllerPreviewingDelegate

//peek
- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location{
    NSIndexPath *indexPath=[self.resultTable indexPathForRowAtPoint:location];
    if (!indexPath) {
        return nil;
    }
    else{
        //This will show the cell clearly and blur the rest of the screen for our peek.
        previewingContext.sourceRect = [self.resultTable rectForRowAtIndexPath:indexPath];
        
        MessageDetail *record = [self.searchList objectAtIndex:indexPath.row];
        FriendTalkViewController *vc=[[FriendTalkViewController alloc] initWithMsg:record];
        vc.hidesBottomBarWhenPushed = YES;
        return vc;
    }
}
//pop
- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit{
    if (viewControllerToCommit) {
        [self showViewController:viewControllerToCommit sender:self];
    }
}

#pragma mark - Scroll Message TableView Helper Method

- (void)setTableViewInsets{
    UIEdgeInsets insets = UIEdgeInsetsMake(0-2, 0, 0-2, 0);
    self.resultTable.contentInset = insets;
    self.resultTable.scrollIndicatorInsets = insets;
}

#pragma mark Table view methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.searchList count]>0 ){
        MessageDetail *record = [self.searchList objectAtIndex:indexPath.row];
        
        NSString *identifier=@"MsgCell1";
        MsgCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            NSArray *nibArray = [[NSBundle mainBundle] loadNibNamed:@"MsgCell" owner:nil options:nil];
            cell = (MsgCell *)[nibArray objectAtIndex:1];
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.tag=indexPath.row;
        [cell showMessage:record];
        return cell;
    }
    else {
        UITableViewCell *cell =  nil;//[tableView dequeueReusableCellWithIdentifier:@"PlaceholderCell"];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"PlaceholderCell"];
            [cell.contentView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [obj removeFromSuperview];
            }];
        }
        
        cell.backgroundColor=[UIColor whiteColor];
        
        if (_error) {
            if(_error.code==0 ){
                UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 164, [[UIScreen mainScreen] bounds].size.width, 42)];
                statusLabel.font = CFont(16);
                statusLabel.textColor=MKRGBA(66,66,66,255);
                statusLabel.textAlignment = NSTextAlignmentCenter;
                statusLabel.text = NSLocalizedString(@"正在获取数据",nil);
                statusLabel.numberOfLines=1;
                statusLabel.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:statusLabel];
            }
            else if (_error.code == -1) {
                UIImageView *noResultIV=[[UIImageView alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width-100)/2, 154, 100, 100)];
                noResultIV.image=[UIImage imageNamed:@"EH_No_Network"];
                [cell.contentView addSubview:noResultIV];
                
                UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 274, [[UIScreen mainScreen] bounds].size.width-80, 42)];
                statusLabel.font = CFont(12);
                statusLabel.textColor=MKRGBA(146,146,146,255);
                statusLabel.textAlignment = NSTextAlignmentCenter;
                statusLabel.text = NSLocalizedString(@"抱歉，你的网络好像有点问题。\n请检查网络设置",nil);
                statusLabel.numberOfLines=0;
                statusLabel.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:statusLabel];
            }
            else{
                UIImageView *noResultIV=[[UIImageView alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width-150)/2, 154, 150, 151.6)];
                noResultIV.image=[UIImage imageNamed:@"EH_No_Result"];
                [cell.contentView addSubview:noResultIV];
                
                UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 269, [[UIScreen mainScreen] bounds].size.width-40, 63)];
                statusLabel.font = CFont(12);
                statusLabel.textColor=MKRGBA(146,146,146,255);
                statusLabel.textAlignment = NSTextAlignmentCenter;
                statusLabel.text = _error.domain;
                statusLabel.numberOfLines=4;
                statusLabel.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:statusLabel];
            }
        }
        else{
            UIImageView *noResultIV=[[UIImageView alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width-150)/2, 154, 150, 151.6)];
            noResultIV.image=[UIImage imageNamed:@"EH_No_Result"];
            [cell.contentView addSubview:noResultIV];
            
            UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 269, [[UIScreen mainScreen] bounds].size.width-40, 63)];
            statusLabel.font = CFont(12);
            statusLabel.textColor=MKRGBA(146,146,146,255);
            statusLabel.textAlignment = NSTextAlignmentCenter;
            statusLabel.text = @"暂无数据";
            statusLabel.numberOfLines=4;
            statusLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:statusLabel];
        }
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger count = [self.searchList count];
    if (count == 0)
    {
        count = 1;
    }
    return count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self.searchList count]==0)
        return tableView.frame.size.height;
    else{
        MessageDetail *record = [self.searchList objectAtIndex:indexPath.row];
        return [MsgCell calcCellHeight:record];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view= [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 1)];
    view.backgroundColor=[UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view= [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 1)];
    view.backgroundColor=[UIColor clearColor];
    return view;
}

/*
 - (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
 return UITableViewCellAccessoryDisclosureIndicator;
 }
 */

#pragma mark Table view delegate

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    //for ios 8.0
//    // Remove seperator inset
//    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
//        [cell setSeparatorInset:UIEdgeInsetsZero];
//    }
//
//    // Prevent the cell from inheriting the Table View's margin settings
//    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
//        [cell setPreservesSuperviewLayoutMargins:NO];
//    }
//
//    // Explictly set your cell's layout margins
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
//        [cell setLayoutMargins:UIEdgeInsetsZero];
//    }
//
//    tableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.searchList count]>0){
        MessageDetail *record = [self.searchList objectAtIndex:indexPath.row];
        record.unread = 0;
        
        MsgCell *cell = (MsgCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.unreadLabel.hidden=YES;
        
        FriendTalkViewController *vc=[[FriendTalkViewController alloc] initWithMsg:record];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

/*
 // Override to support conditional editing of the table view.
 */
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

/*
 // Override to support editing the table view.
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle: (UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
}

#pragma mark paging 底部

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (((UITableView *)scrollView)==_resultTable) {
        if (self.resultTable.tableFooterView) {
            // 下拉到最底部时显示更多数据
            if(!_loadingMore && scrollView.contentOffset.y > ((scrollView.contentSize.height - scrollView.frame.size.height))){
                [self loadDataBegin];
            }
        }
    }
}

// 开始加载数据
- (void) loadDataBegin
{
    if (_loadingMore == NO)
    {
        _loadingMore = YES;
        UIActivityIndicatorView *tableFooterActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width-116.0f)/2-30, 10.0f, 20.0f, 20.0f)];
        [tableFooterActivityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        [tableFooterActivityIndicator startAnimating];
        [self.resultTable.tableFooterView addSubview:tableFooterActivityIndicator];
        
        _pagecount=10;
        [self performSelector:@selector(getMsgList) withObject:nil afterDelay:0.0];
    }
}

// 加载数据中
- (void) loadDataing:(NSMutableArray *)moreList
{
    NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:[moreList count]];
    
    for (int ind = 0; ind < [moreList count]; ind++) {
        NSIndexPath    *newPath =  [NSIndexPath indexPathForRow:[self.searchList count]+ind inSection:0];
        [insertIndexPaths addObject:newPath];
    }
    
    [self.searchList addObjectsFromArray:moreList];
    //[self.resultTable insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
    [self.resultTable reloadData];
    
    [self loadDataEnd];
    if ([moreList count]>=_pagecount) {
        [self createTableFooter];
    }
    else{
        self.resultTable.tableFooterView = nil;
    }
    //[self.resultTable endUpdates];
}

// 加载数据完毕
- (void) loadDataEnd
{
    _loadingMore = NO;
    //[self createTableFooter];
}

// 创建表格底部
- (void) createTableFooter
{
    self.resultTable.tableFooterView = nil;
    
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width, 40.0f)];
    tableFooterView.backgroundColor=[UIColor clearColor];
    UILabel *loadMoreText = [[UILabel alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width-116.0f)/2, 0.0f, 116.0f, 40.0f)];
    //[loadMoreText setCenter:tableFooterView.center];
    [loadMoreText setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
    loadMoreText.textColor=[UIColor grayColor];
    [loadMoreText setText:@"上拉显示更多数据"];
    loadMoreText.backgroundColor=[UIColor clearColor];
    [tableFooterView addSubview:loadMoreText];
    
    self.resultTable.tableFooterView = tableFooterView;
}

#pragma mark Interface

//获取信箱信息列表
- (void)getMsgList
{
    if (_isLoading) {
        return;
    }
    if (_page==1) {
        _startid=0;
    }
    else{
        if ([self.searchList count]>0) {
            MessageDetail *record = [self.searchList objectAtIndex:0];
            _startid=record.msgid;
        }
    }
    _isLoading = YES;
    WEAKSELF
    [API getMsgListWithPage:_page
                      count:_pagecount
                    startid:_startid
                 completion:^(NSError *error, id response) {
                     [weakSelf hideHud];
                     weakSelf.error=error;
                     weakSelf.isLoading=NO;
                     if (!error) {
                         NSMutableArray *moreList=[NSMutableArray array];
                         NSArray *records = response[@"message_list"];
                         if (records && records.count>0) {
                             for (NSDictionary *recordDic in records) {
                                 MessageDetail *record=[[MessageDetail alloc] initWithDic:recordDic];
                                 [moreList addObject:record];
                             }
                             //[moreList sortUsingFunction:newsPositionSort context:nil];
                             
                             if (weakSelf.page==1) {
                                 [self.searchList removeAllObjects];
                                 
                                 //缓存
                                 [MessageDetail clearHistory];
                                 [MessageDetail addRecords:moreList];
                             }
                             weakSelf.page+=1;
                         }
                         
                         if([weakSelf.searchList count]==0)
                         {
                             [weakSelf.searchList addObjectsFromArray:moreList];
                             [weakSelf.resultTable reloadData];
                             if ([moreList count]>=weakSelf.pagecount) {
                                 [weakSelf createTableFooter];
                             }
                         }
                         else{
                             [weakSelf performSelectorOnMainThread:@selector(loadDataing:) withObject:moreList waitUntilDone:NO];
                         }
                     }
                     else{//code>0
                         [[TKAlertCenter defaultCenter] postAlertWithMessage:error.domain];
                         
                         if (weakSelf.searchList.count == 0) {  //加载缓存数据
                             NSArray *records=[MessageDetail loadHistory];
                             if (records && records.count>0) {
                                 [weakSelf.searchList addObjectsFromArray:records];
                                 _page+=1;
                             }
                         }
                         
                         [weakSelf.resultTable reloadData];
                         if ([weakSelf.searchList count]>=weakSelf.pagecount) {
                             [weakSelf createTableFooter];
                         }
                     }
                     
                     [weakSelf.resultTable.pullToRefreshView performSelector:@selector(stopAnimating) withObject:nil afterDelay:0.0];
    }];
}

@end
