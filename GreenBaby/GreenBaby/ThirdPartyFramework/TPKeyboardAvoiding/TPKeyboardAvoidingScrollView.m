//
//  TPKeyboardAvoidingScrollView.m
//
//  Created by Michael Tyson on 11/04/2011.
//  Copyright 2011 A Tasty Pixel. All rights reserved.
//

#import "TPKeyboardAvoidingScrollView.h"

#define _UIKeyboardFrameEndUserInfoKey (&UIKeyboardFrameEndUserInfoKey != NULL ? UIKeyboardFrameEndUserInfoKey : @"UIKeyboardBoundsUserInfoKey")

const CGFloat kCalculatedContentPadding = 10;

@interface TPKeyboardAvoidingScrollView () <UITextFieldDelegate, UITextViewDelegate> {
    UIEdgeInsets    _priorInset;
    UIEdgeInsets    _priorScrollIndicatorInsets;
    BOOL            _keyboardVisible;
    CGRect          _keyboardRect;
    CGSize          _contentsSize;
    CGSize          _priorContentSize;
}
- (UIView*)findFirstResponderBeneathView:(UIView*)view;
- (UIEdgeInsets)contentInsetForKeyboard;
- (CGFloat)idealOffsetForView:(UIView *)view withSpace:(CGFloat)space;
- (CGRect)keyboardRect;
@end

@implementation TPKeyboardAvoidingScrollView

#pragma mark - Setup/Teardown

- (void)setup {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    NSString *versions = [[UIDevice currentDevice] systemVersion];
    if ([versions compare:@"5.0"] != NSOrderedAscending ) { // iOS5.0以降の判定
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMode:) name:UITextInputCurrentInputModeDidChangeNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
    }
}

-(id)initWithFrame:(CGRect)frame {
    if ( !(self = [super initWithFrame:frame]) ) return nil;
    [self setup];
    return self;
}

-(void)awakeFromNib {
    [self setup];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if ( _keyboardVisible ) {
        self.contentInset = [self contentInsetForKeyboard];
    }
}

-(void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
    if ( _keyboardVisible ) {
		_priorContentSize = self.contentSize;
        self.contentInset = [self contentInsetForKeyboard];
    }
}

-(void)didAddSubview:(UIView *)subview {
    _contentsSize = [self contentsSizeFromSubviewFrames];
}

#pragma mark - Responders, events

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self findFirstResponderBeneathView:self] resignFirstResponder];
    [super touchesEnded:touches withEvent:event];
}

- (void)keyboardWillShow:(NSNotification*)notification {
    if ( CGSizeEqualToSize(self.contentSize, CGSizeZero) ) {
        // Set the content size, if it's not set
        self.contentSize = CGSizeMake(_contentsSize.width, _contentsSize.height + kCalculatedContentPadding);
    }
    
    _keyboardRect = [[[notification userInfo] objectForKey:_UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardVisible = YES;
    
    UIView *firstResponder = [self findFirstResponderBeneathView:self];
    if ( !firstResponder ) {
        // No child view is the first responder - nothing to do here
        return;
    }
    
    _priorInset = self.contentInset;
    _priorScrollIndicatorInsets = self.scrollIndicatorInsets;
    _priorContentSize = self.contentSize;
    
    // Shrink view's inset by the keyboard's height, and scroll to show the text field/view being edited
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    

    
    self.contentInset = [self contentInsetForKeyboard];
    
    [self setContentOffset:CGPointMake(self.contentOffset.x,
                                       [self idealOffsetForView:firstResponder withSpace:[self keyboardRect].origin.y - self.bounds.origin.y])
                  animated:YES];
    [self setScrollIndicatorInsets:self.contentInset];
    
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    _keyboardRect = CGRectZero;
    _keyboardVisible = NO;
    
    // Restore dimensions to prior size
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    self.contentSize = _priorContentSize;
    self.contentInset = _priorInset;
    self.scrollIndicatorInsets = _priorScrollIndicatorInsets;
    [UIView commitAnimations];
}

#pragma mark - UITextInputCurrentInputModeDidChangeNotification
-(void) changeMode:(NSNotification *)notification{
    //CLog(@"%@",[[UITextInputMode currentInputMode] primaryLanguage]);
    
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
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardRect=keyboardRect;
    //CLog(@"keyboardFrameWillChange:True");
    
    _keyboardVisible = YES;
    
    UIView *firstResponder = [self findFirstResponderBeneathView:self];
    if ( !firstResponder ) {
        // No child view is the first responder - nothing to do here
        return;
    }
    
    _priorInset = self.contentInset;
    _priorScrollIndicatorInsets = self.scrollIndicatorInsets;
    _priorContentSize = self.contentSize;
    
    // Shrink view's inset by the keyboard's height, and scroll to show the text field/view being edited
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:[[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue]];
    [UIView setAnimationDuration:[[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue]];
    
    
    
    self.contentInset = [self contentInsetForKeyboard];
    
    [self setContentOffset:CGPointMake(self.contentOffset.x,
                                       [self idealOffsetForView:firstResponder withSpace:[self keyboardRect].origin.y - self.bounds.origin.y])
                  animated:YES];
    [self setScrollIndicatorInsets:self.contentInset];
    
    [UIView commitAnimations];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ( ![self focusNextTextField] ) {
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    [self scrollToActiveTextField];
}

-(void)textViewDidBeginEditing:(UITextView *)textView {
    [self scrollToActiveTextField];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self initializeViewsBeneathView:self];
}

#pragma mark - Utilities

- (BOOL)focusNextTextField {
    UIView *firstResponder = [self findFirstResponderBeneathView:self];
    if ( !firstResponder ) {
        return NO;
    }
    
    CGFloat minY = CGFLOAT_MAX;
    UIView *view = nil;
    [self findTextFieldAfterTextField:firstResponder beneathView:self minY:&minY foundView:&view];
    
    if ( view ) {
        [view becomeFirstResponder];
        return YES;
    }
    
    return NO;
}

-(void)scrollToActiveTextField {
    if ( !_keyboardVisible ) return;
    
    CGFloat visibleSpace = self.bounds.size.height - self.contentInset.top - self.contentInset.bottom;
    
    CGPoint idealOffset = CGPointMake(0, [self idealOffsetForView:[self findFirstResponderBeneathView:self] withSpace:visibleSpace]);
    
    [self setContentOffset:idealOffset animated:YES];
}

#pragma mark - Helpers

- (UIView*)findFirstResponderBeneathView:(UIView*)view {
    // Search recursively for first responder
    for ( UIView *childView in view.subviews ) {
        if ( [childView respondsToSelector:@selector(isFirstResponder)] && [childView isFirstResponder] ) return childView;
        UIView *result = [self findFirstResponderBeneathView:childView];
        if ( result ) return result;
    }
    return nil;
}

- (void)findTextFieldAfterTextField:(UIView*)priorTextField beneathView:(UIView*)view minY:(CGFloat*)minY foundView:(UIView**)foundView {
    // Search recursively for text field or text view below priorTextField
    CGFloat priorFieldOffset = CGRectGetMinY([self convertRect:priorTextField.frame fromView:priorTextField.superview]);
    for ( UIView *childView in view.subviews ) {
        if ( childView.hidden ) continue;
        if ( ([childView isKindOfClass:[UITextField class]] || [childView isKindOfClass:[UITextView class]]) ) {
            CGRect frame = [self convertRect:childView.frame fromView:view];
            if ( childView != priorTextField && CGRectGetMinY(frame) >= priorFieldOffset && CGRectGetMinY(frame) < *minY ) {
                *minY = CGRectGetMinY(frame);
                *foundView = childView;
            }
        } else {
            [self findTextFieldAfterTextField:priorTextField beneathView:childView minY:minY foundView:foundView];
        }
    }
}

- (void)initializeViewsBeneathView:(UIView*)view {
    for ( UIView *childView in view.subviews ) {
        if ( ([childView isKindOfClass:[UITextField class]] || [childView isKindOfClass:[UITextView class]]) ) {
            [self initializeView:childView];
        } else {
            [self initializeViewsBeneathView:childView];
        }
    }
}

-(CGSize)contentsSizeFromSubviewFrames {
    CGRect rect = CGRectZero;
    for ( UIView *view in self.subviews ) {
        rect = CGRectUnion(rect, view.frame);
    }
    return rect.size;
}

- (UIEdgeInsets)contentInsetForKeyboard {
    UIEdgeInsets newInset = self.contentInset;
    CGRect keyboardRect = [self keyboardRect];
    newInset.bottom = keyboardRect.size.height - ((keyboardRect.origin.y+keyboardRect.size.height) - (self.bounds.origin.y+self.bounds.size.height));
    return newInset;
}

-(CGFloat)idealOffsetForView:(UIView *)view withSpace:(CGFloat)space {
    
    // Convert the rect to get the view's distance from the top of the scrollView.
    CGRect rect = [view convertRect:view.bounds toView:self];
    
    // Set starting offset to that point
    CGFloat offset = rect.origin.y;
    
    
    if ( self.contentSize.height - offset < space ) {
        // Scroll to the bottom
        offset = self.contentSize.height - space;
    } else {
        if ( view.bounds.size.height < space ) {
            // Center vertically if there's room
            offset -= floor((space-view.bounds.size.height)/2.0);
        }
        if ( offset + space > self.contentSize.height ) {
            // Clamp to content size
            offset = self.contentSize.height - space;
        }
    }
    
    if (offset < 0) offset = 0;
    
    return offset;
}

- (CGRect)keyboardRect {
    CGRect keyboardRect = [self convertRect:_keyboardRect fromView:nil];
    if ( keyboardRect.origin.y == 0 ) {
        CGRect screenBounds = [self convertRect:[UIScreen mainScreen].bounds fromView:nil];
        keyboardRect.origin = CGPointMake(0, screenBounds.size.height - keyboardRect.size.height);
    }
    return keyboardRect;
}

- (void)initializeView:(UIView*)view {
    if ( [view isKindOfClass:[UITextField class]] ) {
        if (![((UITextField*)view) delegate] || [((UITextField*)view)delegate] == self) {
            [((UITextField*)view) setDelegate:self];
            
            UIView *otherView = nil;
            CGFloat minY = CGFLOAT_MAX;
            [self findTextFieldAfterTextField:view beneathView:self minY:&minY foundView:&otherView];
            
            if ( otherView ) {
                ((UITextField*)view).returnKeyType = UIReturnKeyNext;
            } else {
                ((UITextField*)view).returnKeyType = UIReturnKeyDone;
            }
        }
    }
    else if ( [view isKindOfClass:[UITextView class]] ) {
        if (![((UITextView*)view) delegate] || [((UITextView*)view)delegate] == self) {
            [((UITextView*)view) setDelegate:self];
        }
    }
}

@end
