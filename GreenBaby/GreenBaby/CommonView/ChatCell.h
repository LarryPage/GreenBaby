//
//  ChatCell.h
//  RRLT
//
//  Created by 香成 李 on 12-5-2８.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MapKit/MKMapView.h>
#import <MapKit/MKPinAnnotationView.h>
#import "MapViewController.h"
#import "CallViewController.h"
#import "SVWebViewController.h"
#import "EmailViewController.h"
#import "WebViewController.h"

#import "FriendTalkViewController.h"
#import "TimeHeaderView.h"
#import "MLEmojiLabel.h"
#import "MessageModel.h"
#import "UserModel.h"
//#import "UserDetailViewController.h"
//#import "ActivityDetaiViewController.h"

#define CHAT_MSG_CELL_PAD 20//两个cell间距

#define CHAT_ARROW_WIDTH 3.0//箭头的尺寸是6px

#define CHAT_MSG_V_PAD 10
#define CHAT_MSG_H_PAD 10
#define CHAT_MSG_WIDTH [[UIScreen mainScreen] bounds].size.width-60-60/2-CHAT_MSG_H_PAD*2-CHAT_ARROW_WIDTH//内容最大宽度:188
#define CHAT_MSG_HEIGHT 25//最小值

@interface ChatCell : UITableViewCell
@property (nonatomic, strong) MessageModel *message;
- (void)showMessage:(MessageModel *)msg contentEmojiLbl:(MLEmojiLabel *)contentEmojiLbl isRight:(Boolean)isRight shouldShowTime:(Boolean)shouldShowTime;
+ (NSInteger)calcCellHeight:(MessageModel *)msg contentEmojiLbl:(MLEmojiLabel *)contentEmojiLbl shouldShowTime:(Boolean)shouldShowTime;
- (IBAction)showDetail:(id)sender;
@end

@interface BaseChatMessageView : UIView {
}
@property (nonatomic, strong) MessageModel *message;
- (void)showMessage:(MessageModel *)msg contentEmojiLbl:(MLEmojiLabel *)contentEmojiLbl;
+ (CGSize)sizeOfChatMessageView:(MessageModel *)msg contentEmojiLbl:(MLEmojiLabel *)contentEmojiLbl;
- (void)showDetail;
@end

@interface TextChatMessageView : BaseChatMessageView <MLEmojiLabelDelegate,MFMailComposeViewControllerDelegate>{
}

- (void)DisplayAlertWithTitle:(NSString *)title message:(NSString *)message;
@end

@interface PhotoChatMessageView : BaseChatMessageView<MWPhotoBrowserDelegate>{
    NSMutableArray *_photos;
}
@end

@interface ActivityChatMessageView : BaseChatMessageView{
}
@end
