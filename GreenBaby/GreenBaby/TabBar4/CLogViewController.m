//
//  CLogViewController.m
//  BrcIot
//
//  Created by LiXiangCheng on 2018/10/31.
//  Copyright © 2018年 BRC. All rights reserved.
//

#import "CLogViewController.h"

@interface CLogViewController ()
@property (nonatomic,weak) IBOutlet UITableView *resultTable;
@property (nonatomic,strong) NSMutableArray <CLogModel *>*logList;//日志列表
@end

@implementation CLogViewController

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.statusBarHidden=NO;
        self.logList=[NSMutableArray arrayWithArray:[CLogger sharedInstance].logList];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title=@"日志";
    self.rightBtn.hidden=NO;
    [self.rightBtn setTitle:@"分享" forState:UIControlStateNormal];
    [self.rightBtn setTitle:@"分享" forState:UIControlStateHighlighted];
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
    NSString * fullLogStr =@"";
    for (CLogModel *msg in self.logList) {
        NSString *timeStr = [msg.time formattedDateWithFormatString:@"MM-dd HH:mm:ss.SSS"];
        NSString *logStr = [NSString stringWithFormat:@"%@ | %@ - %@:%@ | %@",timeStr,msg.fileName,msg.function,@(msg.line),msg.msg];
        
        fullLogStr = [fullLogStr stringByAppendingString:logStr];
        fullLogStr = [fullLogStr stringByAppendingString:@"\n"];
    }
    
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *fileName = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.txt",[[NSDate date] formattedDateWithFormatString:@"YYYY-MM-dd-HH-mm"]]];
    NSURL *fileUrl = [NSURL fileURLWithPath:fileName];
    
    BOOL isWrite = [fullLogStr writeToURL:fileUrl atomically:YES encoding:NSUTF8StringEncoding error:nil];
    if (!isWrite) {
        return;
    }
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[@"日志", [NSURL fileURLWithPath:fileName]] applicationActivities:nil];
    
    [[AppDelegate sharedAppDelegate].window.rootViewController presentViewController:activityViewController animated:YES completion:nil];
}

#pragma mark Table view methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CLogCell"];
    UILabel * label;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"CLogCell"];
        cell.clipsToBounds = YES;
        cell.backgroundColor = UIColor.clearColor;
        
        label = [UILabel new];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize:13];
        label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        label.numberOfLines = 0;
        label.frame = cell.contentView.bounds;
        [cell.contentView addSubview:label];
    }
    else
    {
        label = (UILabel *)cell.contentView.subviews[0];
    }
    
    label.textColor = UIColorFromRGB(0xFF008312);
    
    CLogModel *msg=[self.logList safeObjectAtIndex:indexPath.row];
    NSString *timeStr = [msg.time formattedDateWithFormatString:@"MM-dd HH:mm:ss.SSS"];
    NSString *logStr;
    if (msg.bExpand) {
        logStr = [NSString stringWithFormat:@" Ⓘ %@ | %@ - %@:%@ | %@",timeStr,msg.fileName,msg.function,@(msg.line),msg.msg];
    }
    else{
        logStr = [NSString stringWithFormat:@" Ⓘ %@ | %@",timeStr,msg.msg];
    }
    label.text = logStr;
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.logList.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CLogModel *msg=[self.logList safeObjectAtIndex:indexPath.row];
    NSString *timeStr = [msg.time formattedDateWithFormatString:@"MM-dd HH:mm:ss.SSS"];
    if (msg.bExpand) {
        NSString *logStr = [NSString stringWithFormat:@" Ⓘ %@ | %@ - %@:%@ | %@",timeStr,msg.fileName,msg.function,@(msg.line),msg.msg];
        CGSize size = [logStr adjustSizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(tableView.bounds.size.width, MAXFLOAT)];
        return size.height + 20.0;
    }
    else{
        return 20.0;
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
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    CLogModel *msg=[self.logList safeObjectAtIndex:indexPath.row];
    msg.bExpand=!msg.bExpand;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
