//
//  ScanViewController.m
//  LCW
//
//  Created by Li XiangCheng on 13-1-25.
//  Copyright (c) 2013年 Li XiangCheng. All rights reserved.
//

#import "ScanViewController.h"
#import "ZBarSDK.h"

@interface ScanViewController ()<UIPopoverControllerDelegate,ZBarReaderViewDelegate,ZBarReaderDelegate>{
    ZBarCameraSimulator *_cameraSim;
    
    BOOL _bCrossMoveIng;
    
    UIPopoverController *_popover;
    
    NSString *_scanCode;
}

@property (nonatomic, weak) IBOutlet UIView *mask_top_View;
@property (nonatomic, weak) IBOutlet UIView *mask_bottom_View;
@property (nonatomic, weak) IBOutlet UIView *mask_left_View;
@property (nonatomic, weak) IBOutlet UIView *mask_right_View;
@property (nonatomic, weak) IBOutlet UIImageView *scan_target_IV;
@property (nonatomic, weak) IBOutlet UIImageView *scroll_across_IV;
@property (nonatomic, weak) IBOutlet UILabel *tipLabel;
@property (nonatomic, weak) IBOutlet ZBarReaderView *readerView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *topConstraint;

- (void)showAnimateaCrossMove;//展现扫描光标图循环移动的动画
- (void)scanBtn;

@end

@implementation ScanViewController

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _scanCode=@"";
    }
    return self;
}

- (void) cleanup{
    _cameraSim = nil;
    _readerView.readerDelegate = nil;
    _readerView = nil;
}

- (void) dealloc{
    [self cleanup];
}

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.title = @"扫描二维码";
    
//    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]
//                                             initWithTitle:@"扫描"
//                                             style:UIBarButtonItemStylePlain
//                                             target:self
//                                             action:@selector(scanBtn)]];
    
    [_mask_top_View setBackgroundColor:[[UIColor alloc] initWithCGColor:[[UIColor colorWithPatternImage:[UIImage imageNamed:@"scan-mask-bg"]] CGColor]]];
    //In iOS4.3, UIView's background color setting with UIImage could not be transparent
    [_mask_top_View.layer setOpaque:NO];
    _mask_top_View.opaque = NO;
    [_mask_bottom_View setBackgroundColor:[[UIColor alloc] initWithCGColor:[[UIColor colorWithPatternImage:[UIImage imageNamed:@"scan-mask-bg"]] CGColor]]];
    [_mask_bottom_View.layer setOpaque:NO];
    _mask_bottom_View.opaque = NO;
    [_mask_left_View setBackgroundColor:[[UIColor alloc] initWithCGColor:[[UIColor colorWithPatternImage:[UIImage imageNamed:@"scan-mask-bg"]] CGColor]]];
    [_mask_left_View.layer setOpaque:NO];
    _mask_left_View.opaque = NO;
    [_mask_right_View setBackgroundColor:[[UIColor alloc] initWithCGColor:[[UIColor colorWithPatternImage:[UIImage imageNamed:@"scan-mask-bg"]] CGColor]]];
    [_mask_right_View.layer setOpaque:NO];
    _mask_right_View.opaque = NO;
    
    _scroll_across_IV.image=[UIImage imageNamed:UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone?@"scan-scroll-across":@"scan-scroll-across-pad"];
    
    // the delegate receives decode results
    _readerView.readerDelegate = self;
    
    // turn down the flash
    _readerView.torchMode = 0;
    
    //More param
    //_readerView.trackingColor=[UIColor greenColor];
    //_readerView.showsFPS = YES;//show FPS
    //_readerView.zoom = zoom;
    
    // you can use this to support the simulator
    if(TARGET_IPHONE_SIMULATOR) {
        _cameraSim = [[ZBarCameraSimulator alloc]
                     initWithViewController: self];
        _cameraSim.readerView = _readerView;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear: (BOOL) animated{
    [super viewDidAppear:animated];
    
    // run the reader when the view is visible
    [_readerView start];
    
    if (!_bCrossMoveIng) {
        _bCrossMoveIng=TRUE;
        //展现扫描光标图循环移动的动画
        [self performSelector:@selector(showAnimateaCrossMove) withObject:nil afterDelay:0.0];
    }
}

- (void)viewWillDisappear: (BOOL) animated{
    [_readerView stop];
    _bCrossMoveIng=FALSE;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    //return YES;
}

- (void)willRotateToInterfaceOrientation: (UIInterfaceOrientation) orient
                                 duration: (NSTimeInterval) duration{
    // compensate for view rotation so camera preview is not rotated
    [_readerView willRotateToInterfaceOrientation: orient
                                        duration: duration];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Custom Animation

//展现扫描光标图循环移动的动画
- (void)showAnimateaCrossMove{
    if (!_bCrossMoveIng) {
        return;
    }
    //move
    _topConstraint.constant = 138;
    [self.view layoutIfNeeded];
    
    [UIView beginAnimations:@"Cross_Move_View" context:NULL];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(didStop:finished:context:)];
    [UIView setAnimationDuration:2.5];
    _topConstraint.constant=_scan_target_IV.frame.origin.y+_scan_target_IV.frame.size.height-16;
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

#pragma mark Animation

- (void)didStart:(NSString *)animationId context:(void *)context {
}

- (void)didStop:(NSString *)animationId finished:(BOOL)flag context:(void *)context {
    if (!_bCrossMoveIng) {
        return;
    }
    
    if ([animationId isEqualToString:@"Cross_Move_View"] && [[self navigationController] topViewController] == self) {
        [UIView beginAnimations:@"Cross_Hidden_View" context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(didStop:finished:context:)];
        [UIView setAnimationDuration:0.5f];
        _scroll_across_IV.alpha=0.0;
        [UIView commitAnimations];
    }
    if ([animationId isEqualToString:@"Cross_Hidden_View"] && [[self navigationController] topViewController] == self) {
        _topConstraint.constant = _scan_target_IV.frame.origin.y-6;
        [self.view layoutIfNeeded];
        [UIView beginAnimations:@"Cross_Show_View" context:NULL];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(didStop:finished:context:)];
        [UIView setAnimationDuration:0.5f];
        _scroll_across_IV.alpha=1.0;
        [UIView commitAnimations];
    }
    if ([animationId isEqualToString:@"Cross_Show_View"] && [[self navigationController] topViewController] == self) {
        [self showAnimateaCrossMove];
    }
}

#pragma mark Action

- (void)scanBtn{
    WEAKSELF
    [UIAlertController showWithTitle:nil
                             message:nil
                   cancelButtonTitle:NSLocalizedString(@"取消",nil)
                  defultButton1Title:NSLocalizedString(@"拍照",nil)
                  defultButton2Title:NSLocalizedString(@"从相册选取",nil)
              destructiveButtonTitle:nil
                            onCancel:^(UIAlertAction *action) {
                            }
                           onDefult1:^(UIAlertAction *action) {
                               if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
                                   [weakSelf scan:TRUE];
                               } else {
                                   [weakSelf scan:FALSE];
                               }
                           }
                           onDefult2:^(UIAlertAction *action) {
                               [weakSelf scan:FALSE];
                           }
                       onDestructive:^(UIAlertAction *action) {
                       }
                          sourceView:(UIView *)self.navigationItem.rightBarButtonItem];
}

- (void)scan:(Boolean)IsSourceTypeCamera{
    if (IsSourceTypeCamera) {//拍照
        ZBarReaderViewController *reader = [ZBarReaderViewController new];
        reader.readerDelegate = self;
        reader.sourceType = UIImagePickerControllerSourceTypeCamera;
        reader.cameraMode = ZBarReaderControllerCameraModeSampling;
        reader.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        reader.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        reader.videoQuality = UIImagePickerControllerQualityTypeMedium;
        
        ZBarImageScanner *scanner = reader.scanner;
        // TODO: (optional) additional reader configuration here
        
        // EXAMPLE: disable rarely used I2/5 to improve performance
        [scanner setSymbology: ZBAR_I25
                       config: ZBAR_CFG_ENABLE
                           to: 0];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {//iphone
            // present and release the controller
            [self presentViewController:reader animated:YES completion:nil];
        }
        else{//ipad
            _popover=nil;
            _popover = [[UIPopoverController alloc] initWithContentViewController:reader];
            _popover.delegate=self;
            //[popover presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [_popover presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                }];
            }
            else{
                [_popover presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }
        }
    }
    else{//从相册选取
        ZBarReaderController *reader = [ZBarReaderController new];
        reader.readerDelegate = self;
        reader.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        ZBarImageScanner *scanner = reader.scanner;
        // TODO: (optional) additional reader configuration here
        
        // EXAMPLE: disable rarely used I2/5 to improve performance
        [scanner setSymbology: ZBAR_I25
                       config: ZBAR_CFG_ENABLE
                           to: 0];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {//iphone
            // present and release the controller
            [self presentViewController:reader animated:YES completion:nil];
        }
        else{//ipad
            _popover=nil;
            _popover = [[UIPopoverController alloc] initWithContentViewController:reader];
            _popover.delegate=self;
            //[popover presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [_popover presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                }];
            }
            else{
                [_popover presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem  permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }
        }
    }
    
}

#pragma mark UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self.navigationItem.rightBarButtonItem.enabled=TRUE;
}

#pragma mark ZBarReaderViewDelegate

- (void) readerView:(ZBarReaderView*)view didReadSymbols:(ZBarSymbolSet*)syms fromImage:(UIImage*)img
{
    [[SoundManager shareInstance] playSoundEffectsWithID:AUDIOEFFECT_beep];
    
    // do something useful with results
    for(ZBarSymbol *sym in syms) {
        NSLog(@"%@",[NSString stringWithFormat:@"typeName:%@ data:%@",sym.typeName,sym.data]);
        NSString *scanCode=sym.data.lowercaseString;//http://www.rrlt.com/resume/preview_wap?jkey=***&rid=***&from=singlemessage&isappinstalled=1&uid=123456
        if ([scanCode hasPrefix:@"http://www.rrlt.com/resume/preview_wap"]) {
            [_readerView stop];
            _bCrossMoveIng=FALSE;
            
            NSDictionary *params=[scanCode queryDictionaryUsingEncoding:NSUTF8StringEncoding];
            //roster.roster_user_id=[RKMapping([params valueForKey:@"uid"]) integerValue];
        }
        else{
            [_readerView stop];
            _bCrossMoveIng=FALSE;
            
            _scanCode=[[NSString alloc]initWithString:scanCode];
            
            [UIAlertController showWithTitle:@"提示"
                                     message:@"你扫描的二维码为外部链接，是否继续访问？"
                           cancelButtonTitle:NSLocalizedString(@"取消", nil)
                           defultButtonTitle:NSLocalizedString(@"确定",nil)
                      destructiveButtonTitle:nil
                                    onCancel:^(UIAlertAction *action) {
                                        [_readerView start];
                                        if (!_bCrossMoveIng) {
                                            _bCrossMoveIng=TRUE;
                                            //展现扫描光标图循环移动的动画
                                            [self showAnimateaCrossMove];
                                        }
                                    }
                                    onDefult:^(UIAlertAction *action) {
                                        [_readerView start];
                                        if (!_bCrossMoveIng) {
                                            _bCrossMoveIng=TRUE;
                                            //展现扫描光标图循环移动的动画
                                            [self showAnimateaCrossMove];
                                        }
                                        
                                        //打开_scanCode
                                        NSString *urlStr=[_scanCode stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
                                        SVWebViewController *sv = [[SVWebViewController alloc] initWithURL:[NSURL URLWithString:urlStr]];
                                        [sv setTitle:urlStr];
                                        sv.hidesBottomBarWhenPushed=YES;
                                        [self.navigationController pushViewController:sv animated:YES];
                                    }
                               onDestructive:nil];
        }
        break;
    }
}

#pragma mark ZBarReaderDelegate

- (void) imagePickerController: (UIImagePickerController*) reader didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results = [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
    
    // EXAMPLE: do something useful with the barcode data
    NSLog(@"%@",[NSString stringWithFormat:@"typeName:%@ data:%@",symbol.typeName,symbol.data]);
    
    // EXAMPLE: do something useful with the barcode image
    //resultImage.image =[info objectForKey: UIImagePickerControllerOriginalImage];
    
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {//iphone
        [reader dismissViewControllerAnimated:YES completion:nil];
    }
    else{//ipad
        [_popover dismissPopoverAnimated:NO];
    }
}

- (void) imagePickerControllerDidCancel: (UIImagePickerController*) picker
{
    NSLog(@"imagePickerControllerDidCancel:\n");
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {//iphone
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    else{//ipad
        [_popover dismissPopoverAnimated:NO];
    }
}

- (void) readerControllerDidFailToRead: (ZBarReaderController*) _reader
                             withRetry: (BOOL) retry
{
    NSLog(@"readerControllerDidFailToRead: retry=%s\n",(retry) ? "YES" : "NO");
    if(!retry){
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {//iphone
            [_reader dismissViewControllerAnimated:YES completion:nil];
        }
        else{//ipad
            [_popover dismissPopoverAnimated:NO];
        }
    }
}

@end

