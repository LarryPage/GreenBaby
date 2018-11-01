//
//  ChatCell.m
//  RRLT
//
//  Created by 香成 李 on 12-5-2８.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ChatCell.h"

#define kImgMaxWidth ([[UIScreen mainScreen] bounds].size.width-60-60/2-CHAT_MSG_H_PAD*2-CHAT_ARROW_WIDTH)/2
#define kImgMaxHeight ([[UIScreen mainScreen] bounds].size.height-20-44-49)/4//屏幕有效高度的1/4

#define kPositionHeight 50

@interface ChatCell (){
    BaseChatMessageView *_messageView;
}
@property (nonatomic, weak) IBOutlet UIView *leftView;
@property (nonatomic, weak) IBOutlet UIImageView *leftAvatarView;
@property (nonatomic, weak) IBOutlet UIButton *leftAvatarBtn;
@property (nonatomic, weak) IBOutlet UIView *rightView;
@property (nonatomic, weak) IBOutlet UIImageView *rightAvatarView;
@property (nonatomic, weak) IBOutlet UIButton *rightAvatarBtn;
@property (nonatomic, weak) IBOutlet TimeHeaderView *timeHeaderView;
@property (nonatomic, weak) IBOutlet UIButton *msgBackgroundButton;
@end

@implementation ChatCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _leftAvatarView.layer.cornerRadius = 3.0;//_leftAvatarView.frame.size.width/2;
    _leftAvatarView.layer.masksToBounds = YES;
    _rightAvatarView.layer.cornerRadius = 3.0;//_rightAvatarView.frame.size.width/2;
    _rightAvatarView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    [super setHighlighted:highlighted animated:animated];
}

#pragma mark - Actions

- (void)showMessage:(MessageModel *)msg contentEmojiLbl:(MLEmojiLabel *)contentEmojiLbl isRight:(Boolean)isRight shouldShowTime:(Boolean)shouldShowTime{
    self.message = msg;
    
    if (msg.msg_type==3) {//WebPage
        _leftView.hidden=YES;
        _rightView.hidden=YES;
        
        float offset;
        if (shouldShowTime) {
            _timeHeaderView.hidden = NO;
            //[_timeHeaderView showTime:msg.submitTime];
            [_timeHeaderView showDate:msg.time];
            offset = TIME_HEADER_HEIGHT;
        } else {
            _timeHeaderView.hidden = YES;
            offset = 5;
        }
        
        CGFloat xLeft=10;
        CGFloat y=offset;
        
        self.backgroundColor=[UIColor clearColor];
        
        _msgBackgroundButton.frame=CGRectMake(xLeft, offset, [[UIScreen mainScreen] bounds].size.width-xLeft*2, 0);
        _msgBackgroundButton.backgroundColor=[UIColor clearColor];
        UIImage *btnBg_normal = [[UIImage imageNamed:@"webpageBtnBg"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 7, 7, 7)];
        UIImage *btnBg_highlighted = [[UIImage imageNamed:@"webpageBtnBg_hl"] resizableImageWithCapInsets:UIEdgeInsetsMake(7, 7, 7, 7)];
        [_msgBackgroundButton setBackgroundImage:btnBg_normal forState:UIControlStateNormal];
        [_msgBackgroundButton setBackgroundImage:btnBg_highlighted forState:UIControlStateHighlighted];
        
        xLeft+=10;
        y+=10;
        
        //titleLabel
        UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(xLeft, y, [[UIScreen mainScreen] bounds].size.width-xLeft*2, 21)];
        titleLabel.text=msg.title;
        titleLabel.font=[UIFont systemFontOfSize:14];
        titleLabel.textColor=MKRGBA(66,66,66,255);
        titleLabel.backgroundColor=[UIColor clearColor];
        titleLabel.textAlignment=NSTextAlignmentLeft;
        [self addSubview:titleLabel];
        y+=21;
        //timeLabel
        UILabel *timeLabel=[[UILabel alloc] initWithFrame:CGRectMake(xLeft, y, [[UIScreen mainScreen] bounds].size.width-xLeft*2, 21)];
        timeLabel.text=msg.time;
        timeLabel.font=[UIFont systemFontOfSize:10];
        timeLabel.textColor=MKRGBA(146,146,146,255);
        timeLabel.backgroundColor=[UIColor clearColor];
        timeLabel.textAlignment=NSTextAlignmentLeft;
        [self addSubview:timeLabel];
        y+=21;
        //picBtn
        CGFloat width=[[UIScreen mainScreen] bounds].size.width-xLeft*2;
        CGFloat height=([[UIScreen mainScreen] bounds].size.width-xLeft*2)/2;
        //http://docs.qiniutek.com/v3/api/foimg/#imageView
        //http://qiniuphotos.qiniudn.com/gogopher.jpg?imageView/2/w/300/h/400/q/100
        NSString *pic_thumb_url=[NSString stringWithFormat:@"%@?imageView/1/w/%@/h/%@/q/100",msg.image,@((int)(width*[[UIScreen mainScreen] scale])),@((int)(height*[[UIScreen mainScreen] scale]))];
        UIButton *picBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        picBtn.frame=CGRectMake(xLeft, y, width, height);
        [picBtn sd_setImageWithURL:[NSURL URLWithString:pic_thumb_url] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"Loading_PlaceHolder"]];
        picBtn.imageView.contentMode=UIViewContentModeScaleToFill;
        picBtn.backgroundColor=MKRGBA(226,226,226,255);
        [self addSubview:picBtn];
        picBtn.userInteractionEnabled=NO;
        y+=height;
        //contentLabel
        UILabel *contentLabel=[[UILabel alloc] initWithFrame:CGRectMake(xLeft, y, [[UIScreen mainScreen] bounds].size.width-xLeft*2, 42)];
        contentLabel.text=msg.content;
        contentLabel.font=[UIFont systemFontOfSize:12];
        contentLabel.textColor=MKRGBA(146,146,146,255);
        contentLabel.backgroundColor=[UIColor clearColor];
        contentLabel.textAlignment=NSTextAlignmentLeft;
        contentLabel.numberOfLines=2;
        [self addSubview:contentLabel];
        y+=42;
        //separator
        UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(xLeft, y, [[UIScreen mainScreen] bounds].size.width-xLeft*2, 1/[[UIScreen mainScreen] scale])];
        separator.backgroundColor = MKRGBA(230,230,230,255);
        [self addSubview:separator];
        //moreLabel
        UILabel *moreLabel=[[UILabel alloc] initWithFrame:CGRectMake(xLeft, y+3, [[UIScreen mainScreen] bounds].size.width-xLeft*2, 21)];
        moreLabel.text=@"阅读全文";
        moreLabel.font=[UIFont systemFontOfSize:12];
        moreLabel.textColor=MKRGBA(66,66,66,255);
        moreLabel.backgroundColor=[UIColor clearColor];
        moreLabel.textAlignment=NSTextAlignmentLeft;
        [self addSubview:moreLabel];
        y+=21;
        //arrowIV
        UIImageView *arrowIV=[[UIImageView alloc] initWithFrame:CGRectMake([[UIScreen mainScreen] bounds].size.width-xLeft-14, y-14, 14, 14)];
        arrowIV.image=[UIImage imageNamed:@"disclosure"];
        [self addSubview:arrowIV];
        
        y+=10;
        CGRect frame=_msgBackgroundButton.frame;
        frame.size.height=y-frame.origin.y;
        _msgBackgroundButton.frame=frame;
        
        return;
    }
    //箭头的尺寸是6px
    UIImage *leftImage = [[UIImage imageNamed:@"leftBubleBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 20, 10, 20)];
    UIImage *rightImage = [[UIImage imageNamed:msg.msg_type==8?@"rightBubleBackground_1":@"rightBubleBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(30, 20, 10, 20)];
    
    float offset;
    if (shouldShowTime) {
        _timeHeaderView.hidden = NO;
        //[_timeHeaderView showTime:msg.submitTime];
        [_timeHeaderView showDate:msg.time];
        offset = TIME_HEADER_HEIGHT;
    } else {
        _timeHeaderView.hidden = YES;
        offset = 0;
    }
    CGRect tempRect= _msgBackgroundButton.frame;
    tempRect.origin.y = offset;
    _msgBackgroundButton.frame = tempRect;
    
    tempRect = _leftView.frame;
    tempRect.origin.y = offset;
    _leftView.frame = tempRect;
    
    tempRect = _rightView.frame;
    tempRect.origin.y = offset;
    _rightView.frame = tempRect;
    
    
    if (_messageView) {
        [_messageView removeFromSuperview];
        _messageView=nil;
    }
    switch (msg.msg_type) {
        case 1://仅仅文本（含emoji)
        default:
            _messageView = [[TextChatMessageView alloc] init];
            break;
        case 2://图片
            _messageView = [[PhotoChatMessageView alloc] init];
            break;
        case 8://活动邀请
            _messageView = [[ActivityChatMessageView alloc] init];
            break;
    }
    _messageView.userInteractionEnabled = YES;//允许copy CopyLabel
    
    CGRect bgViewFrame = _msgBackgroundButton.frame;
    bgViewFrame.origin.x = 60;//
    
    CGRect messageViewFrame = CGRectMake(bgViewFrame.origin.x + CHAT_MSG_H_PAD + CHAT_ARROW_WIDTH, bgViewFrame.origin.y + CHAT_MSG_V_PAD, CHAT_MSG_WIDTH, CHAT_MSG_HEIGHT);
    [_messageView showMessage:msg contentEmojiLbl:contentEmojiLbl];
    messageViewFrame.size = _messageView.bounds.size;
    
    bgViewFrame.size = CGSizeMake(_messageView.bounds.size.width + 2 * CHAT_MSG_H_PAD + CHAT_ARROW_WIDTH, _messageView.bounds.size.height + 2 * CHAT_MSG_V_PAD);
    
    if (isRight) {
        //        float offset = bgViewFrame.size.width - (_messageView.bounds.size.width + CHAT_MSG_H_PAD);
        //        bgViewFrame.origin.x += offset;
        //        messageViewFrame.origin.x += offset - CHAT_ARROW_WIDTH;
        float offset = bgViewFrame.origin.x+bgViewFrame.size.width - ([[UIScreen mainScreen] bounds].size.width-60);//
        bgViewFrame.origin.x -= offset;
        messageViewFrame.origin.x -= offset + CHAT_ARROW_WIDTH;
    }
    
    _msgBackgroundButton.frame = bgViewFrame;
    _messageView.frame = messageViewFrame;
    
    [self.contentView addSubview:_messageView];
    
    _leftView.hidden = isRight;
    _rightView.hidden = !isRight;
    UserModel *user = [UserModel loadCurRecord];
    if (!isRight) {//左边
        NSInteger uid=msg.fromuid!=user.user_id?msg.fromuid:msg.touid;
        NSString *name=msg.fromuid!=user.user_id?msg.fromuname:msg.touname;
        name=(name && name.length>0)?name:@" ";
        NSString *avatar=msg.avatar;
        
        //[self.leftAvatarView sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[UIImage imageWithString:[[name substringToIndex:1] uppercaseString] ToSize:self.leftAvatarView.frame.size]];
        [self.leftAvatarView sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[UIImage imageNamed:@"avatarDefault"]];
        
        _leftAvatarBtn.tag=uid;
        [_msgBackgroundButton setBackgroundImage:leftImage forState:UIControlStateNormal];
        [_msgBackgroundButton setBackgroundImage:leftImage forState:UIControlStateHighlighted];
    } else {//右边
        NSInteger uid=msg.fromuid==user.user_id?msg.fromuid:msg.touid;
        NSString *name=msg.fromuid==user.user_id?msg.fromuname:msg.touname;
        name=(name && name.length>0)?name:@" ";
        NSString *avatar=user.avatar;
        
        //[self.rightAvatarView sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[UIImage imageWithString:[[name substringToIndex:1] uppercaseString] ToSize:self.rightAvatarView.frame.size]];
        [self.rightAvatarView sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[UIImage imageNamed:@"avatarDefault"]];
        
        _rightAvatarBtn.tag=uid;
        [_msgBackgroundButton setBackgroundImage:rightImage forState:UIControlStateNormal];
        [_msgBackgroundButton setBackgroundImage:rightImage forState:UIControlStateHighlighted];
    }
}

+ (NSInteger)calcCellHeight:(MessageModel *)msg contentEmojiLbl:(MLEmojiLabel *)contentEmojiLbl shouldShowTime:(Boolean)shouldShowTime{
    if (msg.msg_type==3) {//WebPage
        float offset;
        if (shouldShowTime) {
            offset = TIME_HEADER_HEIGHT;
        } else {
            offset = 5;
        }
        
        CGFloat xLeft=10;
        CGFloat y=offset;
        
        xLeft+=10;
        y+=10;
        
        //titleLabel
        y+=21;
        //timeLabel
        y+=21;
        //WebPageImg
        y+=([[UIScreen mainScreen] bounds].size.width-xLeft*2)/2;
        //contentLabel
        y+=42;
        //moreLabel
        y+=21;
        
        y+=10;
        
        return y+5;
    }
    
    NSInteger height = 0;
    switch (msg.msg_type) {
        case 1://仅仅文本（含emoji)
        default:
            height = [TextChatMessageView sizeOfChatMessageView:msg contentEmojiLbl:contentEmojiLbl].height;
            break;
        case 2://图片
            height = [PhotoChatMessageView sizeOfChatMessageView:msg contentEmojiLbl:contentEmojiLbl].height;
            break;
        case 8://活动邀请
            height = [ActivityChatMessageView sizeOfChatMessageView:msg contentEmojiLbl:contentEmojiLbl].height;
            break;
    }
    
    NSInteger minHeight = 70;
    if (shouldShowTime) {
        height += TIME_HEADER_HEIGHT;
        minHeight += TIME_HEADER_HEIGHT;
    }
    height+= 2 * CHAT_MSG_V_PAD + CHAT_MSG_CELL_PAD;
    if (height<minHeight) {
        height=minHeight;
    }
    return height;
}

- (IBAction)showDetail:(id)sender {
    if (self.message.msg_type==3) {//WebPage
        UIViewController *parentVC=[self getViewController];//通过UIView获取它的UIViewController
        WebViewController *vc = [[WebViewController alloc] initWithUrl:self.message.page_url title:self.message.title];
        [[parentVC navigationController] pushViewController:vc animated:YES];
        return;
    }
    [_messageView showDetail];
}

#pragma mark Action

- (IBAction)leftAvatarBtn:(id)sender{
//    //UIButton *btn=(UIButton *)sender;
//    UIViewController *parentVC=[self getViewController];//通过UIView获取它的UIViewController
//    
//    UserInfo *myUser = [UserInfo loadCurRecord];
//    NSInteger user_id=self.message.fromuid!=myUser.user_id?self.message.fromuid:self.message.touid;
//    NSString *name=self.message.fromuid!=myUser.user_id?self.message.fromuname:self.message.touname;
//    
//    UserInfo *user=[[UserInfo alloc] init];
//    user.user_id=user_id;
//    user.name=name;
//    user.avatar=self.message.avatar;
//    
//    UIViewController *vc = [[UserDetailViewController alloc] initWithUser:user];
//    [parentVC.navigationController pushViewController:vc animated:YES];
}

- (IBAction)rightAvatarBtn:(id)sender{
//    //UIButton *btn=(UIButton *)sender;
//    UIViewController *parentVC=[self getViewController];//通过UIView获取它的UIViewController
//    UIViewController *vc = [[UserDetailViewController alloc] initWithUser:[UserInfo loadCurRecord]];
//    [parentVC.navigationController pushViewController:vc animated:YES];
}

@end

@implementation BaseChatMessageView

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)showMessage:(MessageModel *)msg contentEmojiLbl:(MLEmojiLabel *)contentEmojiLbl{
    self.message = msg;
}

+ (CGSize)sizeOfChatMessageView:(MessageModel *)msg contentEmojiLbl:(MLEmojiLabel *)contentEmojiLbl{
    return CGSizeZero;
}

- (void)showDetail {
    
}
@end

@implementation TextChatMessageView

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (CGSize)sizeOfChatMessageView:(MessageModel *)msg contentEmojiLbl:(MLEmojiLabel *)contentEmojiLbl{
    //return contentEmojiLbl.frame.size;
    return CGSizeMake(contentEmojiLbl.frame.size.width, contentEmojiLbl.frame.size.height);
}

//自定义copoy  --begin
#pragma mark Clipboard

- (void) copy: (id) sender{
    //NSLog(@"Copy handler, label: “%@”.", self.message.content);
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = self.message.content;
}

- (BOOL) canPerformAction: (SEL) action withSender: (id) sender{
    //NSLog(@"action:%@",NSStringFromSelector(action));//cut: copy: select: selectAll: paste: delete: promptForReplace: _showMoreItems: _setRtoLTextDirection: _setLtoRTextDirection:
    //return (action == @selector(copy:) || action == @selector(select:) || action == @selector(selectAll:));
    return (action == @selector(copy:));
}

- (void) handleTap: (UIGestureRecognizer*) recognizer{
    [self becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setTargetRect:self.frame inView:self.superview];
    [menu setMenuVisible:YES animated:YES];
}

- (BOOL) canBecomeFirstResponder{
    return YES;
}

- (void) attachTapHandler{
    [self setUserInteractionEnabled:YES];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:longPress];
}
//自定义copoy --end

- (void)showMessage:(MessageModel *)msg contentEmojiLbl:(MLEmojiLabel *)contentEmojiLbl{
    [super showMessage:msg contentEmojiLbl:(MLEmojiLabel *)contentEmojiLbl];
    
    CGRect frame = self.bounds;
    frame.size = [TextChatMessageView sizeOfChatMessageView:msg contentEmojiLbl:(MLEmojiLabel *)contentEmojiLbl];
    
    contentEmojiLbl.frame=frame;
    [self addSubview:contentEmojiLbl];
    contentEmojiLbl.emojiDelegate = self;
    [self attachTapHandler];//自定义copoy
    
    CGRect frame1 = self.frame;
    frame1.size = frame.size;
    self.frame = frame1;
}

- (void)showDetail {
}

#pragma mark MLEmojiLabelDelegate

- (void)DisplayAlertWithTitle:(NSString *)title message:(NSString *)message{
    [UIAlertController alert:message title:title bTitle:@"确定"];
}

- (void)mlEmojiLabel:(MLEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(MLEmojiLabelLinkType)type{
    BaseViewController *parentVC=(BaseViewController *)[self getViewController];//通过UIView获取它的UIViewController
    
    switch (type) {
        case MLEmojiLabelLinkTypeURL:
        {
            NSURL *url=[NSURL URLWithString:link];
            if ([[url scheme] isEqualToString:@"user"]) {
                // We use this arbitrary URL scheme to handle custom actions
                // So URLs like "user://xxx" will be handled here instead of opening in Safari.
                // Note: in the above example, "xxx" is the 'host' part of the URL
                NSString* user = [url host];
                [self DisplayAlertWithTitle:@"User Profile" message:[NSString stringWithFormat:@"Here you should display the profile of user %@ on a new screen.",user]];
            }
            else if (([[url scheme] isEqualToString:@"mailto"]) ) {//邮件mailto:
                if (![EmailViewController canSendMail]) {
                    [self DisplayAlertWithTitle:nil message:@"您的设备不支持\r\n电子邮件服务"];
                    break;
                }
                
                EmailViewController *picker = [[EmailViewController alloc] init];
                picker.mailComposeDelegate = self;
                
                [picker setSubject:@"回家么"];
                //NSArray *ccRecipients = [NSArray arrayWithObjects:@"sbtjfdn@tom.com", @"third@example.com", nil];
                //NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"];
                [picker setToRecipients:[NSArray arrayWithObject:[link stringByReplacingOccurrencesOfString:@"mailto:" withString:@""]]];
                //[picker setCcRecipients:ccRecipients];
                //[picker setBccRecipients:bccRecipients];
                
                // Attach an image to the email
                //UIImage *myPic = [UIImage imageNamed:@"SearchResult.PNG"];
                //NSData *myData = UIImagePNGRepresentation(myPic);
                //[picker addAttachmentData:myData mimeType:@"image/png" fileName:@"SearchResult.PNG"];
                
                // Fill out the email body text
                //NSString *emailBody = @"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Frameset//EN\"><html><head><title>名片碰碰</title></head><body><br><br><br>@名片碰碰　http://www.peng.me</body></html>";
                //[picker setMessageBody:emailBody isHTML:YES];
                
                picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;//UIModalTransitionStyleFlipHorizontal;
                picker.navigationBar.barStyle = DefaultStatusBarStyle;
                picker.navigationBar.translucent = YES;
                [parentVC setNavigationBar1Attribute:picker.navigationBar];
                [parentVC presentViewController:picker animated:YES completion:nil];//6.0
            }
            else{//http://
                NSString *urlStr=link;
                if (!([link hasPrefix:@"http://"] || [link hasPrefix:@"https://"])) {
                    urlStr = [NSString stringWithFormat:@"http://%@", link];
                }
                
                /*
                 SVWebViewController *sv = [[SVWebViewController alloc] initWithURL:[NSURL URLWithString:urlStr]];
                 [sv setTitle:urlStr];
                 [[parentVC navigationController] pushViewController:sv animated:YES];
                 */
                
                WebViewController *vc = [[WebViewController alloc] initWithUrl:urlStr title:self.message.title];
                [[parentVC navigationController] pushViewController:vc animated:YES];
            }
        }
            break;
        case MLEmojiLabelLinkTypePhoneNumber:
        {
            //DisplayAlert(@"Phone Number",linkInfo.phoneNumber);
            //去掉NSString中的其它所有字符，而只保留数字
            NSCharacterSet *nonNumbers = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
            NSString *truePhoneValue = [[link componentsSeparatedByCharactersInSet:nonNumbers] componentsJoinedByString:@""];
            //DisplayAlert(@"Phone Number",truePhoneValue);
            if (![CallViewController canCallPhone]) {
                [[TKAlertCenter defaultCenter] postAlertWithMessage:@"您的设备不支持\r\n拨打电话服务"];
            }
            else{
                [CallViewController CallPhone:truePhoneValue];
            }
        }
            break;
        case MLEmojiLabelLinkTypeEmail:
        {
            if (![EmailViewController canSendMail]) {
                [self DisplayAlertWithTitle:nil message:@"您的设备不支持\r\n电子邮件服务"];
                break;
            }
            
            EmailViewController *picker = [[EmailViewController alloc] init];
            picker.mailComposeDelegate = self;
            
            [picker setSubject:@"回家么"];
            //NSArray *ccRecipients = [NSArray arrayWithObjects:@"sbtjfdn@tom.com", @"third@example.com", nil];
            //NSArray *bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"];
            [picker setToRecipients:[NSArray arrayWithObject:[link stringByReplacingOccurrencesOfString:@"mailto:" withString:@""]]];
            //[picker setCcRecipients:ccRecipients];
            //[picker setBccRecipients:bccRecipients];
            
            // Attach an image to the email
            //UIImage *myPic = [UIImage imageNamed:@"SearchResult.PNG"];
            //NSData *myData = UIImagePNGRepresentation(myPic);
            //[picker addAttachmentData:myData mimeType:@"image/png" fileName:@"SearchResult.PNG"];
            
            // Fill out the email body text
            //NSString *emailBody = @"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Frameset//EN\"><html><head><title>名片碰碰</title></head><body><br><br><br>@名片碰碰　http://www.peng.me</body></html>";
            //[picker setMessageBody:emailBody isHTML:YES];
            
            picker.modalTransitionStyle = UIModalTransitionStyleCoverVertical;//UIModalTransitionStyleFlipHorizontal;
            picker.navigationBar.barStyle = DefaultStatusBarStyle;
            picker.navigationBar.translucent = YES;
            [parentVC setNavigationBar1Attribute:picker.navigationBar];
            [parentVC presentViewController:picker animated:YES completion:nil];//6.0
        }
            break;
        case MLEmojiLabelLinkTypeAt://@功能
            break;
        case MLEmojiLabelLinkTypePoundSign://##功能
            break;
        case MLEmojiLabelLinkTypeReply://回复功能
            break;
        default:
        {
            [self DisplayAlertWithTitle:@"Address" message:link];
        }
            break;
    }
}

#pragma mark Mail delegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    NSString * resultStr;
    // Notifies users about errors associated with the interface
    switch (result)
    {
        case MFMailComposeResultCancelled:
            resultStr = @"取消邮件发送";
            break;
        case MFMailComposeResultSaved:
            resultStr = @"保存邮件";
            break;
        case MFMailComposeResultSent:
            resultStr = @"邮件发送成功";
            break;
        case MFMailComposeResultFailed:
            resultStr = @"邮件发送失败";
            break;
        default:
            resultStr = @"邮件不能发送";
            break;
    }
    
    if (result == MFMailComposeResultSent || result == MFMailComposeResultFailed) {
        [UIAlertController alert:resultStr title:@"提示" bTitle:@"确定"];
    }
    
    [controller dismissViewControllerAnimated:YES completion:nil];//6.0
}

@end

@implementation PhotoChatMessageView

- (void)awakeFromNib {
    [super awakeFromNib];
    _photos = [[NSMutableArray alloc] init];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _photos = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)showMessage:(MessageModel *)msg contentEmojiLbl:(MLEmojiLabel *)contentEmojiLbl{
    [super showMessage:msg contentEmojiLbl:(MLEmojiLabel *)contentEmojiLbl];
    
    CGRect frame = self.bounds;
    frame.size = [PhotoChatMessageView sizeOfChatMessageView:msg contentEmojiLbl:(MLEmojiLabel *)contentEmojiLbl];
    
    UIButton *picBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    picBtn.frame=frame;
    NSString *pic_url=msg.image;//20141225164012_400_600.png
    //http://docs.qiniutek.com/v3/api/foimg/#imageView
    //http://qiniuphotos.qiniudn.com/gogopher.jpg?imageView/2/w/300/h/400
    NSString *pic_thumb_url=[NSString stringWithFormat:@"%@?imageView/1/w/%@/h/%@/q/100",pic_url,@((int)(frame.size.width*[[UIScreen mainScreen] scale])),@((int)(frame.size.height*[[UIScreen mainScreen] scale]))];
    [picBtn sd_setImageWithURL:[NSURL URLWithString:pic_thumb_url] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"Loading_PlaceHolder"]];
    picBtn.imageView.contentMode=UIViewContentModeScaleToFill;
    picBtn.backgroundColor=MKRGBA(226,226,226,255);
    [self addSubview:picBtn];
    self.userInteractionEnabled=NO;
    
    CGRect frame1 = self.frame;
    frame1.size = frame.size;
    self.frame = frame1;
}

+ (CGSize)sizeOfChatMessageView:(MessageModel *)msg contentEmojiLbl:(MLEmojiLabel *)contentEmojiLbl{
    NSString *pic_url=msg.image;//20141225164012_400_600.png
    
    CGFloat width=kImgMaxWidth;
    CGFloat height=kImgMaxHeight;
    if (pic_url && pic_url.length>0) {
        NSString *fileName=[pic_url stringByDeletingPathExtension];
        NSArray *tmp=[fileName componentsSeparatedByString:@"_"];
        if (tmp.count==3) {
            CGFloat imageWidth=[tmp[1] integerValue];
            CGFloat imageHeight=[tmp[2] integerValue];
            
            CGFloat hScaleFactor = imageWidth / width;
            CGFloat vScaleFactor = imageHeight / height;
            
            if (hScaleFactor>=1 || vScaleFactor>=1) {//缩小
                CGFloat scaleFactor = MAX(hScaleFactor, vScaleFactor);
                
                width = imageWidth   / scaleFactor;
                height = imageHeight / scaleFactor;
            }
            else{//不放大，用原图
                width = imageWidth;
                height = imageHeight;
            }
        }
    }
    
    return CGSizeMake(width, height);
}

- (void)showDetail {
    __block NSInteger currentPhotoIndex=0;
    [_photos removeAllObjects];
    
    FriendTalkViewController *parentVC=(FriendTalkViewController *)[self getViewController];
    [parentVC.searchList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        MessageModel *msg = (MessageModel *)obj;
        
        if (msg.msg_type==2) {//图片
            MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:msg.image]];
            //photo.caption = @"图片描述";
            [_photos addObject:photo];
            
            if (msg.msgid==self.message.msgid) {
                currentPhotoIndex=_photos.count-1;
            }
        }
    }];
    
    if (_photos.count>0) {
        // Create browser
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        browser.displayActionButton = YES;
        browser.displayNavArrows = YES;
        browser.displaySelectionButtons = NO;
        browser.alwaysShowControls = NO;
        browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
        browser.wantsFullScreenLayout = YES;
#endif
        browser.enableGrid = NO;
        browser.startOnGrid = NO;
        browser.enableSwipeToDismiss = YES;
        [browser setCurrentPhotoIndex:currentPhotoIndex];
        
        // Show
        // 1.Push
        [parentVC.navigationController pushViewController:browser animated:YES];
        // 2.Modal
//        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
//        nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//        [parentVC presentViewController:nc animated:YES completion:nil];
    }
}

#pragma mark - MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photos.count)
        return [_photos objectAtIndex:index];
    return nil;
}

//- (MWCaptionView *)photoBrowser:(MWPhotoBrowser *)photoBrowser captionViewForPhotoAtIndex:(NSUInteger)index{
//    MWPhoto *photo = [_photos objectAtIndex:index];
//    MWCaptionView *captionView = [[MWCaptionView alloc] initWithPhoto:photo];
//    return captionView;
//}

@end

@implementation ActivityChatMessageView

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)showMessage:(MessageModel *)msg contentEmojiLbl:(MLEmojiLabel *)contentEmojiLbl{
    [super showMessage:msg contentEmojiLbl:(MLEmojiLabel *)contentEmojiLbl];
    
    self.backgroundColor=[UIColor clearColor];
    CGRect frame = self.bounds;
    frame.size = [ActivityChatMessageView sizeOfChatMessageView:msg contentEmojiLbl:(MLEmojiLabel *)contentEmojiLbl];
    
    CGFloat x=4;
    //titleLabel
    UILabel *titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(x, 0, frame.size.width-x*2, 21)];
    titleLabel.text=msg.title;
    titleLabel.font=[UIFont systemFontOfSize:16];
    titleLabel.textColor=MKRGBA(66,66,66,255);
    titleLabel.backgroundColor=[UIColor clearColor];
    titleLabel.textAlignment=NSTextAlignmentLeft;
    titleLabel.numberOfLines=1;
    [self addSubview:titleLabel];
    //picBtn
    CGFloat width=60;
    CGFloat height=width;
    //http://docs.qiniutek.com/v3/api/foimg/#imageView
    //http://qiniuphotos.qiniudn.com/gogopher.jpg?imageView/2/w/300/h/400/q/100
    NSString *pic_thumb_url=[NSString stringWithFormat:@"%@?imageView/1/w/%@/h/%@/q/100",msg.image,@((int)(width*[[UIScreen mainScreen] scale])),@((int)(height*[[UIScreen mainScreen] scale]))];
    UIButton *picBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    picBtn.frame=CGRectMake(x, 21+10, width, height);
    [picBtn sd_setImageWithURL:[NSURL URLWithString:pic_thumb_url] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"Loading_PlaceHolder"]];
    picBtn.imageView.contentMode=UIViewContentModeScaleToFill;
    picBtn.backgroundColor=MKRGBA(226,226,226,255);
    [self addSubview:picBtn];
    picBtn.userInteractionEnabled=NO;
    //contentLabel
    CGSize size = [msg.content adjustSizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(frame.size.width-(x)*2-width-10, MAXFLOAT)];
    UILabel *contentLabel=[[UILabel alloc] initWithFrame:CGRectMake(x+width+10, 21+10, frame.size.width-(x)*2-width-10, size.height>height?height:size.height)];
    contentLabel.text=msg.content;
    contentLabel.font=[UIFont systemFontOfSize:13];
    contentLabel.textColor=MKRGBA(98,98,98,255);
    contentLabel.backgroundColor=[UIColor clearColor];
    contentLabel.textAlignment=NSTextAlignmentLeft;
    if (size.height>height) {
        contentLabel.numberOfLines=4;
    }
    else{
        contentLabel.numberOfLines=0;
    }
    [self addSubview:contentLabel];
    self.userInteractionEnabled=NO;
    
    CGRect frame1 = self.frame;
    frame1.size = frame.size;
    self.frame = frame1;
}

+ (CGSize)sizeOfChatMessageView:(MessageModel *)msg contentEmojiLbl:(MLEmojiLabel *)contentEmojiLbl{
    CGFloat maxWidth=CHAT_MSG_WIDTH;
    CGFloat height=0;
    
    //titleLabel
    height+=21+10;
    //picBtn
    //60
    //contentLabel
    height+=60;
    
    return CGSizeMake(maxWidth, height);
}

- (void)showDetail {
//    BaseViewController *parentVC=(BaseViewController *)[self getViewController];//通过UIView获取它的UIViewController
//    
//    NSURL *url=[NSURL URLWithString:self.message.page_url];
//    NSDictionary *params=[[url query] queryDictionaryUsingEncoding:NSUTF8StringEncoding];
//    
//    Activity *record = [[Activity alloc] init];
//    record.activity_id=[params[@"id"] integerValue];
//    ActivityDetaiViewController *vc=[[ActivityDetaiViewController alloc] initWithRecord:record];
//    [[parentVC navigationController] pushViewController:vc animated:YES];
}

@end
