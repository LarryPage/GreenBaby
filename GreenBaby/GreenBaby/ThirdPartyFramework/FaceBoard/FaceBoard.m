//
//  FaceBoard.m
//
//  Created by blue on 12-9-26.
//  Copyright (c) 2012年 blue. All rights reserved.
//  Email - 360511404@qq.com
//  http://github.com/bluemood

#import "FaceBoard.h"

#define FACE_COUNT_ALL  85
#define FACE_COUNT_ROW  4
#define FACE_COUNT_CLU  7
#define FACE_COUNT_PAGE ( FACE_COUNT_ROW * FACE_COUNT_CLU )
#define FACE_ICON_SIZE  44

@interface FaceBoard ()<UIScrollViewDelegate>{
    NSDictionary *_faceMap;
    
    UIScrollView *_faceView;
    GrayPageControl *_facePageControl;
}
@end

@implementation FaceBoard

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, 320, 216)];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:243.0/255.0 green:243.0/255.0 blue:243.0/255.0 alpha:1];
//        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//        NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
//        if ([[languages objectAtIndex:0] hasPrefix:@"zh"]) {
//            _faceMap = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"faceMap_ch" ofType:@"plist"]];
//        } else {
//            _faceMap = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"faceMap_en" ofType:@"plist"]];
//        }
        _faceMap=[Configs faceMap];
       
        //表情盘
        _faceView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, 190)];
        _faceView.pagingEnabled = YES;
        _faceView.contentSize = CGSizeMake((FACE_COUNT_ALL / FACE_COUNT_PAGE + 1) * 320, 190);
        _faceView.showsHorizontalScrollIndicator = NO;
        _faceView.showsVerticalScrollIndicator = NO;
        _faceView.delegate = self;
        
        for (int i = 1; i<=FACE_COUNT_ALL; i++) {
            UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
            faceButton.tag = i;
            
            [faceButton addTarget:self
                           action:@selector(faceButton:)
                 forControlEvents:UIControlEventTouchUpInside];
            
            //计算每一个表情按钮的坐标和在哪一屏
            CGFloat x = (((i - 1) % FACE_COUNT_PAGE) % FACE_COUNT_CLU) * FACE_ICON_SIZE + 6 + ((i - 1) / FACE_COUNT_PAGE * 320);
            CGFloat y = (((i - 1) % FACE_COUNT_PAGE) / FACE_COUNT_CLU) * FACE_ICON_SIZE + 8;
            faceButton.frame = CGRectMake( x, y, FACE_ICON_SIZE, FACE_ICON_SIZE);
            
            [faceButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%03d",i]] forState:UIControlStateNormal];
            [_faceView addSubview:faceButton];
        }
        
        //添加PageControl
        _facePageControl = [[GrayPageControl alloc]initWithFrame:CGRectMake(110, 190, 100, 20)];
        
        [_facePageControl addTarget:self
                             action:@selector(pageChange:)
                   forControlEvents:UIControlEventValueChanged];
        
        _facePageControl.numberOfPages = FACE_COUNT_ALL / FACE_COUNT_PAGE + 1;
        _facePageControl.currentPage = 0;
        [self addSubview:_facePageControl];
        
        //添加键盘View
        [self addSubview:_faceView];
        
        //删除键
        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        [back setTitle:@"删除" forState:UIControlStateNormal];
        [back setImage:[UIImage imageNamed:@"backFace"] forState:UIControlStateNormal];
        [back setImage:[UIImage imageNamed:@"backFaceSelect"] forState:UIControlStateSelected];
        [back addTarget:self action:@selector(backFace:) forControlEvents:UIControlEventTouchUpInside];
        back.frame = CGRectMake(270, 185, 38, 27);
        [self addSubview:back];
    }
    return self;
}

//停止滚动的时候
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [_facePageControl setCurrentPage:_faceView.contentOffset.x/320];
    [_facePageControl updateCurrentPageDisplay];
}

- (void)pageChange:(id)sender {
    [_faceView setContentOffset:CGPointMake(_facePageControl.currentPage*320, 0) animated:YES];
    [_facePageControl setCurrentPage:_facePageControl.currentPage];
}

- (void)faceButton:(id)sender {
    int i = (int)((UIButton*)sender).tag;
    if (self.inputTextField) {
        NSMutableString *faceString = [[NSMutableString alloc]initWithString:self.inputTextField.text];
        [faceString appendString:[_faceMap objectForKey:[NSString stringWithFormat:@"%03d",i]]];
        self.inputTextField.text = faceString;
    }
    if (self.inputTextView) {
        NSMutableString *faceString = [[NSMutableString alloc]initWithString:self.inputTextView.text];
        [faceString appendString:[_faceMap objectForKey:[NSString stringWithFormat:@"%03d",i]]];
        self.inputTextView.text = faceString;
    }
}

- (void)backFace:(id)sender {
    NSString *inputString;
    if (self.inputTextField) {
        inputString = self.inputTextField.text;
    }
    if (self.inputTextView) {
        inputString = self.inputTextView.text;
    }
    
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
                if ([[_faceMap allValues] indexOfObject:text]==NSNotFound) {
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
    
    if (self.inputTextField) {
        self.inputTextField.text = string;
    }
    if (self.inputTextView) {
        self.inputTextView.text = string;
        if (_delegate && [_delegate respondsToSelector:@selector(textViewDidChange:)]) {
            [_delegate textViewDidChange:self.inputTextView];
        }
    }
}

@end
