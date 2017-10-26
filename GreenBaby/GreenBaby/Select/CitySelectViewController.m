//
//  CitySelectViewController.m
//  Hunt
//
//  Created by LiXiangCheng on 14/12/11.
//  Copyright (c) 2014年 LiXiangCheng. All rights reserved.
//

#import "CitySelectViewController.h"

@interface CitySelectViewController ()<UITableViewDataSource, UITableViewDelegate,UISearchControllerDelegate, UISearchResultsUpdating>{
    NSIndexPath *_curSelectIndexPath;
    
    NSMutableArray *_cityList;
    NSMutableArray *_alphabets;//["A"]
    NSMutableArray *_listContent;//list <NSMutableArray>
    NSMutableArray *_filteredListContent;//["CityModel"]
}
@property (nonatomic, assign) NSInteger gpsCityID;
@property (nonatomic, strong) NSString *gpsCityName;

@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, weak) IBOutlet UITableView *resultTable;
@end

@implementation CitySelectViewController

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _curSelectIndexPath=[NSIndexPath indexPathForRow:0 inSection:0];
        
        _cityList=[CityModel loadHistory];
        _alphabets=[[NSMutableArray alloc] init];
        _listContent = [[NSMutableArray alloc] initWithCapacity:[kAlphabet count]];
        _filteredListContent = [NSMutableArray new];
        
        self.gpsCityID=0;
        self.gpsCityName=@"";
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title=@"选择城市";
    
    self.automaticallyAdjustsScrollViewInsets=NO;
    
    //不需要创建UISearchBar,表视图用同一个resultTable
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    //设置代理
    _searchController.delegate = self;
    _searchController.searchResultsUpdater = self;
    //搜索时，背景变暗色
    _searchController.dimsBackgroundDuringPresentation = YES;
    //以下两行为YES：UISearchBar会自动占据导航栏
    self.definesPresentationContext = YES;
    _searchController.hidesNavigationBarDuringPresentation = YES;
    _searchController.searchBar.barTintColor = [UIColor grayColor];
    //[_searchController.searchBar setBackgroundImage:[UIImage new]];//去掉上下的黑线
    _searchController.searchBar.frame = CGRectMake(_searchController.searchBar.frame.origin.x, _searchController.searchBar.frame.origin.y, _searchController.searchBar.frame.size.width, 44.0);
    
    self.resultTable.tableHeaderView = _searchController.searchBar;
    
    [[LocationManager sharedInstance] start];
    [self locationChanged:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationChanged:) name:LocationChanged object:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Action

-(void)setGprsCity{
    if ([[LocationManager sharedInstance] latitude]==0.0 && [[LocationManager sharedInstance] longitude]==0.0) {
        self.gpsCityID=0;
        self.gpsCityName =@"正在定位城市";
    }
    else{
        CLPlacemark *mPlacemark = [[LocationManager sharedInstance] placemark];
        NSString *cityName=[NSString stringWithFormat:@"%@,%@",mPlacemark.locality,mPlacemark.administrativeArea];
        self.gpsCityName =(cityName && cityName.length>0)? cityName: @"正在定位城市";
        
        CityModel *city=[CityModel findRecordbyGprs:self.gpsCityName];
        if (city) {
            self.gpsCityID=city.cityid;
            self.gpsCityName=city.cityname;
        }
        else{
            self.gpsCityID=0;
            self.gpsCityName =@"定位失败";
        }
    }
}

-(void)sortedByAlphabet{
    [_alphabets removeAllObjects];
    [_listContent removeAllObjects];
    [_filteredListContent removeAllObjects];
    
    for(NSInteger i = 0;i < [kAlphabet count];++i)
    {
        NSMutableArray *tmp = [[NSMutableArray alloc] init];
        [_listContent addObject:tmp];
    }
    
    NSUInteger count=_cityList.count;
    for(NSUInteger i = 0;i < count;++i)
    {
        CityModel *city=[_cityList objectAtIndex:i];
        
        NSString * alphabet = city.pinyin_first;
        NSUInteger k = [kAlphabet indexOfObject:[alphabet uppercaseString]];
        NSMutableArray *tmp = (NSMutableArray *)[_listContent objectAtIndex:k];
        [tmp addObject:city];
        //tmp = [tmp sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    for(NSInteger i = 0;i < [kAlphabet count];++i)
    {
        NSArray *tmp = (NSArray *)[_listContent objectAtIndex:i];
        if (tmp && tmp.count>0) {
            //tmp.Sort = "cityname AESC";
            NSSortDescriptor *countDescriptor = [[NSSortDescriptor alloc] initWithKey:@"cityname" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
            NSArray *descriptors_count = [NSArray arrayWithObjects:countDescriptor, nil];
            tmp = [tmp sortedArrayUsingDescriptors:descriptors_count];
            [_listContent replaceObjectAtIndex: i withObject: tmp];
            
            [_alphabets addObject:[kAlphabet objectAtIndex:i]];
        }
    }
}

- (void)locationChanged:(NSNotification *)n{
    [self setGprsCity];
    [self sortedByAlphabet];
    [self.resultTable reloadData];
}

#pragma mark Table view methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_cityList count]>0 ){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:@"SelectCell"];
        }
        
        if (self.searchController.active){
            CityModel *city=[_filteredListContent objectAtIndex:indexPath.row];
            cell.textLabel.tag=city.cityid;
            cell.textLabel.text=city.cityname;
            
            if (city.cityid==[_curSelectId integerValue]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                UIImage *image = [UIImage imageNamed:@"checkmark"];
                UIImageView *accessoryIV = [[UIImageView alloc] initWithImage:image];
                accessoryIV.frame=CGRectMake(0.0,0.0,image.size.width,image.size.height);
                cell.accessoryView = accessoryIV;
                
                _curSelectIndexPath = indexPath;
            }
            else{
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
        else{
            if (indexPath.section==0) {
                cell.textLabel.tag=self.gpsCityID;
                cell.textLabel.text=self.gpsCityName;
                
                if (self.gpsCityID==[_curSelectId integerValue]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    UIImage *image = [UIImage imageNamed:@"checkmark"];
                    UIImageView *accessoryIV = [[UIImageView alloc] initWithImage:image];
                    accessoryIV.frame=CGRectMake(0.0,0.0,image.size.width,image.size.height);
                    cell.accessoryView = accessoryIV;
                    
                    _curSelectIndexPath = indexPath;
                }
                else{
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
            else{
                NSString * alphabet=[_alphabets objectAtIndex:indexPath.section-1];
                NSUInteger k = [kAlphabet indexOfObject:[alphabet uppercaseString]];
                NSArray *tmp = (NSArray *)[_listContent objectAtIndex:k];
                CityModel *city = (CityModel *)[tmp objectAtIndex:indexPath.row];
                cell.textLabel.tag=city.cityid;
                cell.textLabel.text=city.cityname;
                
                if (city.cityid==[_curSelectId integerValue]) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    UIImage *image = [UIImage imageNamed:@"checkmark"];
                    UIImageView *accessoryIV = [[UIImageView alloc] initWithImage:image];
                    accessoryIV.frame=CGRectMake(0.0,0.0,image.size.width,image.size.height);
                    cell.accessoryView = accessoryIV;
                    
                    _curSelectIndexPath = indexPath;
                }
                else{
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
            }
        }
        
        cell.textLabel.textColor=MKRGBA(66,66,66,255);
        cell.textLabel.font=CFont(16);
        //1.系统默认选择cell的颜色设置
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //2.自定义选择cell的背景图片设置
        //cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selectbg.png"]];
        //3.自定义选择cell的颜色设置
        cell.backgroundColor=[UIColor whiteColor];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = MKRGBA(246,246,248,255);
        cell.textLabel.highlightedTextColor=MKRGBA(66,66,66,255);
        return cell;
    }
    else {
        UITableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"PlaceholderCell"];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"PlaceholderCell"];
            cell.detailTextLabel.textAlignment = NSTextAlignmentCenter;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.detailTextLabel.backgroundColor=kClearColor;
            
        }
        
        cell.detailTextLabel.text = NSLocalizedString(@"暂无数据",nil);
        return cell;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([_cityList count]>0 ){
        if (self.searchController.active){
            return [_filteredListContent count];
        } else {
            if (section==0) {
                return 1;
            }
            else{
                NSString * alphabet=[_alphabets objectAtIndex:section-1];
                NSUInteger k = [kAlphabet indexOfObject:[alphabet uppercaseString]];
                NSArray *tmp = (NSArray *)[_listContent objectAtIndex:k];
                return [tmp count];
            }
        }
    }
    else{
        return 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([_cityList count]>0 ){
        if (self.searchController.active){
            return 1;
        } else {
            return 1+[_alphabets count];
        }
    }
    else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_cityList count]>0 ){
        if (self.searchController.active){
            return 44;//默认tableView rowHeight=44
        }
        else {
            if (indexPath.section==0) {
                return 44;
            }
            else{
                NSString * alphabet=[_alphabets objectAtIndex:indexPath.section-1];
                NSUInteger k = [kAlphabet indexOfObject:[alphabet uppercaseString]];
                NSArray *tmp = (NSArray *)[_listContent objectAtIndex:k];
                return [tmp count]>0?44:0;
            }
        }
    }
    else{
        return 44;//默认tableView rowHeight=44
    }
}

//section title
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if ([_cityList count]>0 ){
        if (self.searchController.active){
            return nil;
        } else {
            return [[NSArray arrayWithObject:UITableViewIndexSearch] arrayByAddingObjectsFromArray:
                    _alphabets];
        }
    }
    else{
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    if ([_cityList count]>0 ){
        if (self.searchController.active){
            return 0;
        } else {
            if (title == UITableViewIndexSearch) {
                //滚动到顶部
                [tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
                //[tableView scrollRectToVisible:self.searchController.searchBar.frame animated:NO];
                return -1;
            } else {
                return index;
            }
        }
    }
    else{
        return 0;
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([_cityList count]>0 ){
        if (self.searchController.active){
            return nil;
        }
        else
        {
            UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, tableView.sectionHeaderHeight)];
            [headerView setBackgroundColor:MKRGBA(212,212,212,255)];
            headerView.alpha = 1.0;
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableView.bounds.size.width - 10, 18)];
            NSString * alphabet=section==0?@"GPS定位当前城市":[_alphabets objectAtIndex:section-1];
            label.text = alphabet;
            label.textColor = MKRGBA(132,132,132,255);
            label.backgroundColor = [UIColor clearColor];
            [headerView addSubview:label];
            
            return headerView;
            
        }
    }
    else{
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([_cityList count]>0 ){
        if (self.searchController.active)
            return 0;
        else{
            if (section==0) {
                return tableView.sectionHeaderHeight;
            }
            else{
                NSString * alphabet=[_alphabets objectAtIndex:section-1];
                NSUInteger k = [kAlphabet indexOfObject:[alphabet uppercaseString]];
                NSArray *tmp = (NSArray *)[_listContent objectAtIndex:k];
                return [tmp count]>0?tableView.sectionHeaderHeight:0;
            }
        }
    }
    else{
        return 0;
    }
}

//- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
//    return UITableViewCellAccessoryDisclosureIndicator;
//}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([_cityList count]>0 ){
        //选择动画
        //NSIndexPath *oldIndexPath = curSelectIndexPath;
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:_curSelectIndexPath];
        if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
            oldCell.accessoryType = UITableViewCellAccessoryNone;
            oldCell.accessoryView = nil;
        }
        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
        if (newCell.accessoryType == UITableViewCellAccessoryNone) {
            newCell.accessoryType = UITableViewCellAccessoryCheckmark;
            UIImage *image = [UIImage imageNamed:@"checkmark"];
            UIImageView *accessoryIV = [[UIImageView alloc] initWithImage:image];
            accessoryIV.frame=CGRectMake(0.0,0.0,image.size.width,image.size.height);
            newCell.accessoryView = accessoryIV;
        }
        _curSelectIndexPath = indexPath;
        
        //保存选择项
        if (self.searchController.active) {
            CityModel *city=[_filteredListContent objectAtIndex:indexPath.row];
            if (_selectCompletion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _selectCompletion([NSString stringWithFormat:@"%@",@(city.cityid)]);
                });
            }
        }
        else {
            if (indexPath.section==0) {//GPS定位当前城市
                if (_selectCompletion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _selectCompletion([NSString stringWithFormat:@"%@",self.gpsCityID>0?@(self.gpsCityID):_curSelectId]);
                    });
                }
            }
            else{
                NSString *alphabet=[_alphabets objectAtIndex:indexPath.section-1];
                NSUInteger k = [kAlphabet indexOfObject:[alphabet uppercaseString]];
                NSArray *tmp = (NSArray *)[_listContent objectAtIndex:k];
                CityModel *city = (CityModel *)[tmp objectAtIndex:indexPath.row];
                if (_selectCompletion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _selectCompletion([NSString stringWithFormat:@"%@",@(city.cityid)]);
                    });
                }
            }
        }
        
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}

/*
 // Override to support conditional editing of the table view.
 */
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

#pragma mark UISearchControllerDelegate

- (void)presentSearchController:(UISearchController *)searchController{
    CLog(@"presentSearchController");
}
- (void)willPresentSearchController:(UISearchController *)searchController{
    CLog(@"willPresentSearchController");
}
- (void)didPresentSearchController:(UISearchController *)searchController{
    CLog(@"didPresentSearchController");
}
- (void)willDismissSearchController:(UISearchController *)searchController{
    CLog(@"willDismissSearchController");
}
- (void)didDismissSearchController:(UISearchController *)searchController{
    CLog(@"didDismissSearchController");
}

#pragma mark UISearchResultsUpdating

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    //修改取消按钮的颜色和文字
    [_searchController.searchBar setShowsCancelButton:YES animated:NO];
    UIButton *cancelBtn = [_searchController.searchBar valueForKey:@"cancelButton"];
    if (cancelBtn) {
        //[cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }
    
    NSString *searchText = _searchController.searchBar.text;
    [_filteredListContent removeAllObjects];
    for (NSArray *section in _listContent) {
        for (CityModel *city in section)
        {
//            NSComparisonResult result = [city.cityname compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
//            if (result == NSOrderedSame)
//            {
//                [_filteredListContent addObject:city];
//            }
            if (searchText && searchText.length>0) {
                NSString *searchKey=[NSString stringWithFormat:@"%@,%@,%@",city.pinyin_second,city.pinyin_full,city.cityname];
                NSRange range = [searchKey rangeOfString:[searchText lowercaseString]];
                if (range.location!=NSNotFound) {
                    [_filteredListContent addObject:city];
                }
            }
        }
    }
    [self.resultTable reloadData];
}

@end
