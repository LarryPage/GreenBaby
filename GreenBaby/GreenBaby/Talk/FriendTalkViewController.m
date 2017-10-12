//
//  FriendTalkViewController.m
//  Hunt
//
//  Created by LiXiangCheng on 14/12/26.
//  Copyright (c) 2014年 LiXiangCheng. All rights reserved.
//

#import "FriendTalkViewController.h"
#import "ChatTableView.h"
#import "ChatCell.h"

#import "XHMessageInputView.h"
#import "XHFaceManagerView.h"
#import "XHShareMenuView.h"
#define KeyboardHeight IS_IPAD?264:216

//#import "UserDetailViewController.h"

#define KMaxPicCount 9

@interface FriendTalkViewController ()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,XHMessageInputViewDelegate,XHFaceManagerViewDelegate,XHShareMenuViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
}
@property (nonatomic, assign) int statusCode;//接口返回状态:0-请求中，1-正常返回，-1-网络异常
@property (nonatomic, assign) int pagecount;//每页数
@property (nonatomic, assign) int loadingOld;//加载状态
@property (nonatomic, strong) MessageDetail *msg;
@property (nonatomic, weak)   IBOutlet ChatTableView *resultTable;
//@property (nonatomic, strong) NSMutableArray *searchList;//搜索结果:[MessageDetail]
@property (nonatomic, strong) NSMutableDictionary *mlEmojLabels;//{key,MLEmojiLabel}
@property (nonatomic, strong) UIImage* editImage;
@property (nonatomic, strong) NSMutableArray *uploadPics;//[{pic_url,width,height}]

@property (nonatomic, strong) XHMessageInputView *messageInputView;
@property (nonatomic, strong) XHFaceManagerView *faceManagerView;
@property (nonatomic, strong) XHShareMenuView *shareMenuView;
/**
 *  记录旧的textView contentSize Heigth
 */
@property (nonatomic, assign) CGFloat previousTextViewContentHeight;
/**
 *  记录键盘的高度，为了适配iPad和iPhone
 */
@property (nonatomic, assign) CGFloat keyboardViewHeight;
@property (nonatomic, assign) XHInputViewType textViewInputViewType;

//下拉更新
- (void) loadOldDataBegin;
- (void) loadOldDataing:(NSMutableArray *)moreList;
- (void) loadOldDataEnd;
//向下paging
// 加载数据中
- (void) loadNewDataing:(NSMutableArray *)moreList;
@end

@implementation FriendTalkViewController

#pragma mark - custom Notification

- (void)keyboardWillShow:(NSNotification *)notif {
    [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGRect frame = self.messageInputView.frame;
        frame.origin.y = self.view.frame.size.height - self.keyboardViewHeight-frame.size.height;
        self.messageInputView.frame = frame;
        
        [self setTableViewInsetsWithBottomValue:self.view.frame.size.height - self.messageInputView.frame.origin.y];
        [self scrollToBottomAnimated:YES];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillHide:(NSNotification *)notif {
    if (self.textViewInputViewType == XHInputViewTypeText) {
        [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            CGRect frame = self.messageInputView.frame;
            frame.origin.y = self.view.frame.size.height - frame.size.height;
            self.messageInputView.frame = frame;
            
            [self setTableViewInsetsWithBottomValue:self.view.frame.size.height - self.messageInputView.frame.origin.y];
            [self scrollToBottomAnimated:YES];
        } completion:^(BOOL finished) {
            
        }];
    }
}

#pragma mark - UITextInputCurrentInputModeDidChangeNotification
-(void) changeMode:(NSNotification *)notification{
    //UITextInputMode *current = [[UITextInputMode activeInputModes] firstObject];
    
    //    2011-07-18 14:32:48.565 UIFont[2447:207] zh-Hans //简体汉字拼音
    //    2011-07-18 14:32:50.784 UIFont[2447:207] en-US   //英文
    //    2011-07-18 14:32:51.344 UIFont[2447:207] zh-Hans //简体手写
    //    2011-07-18 14:32:51.807 UIFont[2447:207] zh-Hans //简体笔画
    //    2011-07-18 14:32:53.271 UIFont[2447:207] zh-Hant //繁体手写
    //    2011-07-18 14:32:54.062 UIFont[2447:207] zh-Hant //繁体仓颉
    //    2011-07-18 14:32:54.822 UIFont[2447:207] zh-Hant //繁体笔画
    
}

#pragma mark - UIKeyboardWillChangeFrameNotification
- (void)keyboardFrameWillChange:(NSNotification*)notification{
    if (self.textViewInputViewType == XHInputViewTypeText) {
        CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        self.keyboardViewHeight=keyboardRect.size.height;
    }
    else{
        self.keyboardViewHeight=KeyboardHeight;
    }
}

- (void)keyboardFrameDidChange:(NSNotification*)notification{
    if ([self.messageInputView.inputTextView isFirstResponder]) {
        if (self.textViewInputViewType == XHInputViewTypeText) {
            self.faceManagerView.alpha = 0.0;
            self.shareMenuView.alpha = 0.0;
        }
    }
}

#pragma mark - View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithMsg:(MessageDetail *)msg{
    if (self = [super initWithNibName:@"FriendTalkViewController" bundle:nil]) {
        self.msg = msg;
        
        self.searchList = [NSMutableArray array];
        self.mlEmojLabels = [NSMutableDictionary dictionary];
        self.uploadPics = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_resultTable setEditing:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UserInfo *user = [UserInfo loadCurRecord];
    NSString *fromname=(user.user_id==_msg.fromuid)?_msg.touname:_msg.fromuname;
    self.title=fromname;
    //right bar
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 44, 44);
    [rightBtn setImage:[UIImage imageNamed:@"Btn_Action"] forState:UIControlStateNormal];
    [rightBtn setImage:[UIImage imageNamed:@"Btn_Action_hl"] forState:UIControlStateHighlighted];
    [rightBtn addTarget:self action:@selector(rightBtn:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    
    UIBarButtonItem *rightSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    rightSeperator.width = -20;//此处修改到边界的距离，请自行测试
    [self.navigationItem setRightBarButtonItems:@[rightSeperator, rightBarItem]];
    
    //ios7
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        //self.automaticallyAdjustsScrollViewInsets=NO;//ios7 deltas for resultTable
    }
    
    WEAKSELF
    [self.resultTable addActionHandler:^{
        [weakSelf hideInputView];
    }];
    
    self.pagecount=UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone?10:20;
    //[self performSelector:@selector(getMessage:) withObject:@"news" afterDelay:0.0];

    self.keyboardViewHeight=KeyboardHeight;
    self.textViewInputViewType=XHInputViewTypeNormal;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:self.view.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:self.view.window];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMode:) name:UITextInputCurrentInputModeDidChangeNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameDidChange:) name:UIKeyboardDidChangeFrameNotification object:nil];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    if (!self.messageInputView) {
        CGFloat inputViewHeight = ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) ? 45.0f : 40.0f;//XHMessageInputViewStyleFlat
        // 设置TableView 的bottom edg
        [self setTableViewInsetsWithBottomValue:inputViewHeight];
        
        CGRect inputFrame = CGRectMake(0.0f,
                                       self.view.frame.size.height - inputViewHeight,
                                       self.view.frame.size.width,
                                       inputViewHeight);
        
        // 初始化输入工具条
        _messageInputView = [[XHMessageInputView alloc] initWithFrame:inputFrame];
        _messageInputView.allowsSendFace = YES;
        _messageInputView.allowsSendMultiMedia = YES;
        _messageInputView.delegate = self;
        [self.view insertSubview:_messageInputView aboveSubview:self.resultTable];
        _messageInputView.inputTextView.text=@"";
        _messageInputView.inputTextView.tag=0;
        _messageInputView.inputTextView.placeHolder = @"输入新消息";
        
        self.previousTextViewContentHeight = [self getTextViewContentH:_messageInputView.inputTextView];
    }
    
    // KVO 检查contentSize
    [self.messageInputView.inputTextView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    
    //启动轮循
    [self performSelector:@selector(getMessage:) withObject:@"news" afterDelay:0.0];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 取消输入框
    [self.messageInputView.inputTextView resignFirstResponder];
    [self.resultTable setEditing:NO animated:YES];
    
    // remove KVO
    [self.messageInputView.inputTextView removeObserver:self forKeyPath:@"contentSize"];
    
//    if ([self.searchList count]>0) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:MessageDidReceive object:nil userInfo:nil];
//    }
    
    //取消轮循
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getMessage:) object:@"news"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Scroll Message TableView Helper Method

- (void)setTableViewInsetsWithBottomValue:(CGFloat)bottom {
    UIEdgeInsets insets = [self tableViewInsetsWithBottomValue:bottom];
    self.resultTable.contentInset = insets;
    self.resultTable.scrollIndicatorInsets = insets;
}

- (UIEdgeInsets)tableViewInsetsWithBottomValue:(CGFloat)bottom {
    UIEdgeInsets insets = UIEdgeInsetsZero;
    
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        insets.top = 64;
    }
    
    insets.bottom = bottom;
    
    return insets;
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    //滚动最后一条
    if (self.searchList && [self.searchList count]>0) {
        NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:[self.searchList count]-1 inSection:0];
        [self.resultTable scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

#pragma mark - Key-value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (object == self.messageInputView.inputTextView && [keyPath isEqualToString:@"contentSize"]) {
        [self layoutAndAnimateMessageInputTextView:object];
    }
}

- (void)layoutAndAnimateMessageInputTextView:(UITextView *)textView {
    CGFloat maxHeight = [XHMessageInputView maxHeight];
    
    CGFloat contentH = [self getTextViewContentH:textView];
    
    BOOL isShrinking = contentH < self.previousTextViewContentHeight;
    CGFloat changeInHeight = contentH - _previousTextViewContentHeight;
    
    if (!isShrinking && (self.previousTextViewContentHeight == maxHeight || textView.text.length == 0)) {
        changeInHeight = 0;
    }
    else {
        changeInHeight = MIN(changeInHeight, maxHeight - self.previousTextViewContentHeight);
    }
    
    if (changeInHeight != 0.0f) {
        [UIView animateWithDuration:0.25f
                         animations:^{
                             [self setTableViewInsetsWithBottomValue:self.resultTable.contentInset.bottom + changeInHeight];
                             [self scrollToBottomAnimated:NO];
                             
                             if (isShrinking) {
                                 if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
                                     self.previousTextViewContentHeight = MIN(contentH, maxHeight);
                                 }
                                 // if shrinking the view, animate text view frame BEFORE input view frame
                                 [self.messageInputView adjustTextViewHeightBy:changeInHeight];
                             }
                             
                             CGRect inputViewFrame = self.messageInputView.frame;
                             self.messageInputView.frame = CGRectMake(0.0f,
                                                                      inputViewFrame.origin.y - changeInHeight,
                                                                      inputViewFrame.size.width,
                                                                      inputViewFrame.size.height + changeInHeight);
                             if (!isShrinking) {
                                 if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
                                     self.previousTextViewContentHeight = MIN(contentH, maxHeight);
                                 }
                                 // growing the view, animate the text view frame AFTER input view frame
                                 [self.messageInputView adjustTextViewHeightBy:changeInHeight];
                             }
                         }
                         completion:^(BOOL finished) {
                         }];
        
        self.previousTextViewContentHeight = MIN(contentH, maxHeight);
    }
    
    // Once we reached the max height, we have to consider the bottom offset for the text view.
    // To make visible the last line, again we have to set the content offset.
    if (self.previousTextViewContentHeight == maxHeight) {
        double delayInSeconds = 0.01;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime,
                       dispatch_get_main_queue(),
                       ^(void) {
                           CGPoint bottomOffset = CGPointMake(0.0f, contentH - textView.bounds.size.height);
                           [textView setContentOffset:bottomOffset animated:YES];
                       });
    }
}

#pragma mark - MessageInputView

- (XHFaceManagerView *)faceManagerView {
    if (!_faceManagerView) {
        XHFaceManagerView *faceManagerView = [[XHFaceManagerView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight([[UIScreen mainScreen] bounds]), CGRectGetWidth([[UIScreen mainScreen] bounds]), KeyboardHeight)];
        faceManagerView.delegate = self;
        faceManagerView.backgroundColor = [UIColor whiteColor];
        faceManagerView.alpha = 0.0;
        faceManagerView.faceMap = [Configs faceMap];
        [self.view insertSubview:faceManagerView aboveSubview:self.resultTable];
        _faceManagerView = faceManagerView;
    }
    return _faceManagerView;
}

- (XHShareMenuView *)shareMenuView {
    if (!_shareMenuView) {
        NSMutableArray *shareMenuItems=[NSMutableArray array];
        XHShareMenuItem *record1=[[XHShareMenuItem alloc] initWithNormalIconImage:[UIImage imageNamed:@"More_photo"] title:@"照片"];
        XHShareMenuItem *record2=[[XHShareMenuItem alloc] initWithNormalIconImage:[UIImage imageNamed:@"More_camera"] title:@"拍照"];
        [shareMenuItems addObject:record1];
        [shareMenuItems addObject:record2];
        
        CGFloat height=KeyboardHeight;
        if (shareMenuItems.count>kXHShareMenuPerRowItemCount*kXHShareMenuPerColum) {
            height = (10+KXHShareMenuItemHeight)*kXHShareMenuPerColum+kXHShareMenuPageControlHeight;
        }
        else if (shareMenuItems.count>kXHShareMenuPerRowItemCount) {
            height = (10+KXHShareMenuItemHeight)*kXHShareMenuPerColum+10;
        }
        else{
            height = 10+KXHShareMenuItemHeight+10;
        }
        
        XHShareMenuView *shareMenuView = [[XHShareMenuView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight([[UIScreen mainScreen] bounds]), CGRectGetWidth([[UIScreen mainScreen] bounds]), height)];
        shareMenuView.delegate = self;
        shareMenuView.backgroundColor = [UIColor whiteColor];
        shareMenuView.alpha = 0.0;
        
        shareMenuView.shareMenuItems = shareMenuItems;
        [self.view insertSubview:shareMenuView aboveSubview:self.resultTable];
        _shareMenuView = shareMenuView;
    }
    return _shareMenuView;
}

- (CGFloat)getTextViewContentH:(UITextView *)textView {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        return ceilf([textView sizeThatFits:textView.frame.size].height);
    } else {
        return textView.contentSize.height;
    }
}

- (void)layoutOtherMenuViewHiden:(BOOL)hide {
    [self.messageInputView.inputTextView resignFirstResponder];
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        __block CGRect inputViewFrame = self.messageInputView.frame;
        __block CGRect otherMenuViewFrame;
        
        void (^InputViewAnimation)(BOOL hide) = ^(BOOL hide) {
            inputViewFrame.origin.y = (hide ? (CGRectGetHeight(self.view.bounds) - CGRectGetHeight(inputViewFrame)) : (CGRectGetMinY(otherMenuViewFrame) - CGRectGetHeight(inputViewFrame)));
            self.messageInputView.frame = inputViewFrame;
        };
        
        void (^FaceManagerViewAnimation)(BOOL hide) = ^(BOOL hide) {
            otherMenuViewFrame = self.faceManagerView.frame;
            otherMenuViewFrame.origin.y = (hide ? CGRectGetHeight(self.view.frame) : (CGRectGetHeight(self.view.frame) - CGRectGetHeight(otherMenuViewFrame)));
            self.faceManagerView.alpha = !hide;
            self.faceManagerView.frame = otherMenuViewFrame;
        };
        
        void (^ShareMenuViewAnimation)(BOOL hide) = ^(BOOL hide) {
            otherMenuViewFrame = self.shareMenuView.frame;
            otherMenuViewFrame.origin.y = (hide ? CGRectGetHeight(self.view.frame) : (CGRectGetHeight(self.view.frame) - CGRectGetHeight(otherMenuViewFrame)));
            self.shareMenuView.alpha = !hide;
            self.shareMenuView.frame = otherMenuViewFrame;
        };
        
        if (hide) {
            switch (self.textViewInputViewType) {
                case XHInputViewTypeFace: {
                    FaceManagerViewAnimation(hide);
                    break;
                }
                case XHInputViewTypeShareMenu: {
                    ShareMenuViewAnimation(hide);
                    break;
                }
                default:
                    break;
            }
        } else {
            
            // 这里需要注意block的执行顺序，因为otherMenuViewFrame是公用的对象，所以对于被隐藏的Menu的frame的origin的y会是最大值
            switch (self.textViewInputViewType) {
                case XHInputViewTypeFace: {
                    // 1、先隐藏和自己无关的View
                    ShareMenuViewAnimation(!hide);
                    // 2、再显示和自己相关的View
                    FaceManagerViewAnimation(hide);
                    break;
                }
                case XHInputViewTypeShareMenu: {
                    // 1、先隐藏和自己无关的View
                    FaceManagerViewAnimation(!hide);
                    // 2、再显示和自己相关的View
                    ShareMenuViewAnimation(hide);
                    break;
                }
                default:
                    break;
            }
        }
        
        InputViewAnimation(hide);
        
        [self setTableViewInsetsWithBottomValue:self.view.frame.size.height - self.messageInputView.frame.origin.y];
        [self scrollToBottomAnimated:NO];
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - XHMessageInputViewDelegate

- (void)inputTextViewWillBeginEditing:(XHMessageTextView *)messageInputTextView{
    self.textViewInputViewType = XHInputViewTypeText;
    if (!self.previousTextViewContentHeight)
        self.previousTextViewContentHeight = [self getTextViewContentH:messageInputTextView];
}

- (BOOL)inputTextView:(XHMessageTextView *)messageInputTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSString *newText = [messageInputTextView.text stringByReplacingCharactersInRange:range withString:text];
    if (messageInputTextView.text.length>newText.length) {//del
        //[self deleteFace];
        return YES;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    _faceManagerView.sendBtn.enabled=textView.text.length>0;
}

- (void)didSendTextAction:(NSString *)text{
    if (text.length>0) {
        //1.将表情替换，计算字数
        /*
         __block NSString *tmp=[text copy];
         NSDictionary *faceMap=[Configs faceMap];
         [[faceMap allKeys] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
         NSString *key=(NSString *)obj;
         tmp=[tmp stringByReplacingOccurrencesOfString:key withString:[NSString stringWithFormat:@"%C",kEmojiReplaceCharacter]];
         }];
         */
        //2.用正则表达式，计算字数
        NSString *tmp=[text copy];
        NSString *customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
        NSRegularExpression *customEmojiRegularExpression = [[NSRegularExpression alloc] initWithPattern:customEmojiRegex options:NSRegularExpressionCaseInsensitive error:nil];
        NSArray *emojis = [customEmojiRegularExpression matchesInString:text
                                                                options:NSMatchingWithTransparentBounds
                                                                  range:NSMakeRange(0, [text length])];
        NSArray *keys=[[Configs faceMap] allKeys];
        for (NSTextCheckingResult *result in emojis) {
            NSString *emojiKey = [text substringWithRange:result.range];
            NSInteger idx=[keys indexOfObject:emojiKey];
            if (idx!=NSNotFound) {
                tmp=[tmp stringByReplacingOccurrencesOfString:emojiKey withString:[NSString stringWithFormat:@"%C",kEmojiReplaceCharacter]];
            }
        }
        
        if (tmp.length>140) {
            [UIAlertController alert:@"最多140个字以内!" title:@"提示" bTitle:@"确定"];
        }
        else{
            [self showHudInView:self.view hint:@"请稍等..."];//显示
            NSDictionary *msgDic=[NSDictionary dictionaryWithObjectsAndKeys:@(1), @"msg_type", text, @"msg_content", nil];
            [self sendMessage:msgDic];//发送消息
        }
    }
}

- (void)didSendFaceAction:(BOOL)sendFace{
    if (sendFace) {
        self.textViewInputViewType = XHInputViewTypeFace;
        [self layoutOtherMenuViewHiden:NO];
    } else {
        [self.messageInputView.inputTextView becomeFirstResponder];
    }
}

- (void)didSelectedMultipleMediaAction{
    if (self.textViewInputViewType != XHInputViewTypeShareMenu) {
        self.textViewInputViewType = XHInputViewTypeShareMenu;
        [self layoutOtherMenuViewHiden:NO];
    }
    else{
        [self.messageInputView.inputTextView becomeFirstResponder];
    }
    
//    NSString *inputString=self.messageInputView.inputTextView.text;
//    if (inputString && inputString.length>0) {
//        [self didSend];
//    }
//    else{
//        [[TKAlertCenter defaultCenter] postAlertWithMessage:@"不能发送空消息"];
//    }
//    [self.messageInputView.inputTextView becomeFirstResponder];
    
}

#pragma mark - XHFaceManagerViewDelegate

- (void)didSelecteFace:(NSString *)faceName{
    NSMutableString *inputString = [[NSMutableString alloc]initWithString:self.messageInputView.inputTextView.text];
    [inputString appendString:faceName];
    self.messageInputView.inputTextView.text=inputString;
    
    _faceManagerView.sendBtn.enabled=self.messageInputView.inputTextView.text.length>0;
}

- (void)deleteFace{
    NSString *inputString=self.messageInputView.inputTextView.text;
    NSString *string = nil;
    NSInteger stringLength = inputString.length;
    if (stringLength > 0) {
        if ([@"]" isEqualToString:[inputString substringFromIndex:stringLength-1]]) {
            NSRange range = [inputString rangeOfString:@"[" options:NSBackwardsSearch];
            if (range.location == NSNotFound) {
                string = [inputString substringToIndex:stringLength - 1];
            }
            else{
                NSString *text= [inputString substringFromIndex:range.location];//[难过]
                if ([[self.faceManagerView.faceMap allKeys] indexOfObject:text]==NSNotFound) {
                    string = [inputString substringToIndex:stringLength - 1];
                }
                else{
                    string = [inputString substringToIndex:range.location];
                }
            }
        } else {
            string = [inputString substringToIndex:stringLength - 1];
        }
    }
    self.messageInputView.inputTextView.text=string;
    
    _faceManagerView.sendBtn.enabled=self.messageInputView.inputTextView.text.length>0;
}

- (void)didSend{
    NSString *inputString=self.messageInputView.inputTextView.text;
    [self didSendTextAction:inputString];
}

#pragma mark - XHShareMenuViewDelegate

- (void)didSelecteShareMenuItem:(XHShareMenuItem *)shareMenuItem atIndex:(NSInteger)index{
    switch (index) {
        case 0://照片
        {
            MLSelectPhotoPickerViewController *picker = [[MLSelectPhotoPickerViewController alloc] init];
            //picker.selectPickers = self.selections;
            picker.maxCount = KMaxPicCount;
            picker.doneText = @"发送";
            picker.status = PickerViewShowStatusCameraRoll;
            [picker showPickerVc:self];
            WEAKSELF
            picker.callBack = ^(NSArray *assets){
                [weakSelf showHudInView:weakSelf.view hint:@""];//显示
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [weakSelf.uploadPics removeAllObjects];
                    for (int i=0; i<assets.count; i++) {
                        MLSelectPhotoAssets *asset = assets[i];
                        UIImage *image = [asset originImage];
                        //NSLog(@"image==%f==%f==%@",image.size.width,image.size.height,image.contentType);
                        weakSelf.editImage = [image compressedImage:CGSizeMake(750, 750)] ;//PNG
                        //NSLog(@"image==%f==%f==%@",weakSelf.editImage.size.width,weakSelf.editImage.size.height,weakSelf.editImage.contentType);
                        if (weakSelf.editImage) {
                            //保存本地
                            //[weakSelf saveImage:weakSelf.editImage];
                            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                            [formatter setDateFormat: @"yyyyMMdd"];
                            [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
                            NSString *timeDesc = [formatter stringFromDate:[NSDate date]];
                            double timeInterval = [[[NSDate alloc] init] timeIntervalSinceReferenceDate]*1000000;
                            NSString *pic_url=[NSString stringWithFormat:@"img%@%.0f_%@_%@",timeDesc,timeInterval+i,@((int)weakSelf.editImage.size.width),@((int)weakSelf.editImage.size.height)];
                            
                            NSString* filePath = [kCachesFolder stringByAppendingPathComponent:pic_url];
                            NSFileManager *fileManager = [NSFileManager defaultManager];
                            BOOL bFileExisted = [fileManager fileExistsAtPath:filePath ];
                            if(bFileExisted)
                            {
                                [fileManager removeItemAtPath:filePath error:nil];
                            }
                            //NSData* pImageData = UIImagePNGRepresentation(pImage);
                            //再次质量压缩
                            NSData* pImageData = [weakSelf.editImage compressedData];
                            [pImageData writeToFile:filePath atomically:YES];
                            
                            NSMutableDictionary *dic=[NSMutableDictionary dictionary];
                            [dic setValue:pic_url forKey:@"pic_url"];
                            [dic setObject:[NSNumber numberWithInt:(int)weakSelf.editImage.size.width] forKey:@"width"];
                            [dic setObject:[NSNumber numberWithInt:(int)weakSelf.editImage.size.height] forKey:@"height"];
                            [weakSelf.uploadPics addObject:dic];
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //更改UI
                        //先上传图片后发送消息
                        [weakSelf uploadPic:weakSelf.uploadPics[0]];
                    });
                });
            };
        }
            break;
        case 1://拍照
        {
            UIImagePickerController *pick = [[UIImagePickerController alloc] init];
            pick.delegate = self;
            pick.view.tag=100;
            
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
                pick.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            } else {
                pick.sourceType = UIImagePickerControllerSourceTypeCamera;
                pick.showsCameraControls = YES;
                //pick.wantsFullScreenLayout = YES;//6.0
                pick.edgesForExtendedLayout=UIRectEdgeNone;//7.0
                pick.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
            }
            pick.allowsEditing = NO;
            pick.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                [self setNavigationBarAttribute:pick.navigationBar];
                [self presentViewController:pick animated:YES completion:nil];
            }
            else{
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:pick animated:YES completion:nil];
            }
        }
            break;
//        case 2://职位
//        {
//            UserInfo *user = [UserInfo loadCurRecord];
//            Roster *roster=[Roster rosterWithDictionary:[myInfo myInfoDic]];
//            
//            UIViewController *vc = [[HPositionListViewController alloc] initWithCompletion:^(Position *position){
//                NSDictionary *msgDic=[NSDictionary dictionaryWithObjectsAndKeys:@"pos", @"msg_type", @(position.positionid), @"msg_content", nil];
//                [self sendMessage:msgDic];//发送消息
//            }  roster:roster];
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//            break;
        default:
            break;
    }
}

#pragma mark Action

- (void)back{
    [self hideHud];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)rightBtn:(id)sender{
//    UserInfo *myUser = [UserInfo loadCurRecord];
//    NSInteger user_id=_msg.fromuid!=myUser.user_id?_msg.fromuid:_msg.touid;
//    NSString *name=_msg.fromuid!=myUser.user_id?_msg.fromuname:_msg.touname;
//    
//    UserInfo *user=[[UserInfo alloc] init];
//    user.user_id=user_id;
//    user.name=name;
//    user.avatar=_msg.avatar;
//    
//    UIViewController *vc = [[UserDetailViewController alloc] initWithUser:user];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)editChatMessage:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (button.tag == 0) { //编辑
        [self.resultTable setEditing:YES animated:YES];
        [button setTitle:@"完成" forState:UIControlStateNormal];
        button.tag = 1;
    } else {
        [button setTitle:@"编辑" forState:UIControlStateNormal];
        [self.resultTable setEditing:NO animated:YES];
        button.tag = 0;
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.resultTable setEditing:editing animated:YES];
}

- (void)hideInputView {
    if (self.textViewInputViewType!=XHInputViewTypeNormal) {
        //self.messageInputView.inputTextView.text=@"";
        //self.messageInputView.inputTextView.tag=0;
        //self.messageInputView.inputTextView.placeHolder = @"";//@"please input key";
        
        [self.messageInputView.inputTextView resignFirstResponder];
        self.messageInputView.faceSendButton.selected=NO;
        self.messageInputView.multiMediaSendButton.selected=NO;
        self.faceManagerView.alpha = 0.0;
        self.shareMenuView.alpha = 0.0;
        
        [UIView animateWithDuration:0.25f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            CGRect frame = self.messageInputView.frame;
            frame.origin.y = self.view.frame.size.height - frame.size.height;
            self.messageInputView.frame = frame;
            
            [self setTableViewInsetsWithBottomValue:self.view.frame.size.height - self.messageInputView.frame.origin.y];
            //[self scrollToBottomAnimated:YES];
        } completion:^(BOOL finished) {
            self.textViewInputViewType=XHInputViewTypeNormal;
        }];
    }
}

- (BOOL)shouldShowTime:(MessageDetail *)msg messages:(NSMutableArray *)messages{
    NSInteger index = [messages indexOfObject:msg];
    if ([messages count] == 0 || index == -1 || index > [messages count] - 1) {
        return NO;
    }
    if (index == 0) {
        return YES;
    }
    MessageDetail *item = [messages objectAtIndex:index - 1];
    NSTimeInterval time0 = [[NSDate dateWithDateTimeString:item.time] timeIntervalSince1970];
    NSTimeInterval time1 = [[NSDate dateWithDateTimeString:msg.time] timeIntervalSince1970];
    int distance = time1 - time0;
    if (distance > 2 * 60) { //超过两分钟后，需要显示时间
        return YES;
    }
    return NO;
}

- (IBAction)reLoadBtn:(id)sender{
    [self performSelector:@selector(getMessage:) withObject:@"news" afterDelay:0.0];
}

//对话
- (MLEmojiLabel *)getTalkContentEmojiLabelInKey:(NSString *)key text:(NSString *)text isRight:(Boolean)isRight{
    id object=[self.mlEmojLabels objectForKey:key];
    if (object && [object isKindOfClass:[MLEmojiLabel class]]){
        return object;
    }
    else{
        MLEmojiLabel *emojiLabel = [[MLEmojiLabel alloc]init];
        emojiLabel.numberOfLines = 0;
        emojiLabel.font = [UIFont systemFontOfSize:15];
        emojiLabel.textColor=isRight?MKRGBA(66,66,66,255):MKRGBA(66,66,66,255);
        //emojiLabel.emojiDelegate = self;
        emojiLabel.lineBreakMode = NSLineBreakByWordWrapping;
        emojiLabel.isNeedAtAndPoundSign = YES;
        //emojiLabel.isNeedReply = YES;
        emojiLabel.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
        //emojiLabel.customReplyRegex = [NSString stringWithFormat:@"^.*?(?=:%C)",kEmojiReplaceCharacter];//xxx:
        //emojiLabel.customReplyRegex = [NSString stringWithFormat:@"(^.*?(?=回复)|(?<=回复).*?(?=:%C))",kEmojiReplaceCharacter];//xxx回复xxx：:
        emojiLabel.frame = CGRectMake(0,0,CHAT_MSG_WIDTH,MAXFLOAT);
        [emojiLabel setEmojiText:text];
        //得到值以后要重新设置label的大小（根据值来设定）
        [emojiLabel sizeToFit];
        
        //最多显示1行
//        if (emojiLabel.frame.size.height>23) {
//            NSRange range =  [emojiLabel rangeOfLineIndex:0 rect:emojiLabel.frame];
//            if (range.length > 0 && range.length + range.location <= emojiLabel.attributedText.length) {
//                if (range.length>2) {
//                    range.length-=2;
//                }
//                NSMutableAttributedString *attrStr=[[NSMutableAttributedString alloc] init];
//                NSAttributedString *line1=[emojiLabel.attributedText attributedSubstringFromRange:range];
//                [attrStr appendAttributedString:line1];
//                NSAttributedString *dot=[[NSAttributedString alloc] initWithString:@"..."];
//                [attrStr appendAttributedString:dot];
//                emojiLabel.attributedText=attrStr;
//                [emojiLabel sizeToFit];
//            }
//        }
        
        [self.mlEmojLabels setObject:emojiLabel forKey:text];
        return emojiLabel;
    }
}

#pragma mark Table view datasource

- (void)tableViewNeedsToUpdateHeight
{
    BOOL animationsEnabled = [UIView areAnimationsEnabled];
    [UIView setAnimationsEnabled:YES];
    [self.resultTable beginUpdates];
    [self.resultTable endUpdates];
    [UIView setAnimationsEnabled:animationsEnabled];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.searchList count]>0 ){
        MessageDetail *msg = [self.searchList objectAtIndex:indexPath.row];
        
        NSString *identifier=[NSString stringWithFormat:@"ChatCell%@",@(msg.msgid)];
        ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"ChatCell" owner:nil options:nil];
            cell = (ChatCell *)[views objectAtIndex:0];
            
            cell.tag=indexPath.row;
            UserInfo *user = [UserInfo loadCurRecord];
            Boolean isRight=msg.fromuid==user.user_id;
            MLEmojiLabel *contentEmojiLbl=[self getTalkContentEmojiLabelInKey:[NSString stringWithFormat:@"MessageDetail%@",@(msg.msgid)] text:msg.content isRight:isRight];
            [cell showMessage:msg contentEmojiLbl:contentEmojiLbl isRight:isRight shouldShowTime:[self shouldShowTime:msg messages:self.searchList]];
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    }
    else{
        UITableViewCell *cell =  nil;//[tableView dequeueReusableCellWithIdentifier:@"PlaceholderCell"];
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"PlaceholderCell"];
            [cell.contentView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [obj removeFromSuperview];
            }];
        }
        
        cell.backgroundColor=[UIColor clearColor];
        
        if(_statusCode==0 ){
            UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 180, [[UIScreen mainScreen] bounds].size.width, 42)];
            statusLabel.font = [UIFont systemFontOfSize:16];
            statusLabel.textColor=MKRGBA(66,66,66,255);
            statusLabel.textAlignment = NSTextAlignmentCenter;
            statusLabel.text = NSLocalizedString(@"正在获取数据",nil);
            statusLabel.numberOfLines=1;
            statusLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:statusLabel];
        }
        else if(_statusCode==1 ){
//            UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 180, [[UIScreen mainScreen] bounds].size.width, 42)];
//            statusLabel.font = [UIFont systemFontOfSize:16];
//            statusLabel.textColor=MKRGBA(66,66,66,255);
//            statusLabel.textAlignment = NSTextAlignmentCenter;
//            statusLabel.text = NSLocalizedString(@"暂无数据",nil);
//            statusLabel.numberOfLines=1;
//            statusLabel.backgroundColor = [UIColor clearColor];
//            [cell.contentView addSubview:statusLabel];
        }
        else if(_statusCode==-1 ){
            UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 180, [[UIScreen mainScreen] bounds].size.width, 42)];
            statusLabel.font = [UIFont systemFontOfSize:16];
            statusLabel.textColor=MKRGBA(66,66,66,255);
            statusLabel.textAlignment = NSTextAlignmentCenter;
            statusLabel.text = NSLocalizedString(@"网络不给力，请重新加载",nil);
            statusLabel.numberOfLines=1;
            statusLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:statusLabel];
            
            UIButton *reLoadBtn=[UIButton buttonWithType:UIButtonTypeCustom];
            reLoadBtn.frame=CGRectMake(([[UIScreen mainScreen] bounds].size.width-200)/2, 240, 200, 40);
            reLoadBtn.titleLabel.font=[UIFont systemFontOfSize:16];
            [reLoadBtn setTitle:@"重新加载" forState:UIControlStateNormal];
            [reLoadBtn setTitle:@"重新加载" forState:UIControlStateHighlighted];
            //设置reLoadBtn
            reLoadBtn.backgroundColor=MKRGBA(0,195,147,255);
            [reLoadBtn setBackgroundImage:[UIImage createImageWithColor:MKRGBA(0,195,147,255)] forState:UIControlStateNormal];
            [reLoadBtn setBackgroundImage:[UIImage createImageWithColor:MKRGBA(4,203,154,255)] forState:UIControlStateHighlighted];
            [reLoadBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //[reLoadBtn setTitleColor:MKRGBA(63,114,218,255) forState:UIControlStateHighlighted];
            [reLoadBtn addTarget:self action:@selector(reLoadBtn:) forControlEvents:UIControlEventTouchUpInside];
            //设置Button为圆角
            reLoadBtn.layer.masksToBounds=YES; //设置为yes，就可以使用圆角
            reLoadBtn.layer.cornerRadius = 5.0;//设置它的圆角大小
            reLoadBtn.layer.borderWidth = 1.0;//视图的边框宽度
            //reLoadBtn.layer.backgroundColor =MKRGBA(240,240,240,255).CGColor;
            reLoadBtn.layer.borderColor = MKRGBA(0,195,147,255).CGColor;//视图的边框颜色
            [cell.contentView addSubview:reLoadBtn];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageDetail *msg = [self.searchList objectAtIndex:indexPath.row];
    UserInfo *user = [UserInfo loadCurRecord];
    Boolean isRight=msg.fromuid==user.user_id;
    MLEmojiLabel *contentEmojiLbl=[self getTalkContentEmojiLabelInKey:[NSString stringWithFormat:@"MessageDetail%@",@(msg.msgid)] text:msg.content isRight:isRight];
    return [ChatCell calcCellHeight:msg contentEmojiLbl:contentEmojiLbl shouldShowTime:[self shouldShowTime:msg messages:self.searchList]];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.searchList removeObjectAtIndex:indexPath.row];
        [tableView reloadData];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    //return YES;//允许删除对话
    return NO;
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //CLog(@"BeginDragging:");
    [self hideInputView];
}

#pragma mark paging 顶部

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.resultTable.tableHeaderView) {
        // 下拉到最顶部部时显示更多数据
        if(!self.loadingOld && scrollView.contentOffset.y >=0 && scrollView.contentOffset.y <= 44){
            [self loadOldDataBegin];
        }
    }
}


// 开始加载数据
- (void) loadOldDataBegin
{
    if (self.loadingOld == NO)
    {
        self.loadingOld = YES;
        UIActivityIndicatorView *tableHeaderActivityIndicator = (UIActivityIndicatorView *)[self.resultTable.tableHeaderView viewWithTag:100];
        [tableHeaderActivityIndicator startAnimating];
        
        [self performSelector:@selector(getMessage:) withObject:@"old" afterDelay:0.0];
    }
}

// 加载数据中
// http://stackoverflow.com/a/11602040 Keep UITableView static when inserting rows at the top
- (void) loadOldDataing:(NSMutableArray *)moreList
{
    __block CGPoint  delayOffset = {0.0};
    WEAKSELF
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),  ^{
        NSMutableArray *messages = [NSMutableArray arrayWithArray:moreList];
        [messages addObjectsFromArray:weakSelf.searchList];
        
        delayOffset = weakSelf.resultTable.contentOffset;
        NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:moreList.count];
        [moreList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            MessageDetail *msg = (MessageDetail *)obj;
            UserInfo *user = [UserInfo loadCurRecord];
            Boolean isRight=msg.fromuid==user.user_id;
            MLEmojiLabel *contentEmojiLbl=[weakSelf getTalkContentEmojiLabelInKey:[NSString stringWithFormat:@"MessageDetail%@",@(msg.msgid)] text:msg.content isRight:isRight];
            
            delayOffset.y += [ChatCell calcCellHeight:msg contentEmojiLbl:contentEmojiLbl shouldShowTime:[weakSelf shouldShowTime:msg messages:messages]];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            [indexPaths addObject:indexPath];
            
        }];
        
        dispatch_async(dispatch_get_main_queue(),^{
            [UIView setAnimationsEnabled:NO];
            [weakSelf.resultTable beginUpdates];
            weakSelf.searchList = messages;
            [weakSelf.resultTable insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
            
            [weakSelf.resultTable setContentOffset:delayOffset animated:NO];
            [weakSelf.resultTable endUpdates];
            [UIView setAnimationsEnabled:YES];
            
            
            [weakSelf loadOldDataEnd];
            if ([moreList count]>=weakSelf.pagecount) {
                [weakSelf createTableHeader];
            }
            else{
                weakSelf.resultTable.tableHeaderView = nil;
            }
        });
    });
}

// 加载数据完毕
- (void) loadOldDataEnd
{
    self.loadingOld = NO;
    //[self createTableHeader];
}

#pragma mark 向下paging
// 加载数据中
- (void) loadNewDataing:(NSMutableArray *)moreList
{
    if ([moreList count]>0) {
        if([self.searchList count]==0){
            if ([moreList count]>=self.pagecount) {
                [self createTableHeader];
            }
            else{
                self.resultTable.tableHeaderView = nil;
            }
        }
        
        NSMutableArray *insertIndexPaths = [NSMutableArray arrayWithCapacity:[moreList count]];
        
        for (int ind = 0; ind < [moreList count]; ind++) {
            NSIndexPath    *newPath =  [NSIndexPath indexPathForRow:[self.searchList count]+ind inSection:0];
            [insertIndexPaths addObject:newPath];
        }
        
        [self.searchList addObjectsFromArray:moreList];
        [self.resultTable insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self tableViewNeedsToUpdateHeight];
        
        //滚动最后一条
        if (moreList.count>0) {
            NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:[self.searchList count]-1 inSection:0];
            BOOL animated=[moreList count]!=[self.searchList count];
            if (animated) {
                [self.resultTable scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:animated];
            }
            else{
                [self.resultTable scrollToRowAtIndexPath:scrollIndexPath atScrollPosition:UITableViewScrollPositionNone animated:animated];
            }
        }
    }
}

// 创建表格顶部
- (void) createTableHeader
{
    self.resultTable.tableHeaderView = nil;
    
    UIView *tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width, 25.0f)];
    tableHeaderView.backgroundColor=[UIColor clearColor];
    UIActivityIndicatorView *tableHeaderActivityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(([[UIScreen mainScreen] bounds].size.width)/2-10, 0.0f, 20.0f, 20.0f)];
    [tableHeaderActivityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [tableHeaderActivityIndicator startAnimating];
    tableHeaderActivityIndicator.tag=100;
    [tableHeaderView addSubview:tableHeaderActivityIndicator];
    
    self.resultTable.tableHeaderView = tableHeaderView;
}

#pragma mark - UIImagePickerControllerDelegate

-(void)saveImage:(UIImage*)pImage
{
    if (pImage == nil) {
        return;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* pFileSavedPath = [[Configs documentPath] stringByAppendingPathComponent:@"edit.png"];
    BOOL bFileExisted = [fileManager fileExistsAtPath:pFileSavedPath ];
    if(bFileExisted)
    {
        [fileManager removeItemAtPath:pFileSavedPath error:nil];
    }
    //NSData* pImageData = UIImagePNGRepresentation(pImage);
    //再次质量压缩
    NSData* pImageData = [pImage compressedData];
    [pImageData writeToFile:pFileSavedPath atomically:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    switch (picker.view.tag) {
        case 100://照片
        {
            //UIImage *image= [info objectForKey:UIImagePickerControllerEditedImage];//PNG格式
            UIImage *image= [info objectForKey:UIImagePickerControllerOriginalImage];//PNG格式
            //NSLog(@"image==%f==%f==%@",image.size.width,image.size.height,image.contentType);
            self.editImage = [image compressedImage:CGSizeMake(750, 750)] ;//PNG
            //NSLog(@"image==%f==%f==%@",_editImage.size.width,_editImage.size.height,_editImage.contentType);
            if (self.editImage) {
                //保存本地
                //[self saveImage:self.editImage];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat: @"yyyyMMdd"];
                [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
                NSString *timeDesc = [formatter stringFromDate:[NSDate date]];
                double timeInterval = [[[NSDate alloc] init] timeIntervalSinceReferenceDate]*1000000;
                NSString *pic_url=[NSString stringWithFormat:@"img%@%.0f_%@_%@",timeDesc,timeInterval,@((int)self.editImage.size.width),@((int)self.editImage.size.height)];
                
                NSString* filePath = [kCachesFolder stringByAppendingPathComponent:pic_url];
                NSFileManager *fileManager = [NSFileManager defaultManager];
                BOOL bFileExisted = [fileManager fileExistsAtPath:filePath ];
                if(bFileExisted)
                {
                    [fileManager removeItemAtPath:filePath error:nil];
                }
                //NSData* pImageData = UIImagePNGRepresentation(pImage);
                //再次质量压缩
                NSData* pImageData = [self.editImage compressedData];
                [pImageData writeToFile:filePath atomically:YES];
                
                [self.uploadPics removeAllObjects];
                NSMutableDictionary *dic=[NSMutableDictionary dictionary];
                [dic setValue:pic_url forKey:@"pic_url"];
                [dic setObject:[NSNumber numberWithInt:(int)self.editImage.size.width] forKey:@"width"];
                [dic setObject:[NSNumber numberWithInt:(int)self.editImage.size.height] forKey:@"height"];
                [self.uploadPics addObject:dic];
                //先上传图片后发送消息
                [self showHudInView:self.view hint:@"请稍等..."];//显示
                [self uploadPic:self.uploadPics[0]];
            }
            
            break;
        }
        default:
            break;
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UINavigationControllerDelegate
//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//    NSLog(@"avigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated");
//}
//- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//    NSLog(@"navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated");
//}

#pragma mark Interface

//获取对话消息接口
- (void)getMessage:(NSString *)direction{
    //取消轮循
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getMessage:) object:@"news"];
    
    UserInfo *user = [UserInfo loadCurRecord];
    NSInteger friend_uid=(user.user_id==_msg.fromuid)?_msg.touid:_msg.fromuid;
    NSInteger fetch_new;
    NSInteger startid;
    if ([direction isEqualToString:@"news"]) {//新消息
        fetch_new=1;
        if([self.searchList count]==0){
            startid=0;
        }
        else{
            MessageDetail *msg = [self.searchList objectAtIndex:[self.searchList count]-1];
            startid=msg.msgid;
        }
    }else{//历史消息
        fetch_new=0;
        if([self.searchList count]==0){
            startid=0;
        }
        else{
            MessageDetail *msg = [self.searchList objectAtIndex:0];
            startid=msg.msgid;
        }
    }
    
    _statusCode=0;
    //[self showHudInView:self.view hint:@"请稍等..."];//显示
    WEAKSELF
    [API getMessageWithTouid:friend_uid
                   fetch_new:fetch_new
                     startid:startid
                       count:self.pagecount
                  completion:^(NSError *error, id response) {
                      [weakSelf hideHud];
                      if (!error) {
                          NSMutableArray *moreList=[NSMutableArray array];
                          
                          //数据处理
                          NSArray *msgs = response[@"message_list"];
                          if (msgs && msgs.count>0) {
                              for (NSDictionary *msgDic in msgs) {
                                  MessageDetail *msg = [[MessageDetail alloc] initWithDic:msgDic];
                                  [moreList addObject:msg];
                              }
                              //[moreList sortUsingFunction:newsPositionSort context:nil];
                          }
                          
                          weakSelf.statusCode=1;
                          
                          if ([direction isEqualToString:@"news"]) {
                              [weakSelf performSelectorOnMainThread:@selector(loadNewDataing:) withObject:moreList waitUntilDone:NO];
                          }
                          else{//old
                              if([weakSelf.searchList count]==0)
                              {
                                  [weakSelf.searchList addObjectsFromArray:moreList];
                                  [weakSelf.resultTable reloadData];
                                  if ([moreList count]>=weakSelf.pagecount) {
                                      [weakSelf createTableHeader];
                                  }
                              }
                              else{
                                  [weakSelf performSelectorOnMainThread:@selector(loadOldDataing:) withObject:moreList waitUntilDone:NO];
                              }
                          }
                      }
                      else{//code>0
                          [[TKAlertCenter defaultCenter] postAlertWithMessage:error.domain];
                          
                          weakSelf.statusCode=-1;
                          
                          if ([direction isEqualToString:@"news"]) {
                              if([weakSelf.searchList count]==0)
                              {
                                  [weakSelf.resultTable reloadData];
                              }
                              else{
                                  [weakSelf performSelectorOnMainThread:@selector(loadNewDataing:) withObject:nil waitUntilDone:NO];
                              }
                          }
                          else{//old
                              if([weakSelf.searchList count]==0)
                              {
                                  [weakSelf.resultTable reloadData];
                              }
                              else{
                                  [weakSelf createTableHeader];
                                  [weakSelf loadOldDataEnd];
                              }
                          }
                      }
                      [weakSelf performSelector:@selector(getMessage:) withObject:@"news" afterDelay:8.0];//轮循
                  }];
}

-(void)uploadPic:(NSDictionary *)dic{
    NSString *key = [dic valueForKey:@"pic_url"];
    NSString *filePath = [kCachesFolder stringByAppendingPathComponent:key];
    
    WEAKSELF
    [APIQN uploadFile:filePath
                  key:key
                scope:QiniuBucketNameImg
                extra:nil
        progressBlock:^(NSProgress *progress) {
            CLog(@"上传进度:%@",@(progress.fractionCompleted));
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self.progressView setProgress:progress.fractionCompleted];
//            });
        }
      completionBlock:^(NSError *error, NSString *filePath, NSDictionary *resp) {
          [weakSelf.uploadPics removeObjectAtIndex:0];
          if (!error) {
              NSString *path = [resp objectForKey:@"key"];
              NSString *urlStr=[NSString stringWithFormat:@"%@.qiniudn.com/%@",QiniuBucketNameImg,path];
              
              NSDictionary *msgDic=[NSDictionary dictionaryWithObjectsAndKeys:@(2), @"msg_type", urlStr, @"msg_content", nil];
              [weakSelf sendMessage:msgDic];//发送消息
          }
          else{
              [weakSelf hideHud];//隐藏
              //[[TKAlertCenter defaultCenter] postAlertWithMessage:error.domain];
              [[TKAlertCenter defaultCenter] postAlertWithMessage:@"上传失败"];
          }
      }];
}

//发送消息接口
//msgDic:{@"msg_type":type,@"msg_content":相应值}
- (void)sendMessage:(NSDictionary *)msgDic{
    //取消轮循
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(getMessage:) object:@"news"];
    
    UserInfo *user = [UserInfo loadCurRecord];
    NSInteger friend_uid=(user.user_id==_msg.fromuid)?_msg.touid:_msg.fromuid;
    NSInteger startid;
    if([self.searchList count]==0){
        startid=0;
    }
    else{
        MessageDetail *msg = [self.searchList objectAtIndex:[self.searchList count]-1];
        startid=msg.msgid;
    }
    NSInteger msg_type=[msgDic[@"msg_type"] integerValue];
    NSString *msg_content=msgDic[@"msg_content"];
    NSString *content;
    NSString *image;
    switch (msg_type) {
        case 2://图片
            content=@"[图片]";
            image=msg_content;
            break;
        default:
            content=msg_content;
            break;
    }
    
    //[self showHudInView:self.view hint:@"请稍等..."];;//显示
    WEAKSELF
    [API sendMessageWithTouid:friend_uid
                      startid:startid
                     msg_type:msg_type
                      content:msg_content
                        image:image
                   completion:^(NSError *error, id response) {
                       [weakSelf hideHud];
                       if (!error) {
                           if (weakSelf.uploadPics.count>0) {
                               //先上传图片后发送消息
                               NSDictionary *dic=weakSelf.uploadPics[0];
                               [weakSelf uploadPic:dic];
                           }
                           else{
                               [weakSelf hideHud];
                           }
                           
                           weakSelf.messageInputView.inputTextView.text=@"";
                           
                           NSMutableArray *moreList=[NSMutableArray array];
                           
                           //数据处理
                           NSArray *msgs = response[@"message_list"];
                           if (msgs && msgs.count>0) {
                               for (NSDictionary *msgDic in msgs) {
                                   MessageDetail *msg = [[MessageDetail alloc] initWithDic:msgDic];
                                   [moreList addObject:msg];
                               }
                               //[moreList sortUsingFunction:newsPositionSort context:nil];
                           }
                           
                           [weakSelf performSelectorOnMainThread:@selector(loadNewDataing:) withObject:moreList waitUntilDone:NO];
                       }
                       else{//code>0
                           [[TKAlertCenter defaultCenter] postAlertWithMessage:error.domain];
                           
                           if (weakSelf.uploadPics.count>0) {
                               //先上传图片后发送消息
                               NSDictionary *dic=weakSelf.uploadPics[0];
                               [weakSelf uploadPic:dic];
                           }
                           else{
                               [weakSelf hideHud];
                           }
                           
                           if([weakSelf.searchList count]==0)
                           {
                               [weakSelf.resultTable reloadData];
                           }
                           else{
                               [weakSelf performSelectorOnMainThread:@selector(loadNewDataing:) withObject:nil waitUntilDone:NO];
                           }
                       }
                       [weakSelf performSelector:@selector(getMessage:) withObject:@"news" afterDelay:8.0];//轮循
                   }];
}

@end
