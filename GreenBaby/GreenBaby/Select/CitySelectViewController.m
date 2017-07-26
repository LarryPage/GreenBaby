//
//  CitySelectViewController.m
//  Hunt
//
//  Created by LiXiangCheng on 14/12/11.
//  Copyright (c) 2014年 LiXiangCheng. All rights reserved.
//

#import "CitySelectViewController.h"

@interface CitySelectViewController ()<UITableViewDataSource, UITableViewDelegate>{
    NSIndexPath *_curSelectIndexPath;
    
    NSMutableArray *_cityList;
    NSMutableArray *_alphabets;//["A"]
    NSMutableArray *_listContent;//list <NSMutableArray>
    NSMutableArray *_filteredListContent;//["City"]
}

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *resultTable;

@property (nonatomic, assign) NSInteger gpsCityID;
@property (nonatomic, strong) NSString *gpsCityName;

@property (nonatomic, strong) NSString *savedSearchTerm;
@property (nonatomic, assign) NSInteger savedScopeButtonIndex;
@property (nonatomic, assign) BOOL searchWasActive;
@end

@implementation CitySelectViewController

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _curSelectIndexPath=[NSIndexPath indexPathForRow:0 inSection:0];
        
        _cityList=[City loadHistory];
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
        
        City *city=[City findRecordbyGprs:self.gpsCityName];
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
    if (self.savedSearchTerm)
    {
        [self.searchDisplayController setActive:self.searchWasActive];
        [self.searchDisplayController.searchBar setText:_savedSearchTerm];
        
        self.savedSearchTerm = nil;
    }
    
    self.searchDisplayController.searchResultsTableView.scrollEnabled = YES;
    self.searchDisplayController.searchBar.showsCancelButton = NO;
    
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
        City *city=[_cityList objectAtIndex:i];
        
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
        
        if (tableView == self.searchDisplayController.searchResultsTableView){
            City *city=[_filteredListContent objectAtIndex:indexPath.row];
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
                City *city = (City *)[tmp objectAtIndex:indexPath.row];
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
        cell.textLabel.font=[UIFont systemFontOfSize:16];
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
        if (tableView == self.searchDisplayController.searchResultsTableView) {
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
        if (tableView == self.searchDisplayController.searchResultsTableView) {
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
        if (tableView == self.searchDisplayController.searchResultsTableView) {
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
        if (tableView == self.searchDisplayController.searchResultsTableView) {
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
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            return 0;
        } else {
            if (title == UITableViewIndexSearch) {
                //滚动到顶部
                [tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
                //[tableView scrollRectToVisible:self.searchDisplayController.searchBar.frame animated:NO];
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
        if (tableView == self.searchDisplayController.searchResultsTableView) {
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
        if (tableView == self.searchDisplayController.searchResultsTableView)
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

/*
 - (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
 return UITableViewCellAccessoryDisclosureIndicator;
 }
 */

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
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            [self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:YES];
            
            City *city=[_filteredListContent objectAtIndex:indexPath.row];
            if (_selectCompletion) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    _selectCompletion([NSString stringWithFormat:@"%@",@(city.cityid)]);
                });
            }
        }
        else {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            if (indexPath.section==0) {//GPS定位当前城市
                if (_selectCompletion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _selectCompletion([NSString stringWithFormat:@"%@",self.gpsCityID>0?@(self.gpsCityID):_curSelectId]);
                    });
                }
            }
            else{
                NSString * alphabet=[_alphabets objectAtIndex:indexPath.section-1];
                NSUInteger k = [kAlphabet indexOfObject:[alphabet uppercaseString]];
                NSArray *tmp = (NSArray *)[_listContent objectAtIndex:k];
                City *city = (City *)[tmp objectAtIndex:indexPath.row];
                if (_selectCompletion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _selectCompletion([NSString stringWithFormat:@"%@",@(city.cityid)]);
                    });
                }
            }
        }
        
    }
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
}

/*
 // Override to support conditional editing of the table view.
 */
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)_searchBar
{
    [self.searchDisplayController.searchBar setShowsCancelButton:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar
{
    [self.searchDisplayController setActive:NO animated:YES];
    [self.resultTable reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
    //	[self.searchDisplayController setActive:NO animated:YES];
    //	[self.searchDisplayController.searchResultsTableView reloadData];
}

#pragma mark ContentFiltering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    [_filteredListContent removeAllObjects];
    for (NSArray *section in _listContent) {
        for (City *city in section)
        {
//            NSComparisonResult result = [city.cityname compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
//            if (result == NSOrderedSame)
//            {
//                [_filteredListContent addObject:user];
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
}

#pragma mark UISearchDisplayDelegate

-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [UIView animateWithDuration:0.25 animations:^{
            for (UIView *subview in self.view.subviews)
                subview.transform = CGAffineTransformMakeTranslation(0,([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)?-44:-88);
        }];
    }
}

-(void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        [UIView animateWithDuration:0.25 animations:^{
            for (UIView *subview in self.view.subviews)
                subview.transform = CGAffineTransformIdentity;
        }];
    }
}

-(void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
    self.searchDisplayController.searchResultsTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    self.searchDisplayController.searchResultsTableView.separatorColor=MKRGBA(204,204,204,255);
    self.searchDisplayController.searchResultsTableView.backgroundColor=MKRGBA(246,246,248,255);
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        //self.searchDisplayController.searchResultsTableView.separatorInset=UIEdgeInsetsMake(0, 63, 0, 0);
        //键盘
//        UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 216, 0);
//        self.searchDisplayController.searchResultsTableView.contentInset = insets;
//        self.searchDisplayController.searchResultsTableView.scrollIndicatorInsets = insets;
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    return YES;
}

@end
