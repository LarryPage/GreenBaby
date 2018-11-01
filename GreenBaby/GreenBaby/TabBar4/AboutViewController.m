//
//  AboutViewController.m
//  BrcIot
//
//  Created by XiangCheng Li on 2018/5/16.
//  Copyright © 2018年 BRC. All rights reserved.
//

#import "AboutViewController.h"
#import "AboutTableHeaderView.h"
#import "PrivacyViewController.h"
#import "FFATManager.h"

@interface AboutViewController ()
@property (nonatomic,weak) IBOutlet UITableView *resultTable;
@property (nonatomic,strong) AboutTableHeaderView *headerView;
@end

@implementation AboutViewController

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title=[NSString stringWithFormat:@"关于%@",kProductName];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self reloadUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceModelCurRecordChanged:) name:@"DeviceModelCurRecordChanged" object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark custom Notification

//消息接收
- (void)deviceModelCurRecordChanged:(NSNotification *)n {
    [self reloadUI];
}

#pragma mark Action

- (void)reloadUI
{
    NSArray *xibs = [[NSBundle mainBundle] loadNibNamed:@"AboutTableHeaderView" owner:nil options:nil];
    self.headerView = [xibs objectAtIndex:0];
    self.headerView.frame = CGRectMake(0, 0, KUIScreeWidth,KUIScreeWidth*160.0/375.0);
    self.headerView.nameVersionLbl.text = [NSString stringWithFormat:@"%@ 版本：%@",kProductName,kVersion];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logoTap:)];
    tap.numberOfTapsRequired = 5;
    tap.numberOfTouchesRequired = 1;
    [self.headerView.iconIV addGestureRecognizer:tap];
    
    self.resultTable.tableHeaderView = self.headerView;
    
    [self.resultTable reloadData];
}

- (void)logoTap:(UIGestureRecognizer *)tap
{
    DeviceModel *device = [DeviceModel loadCurRecord];
    if (device.isShowAssistiveTouch==0) {
        device.isShowAssistiveTouch=1;
        [[FFATManager sharedInstance] showAssistiveTouch];
    } else {
        device.isShowAssistiveTouch=0;
        [[FFATManager sharedInstance] dismiss];
    }
    [DeviceModel saveCurRecord:device];
}

#pragma mark - Scroll Message TableView Helper Method

- (void)setTableViewInsets{
    UIEdgeInsets insets = UIEdgeInsetsMake(0-2, 0, 0, 0);
    self.resultTable.contentInset = insets;
    self.resultTable.scrollIndicatorInsets = insets;
}

#pragma mark Table view methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AboutCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"AboutCell"];
    }
    
    switch (indexPath.section) {
        case 0:
        default:
        {
            switch (indexPath.row) {
                case 0:
                default:
                    cell.textLabel.text=@"服务协议";
                    break;
            }
        }
            break;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
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
    switch (indexPath.section) {
        case 0:
        default:
        {
            switch (indexPath.row) {
                case 0:
                default:
                {
                    UIViewController *vc=[[PrivacyViewController alloc] init];
                    vc.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
            }
        }
            break;
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

@end
