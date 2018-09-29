//
//  TestSpecailViewController.m
//  BrcIot
//
//  Created by LiXiangCheng on 2018/9/28.
//  Copyright © 2018年 BRC. All rights reserved.
//

#import "TestSpecailViewController.h"

@interface TestSpecailViewController ()
@property (nonatomic,weak) IBOutlet UITableView *resultTable;
@property (nonatomic, strong) DeviceModel *device;
@end

@implementation TestSpecailViewController

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.device=[DeviceModel loadCurRecord];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title=@"环境设置";
    self.rightBtn.hidden=NO;
    [self.rightBtn setTitle:@"更换" forState:UIControlStateNormal];
    [self.rightBtn setTitle:@"更换" forState:UIControlStateHighlighted];
    [self.rightBtn setImage:nil forState:UIControlStateNormal];
    [self.rightBtn setImage:nil forState:UIControlStateHighlighted];
    
    [self.resultTable reloadData];
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

- (IBAction)rightBtn:(id)sender{
    [DeviceModel saveCurRecord:self.device];//保存apiEnv
    
    [self showHudInView:self.view hint:@"环境更换成功，app将自动关闭"];
    [[AppDelegate sharedAppDelegate] performSelector:@selector(killApp) withObject:nil afterDelay:2];
}

#pragma mark Table view methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TestSpecailCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"TestSpecailCell"];
    }
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text=[NSString stringWithFormat:@"开发环境:%@",[kAPIList safeObjectAtIndex:indexPath.row]];
            break;
        case 1:
            cell.textLabel.text=[NSString stringWithFormat:@"测试环境:%@",[kAPIList safeObjectAtIndex:indexPath.row]];
            break;
        case 2:
        default:
            cell.textLabel.text=[NSString stringWithFormat:@"线上环境:%@",[kAPIList safeObjectAtIndex:indexPath.row]];
            break;
    }
    
    if (self.device.apiEnv==indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        UIImage *image = [UIImage imageNamed:@"checkmark"];
        UIImageView *accessoryIV = [[UIImageView alloc] initWithImage:image];
        accessoryIV.frame=CGRectMake(0.0,0.0,image.size.width,image.size.height);
        cell.accessoryView = accessoryIV;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = nil;
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view= [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 10)];
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
    self.device.apiEnv=indexPath.row;
    [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:(UITableViewRowAnimationAutomatic)];
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
