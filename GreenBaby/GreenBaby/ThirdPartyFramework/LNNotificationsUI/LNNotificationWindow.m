//
//  LNNotificationWindow.m
//  LNNotificationsUI
//
//  Created by LiXiangCheng on 14/12/1.
//  Copyright (c) 2014年 LiXiangCheng. All rights reserved.
//

#import "LNNotificationWindow.h"
#import "LNNotification.h"
#import "LNNotificationView.h"
#import "LNViewController.h"

static const NSTimeInterval LNNotificationAnimationDuration = 0.5;
static const NSTimeInterval LNNotificationFullDuration = 5.0;
static const NSTimeInterval LNNotificationCutOffDuration = 3.5;//delay

static const CGFloat LNNotificationViewHeight = 68.0;

extern NSString* const LNNotificationWasTappedNotification;

@implementation LNNotificationWindow
{
	LNNotificationView* _notificationView;
	UIView* _swipeView;
	BOOL _notificationViewShown;
	NSDate* _lastShowDate;
	UISwipeGestureRecognizer* _sgr;
	UITapGestureRecognizer* _tgr;
	
	NSLayoutConstraint* _topConstraint;
	
	void (^_pendingCompletionHandler)();
}

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if(self)
	{
		_notificationView = [[LNNotificationView alloc] initWithFrame:self.bounds];
		_notificationView.translatesAutoresizingMaskIntoConstraints = NO;
		
		self.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.0];

		LNViewController* vc = [LNViewController new];
		[vc.view addSubview:_notificationView];
		
		[vc.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_notificationView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_notificationView)]];

		_topConstraint = [NSLayoutConstraint constraintWithItem:_notificationView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:vc.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0];
		
		[vc.view addConstraint:_topConstraint];
		[vc.view addConstraint:[NSLayoutConstraint constraintWithItem:_notificationView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1.0 constant:LNNotificationViewHeight]];
		
		_topConstraint.constant = -LNNotificationViewHeight;
		
		_swipeView = [UIView new];
		_swipeView.translatesAutoresizingMaskIntoConstraints = NO;
		
		[vc.view addSubview:_swipeView];
		[vc.view sendSubviewToBack:_swipeView];
		
		_sgr = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(_dismissFromSwipe)];
		_sgr.direction = UISwipeGestureRecognizerDirectionUp;
		[_swipeView addGestureRecognizer:_sgr];
		
		_tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_userTappedNotification)];
		[_swipeView addGestureRecognizer:_tgr];
		
		[vc.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_swipeView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_swipeView)]];
		[vc.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_swipeView(68)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_swipeView)]];
		
		[self setRootViewController:vc];
		
		self.windowLevel = UIWindowLevelAlert + 2000;
	}
	
	return self;
}

- (BOOL)isNotificationViewShown
{
	return _notificationViewShown;
}

- (void)presentNotification:(LNNotification *)notification completionBlock:(void (^)())completionBlock
{
	NSDate* targetDate;
 
	if(_lastShowDate == nil)
	{
		targetDate = [NSDate date];
	}
	else
	{
		targetDate = [_lastShowDate dateByAddingTimeInterval:LNNotificationCutOffDuration];
	}
	
	NSTimeInterval delay = [targetDate timeIntervalSinceDate:[NSDate date]];
	if(delay < 0)
	{
		delay = 0;
	}
	
	if(!_notificationViewShown)
	{
		[_notificationView configureForNotification:notification];
		
		_topConstraint.constant = -LNNotificationViewHeight;
		[self layoutIfNeeded];
		
		[UIView animateWithDuration:LNNotificationAnimationDuration delay:delay usingSpringWithDamping:500 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			_topConstraint.constant = 0;
			[self layoutIfNeeded];
		} completion:^(BOOL finished) {
			_lastShowDate = [NSDate date];
			_notificationViewShown = YES;
			
			_pendingCompletionHandler = completionBlock;
			
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(LNNotificationCutOffDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				if(_pendingCompletionHandler)
				{
					void (^prevPendingCompletionHandler)() = _pendingCompletionHandler;
					_pendingCompletionHandler = nil;
					prevPendingCompletionHandler();
				}
			});
		}];
	}
	else
	{
		UIView* snapshot = [_notificationView.notificationContentView snapshotViewAfterScreenUpdates:NO];
		
		__block CGRect frame = _notificationView.notificationContentView.frame;
		frame.origin.y = -frame.size.height;
		_notificationView.notificationContentView.frame = frame;
		[_notificationView configureForNotification:notification];
		
		[_notificationView.notificationContentView.superview insertSubview:snapshot belowSubview:_notificationView.notificationContentView];
		
		
		
		[UIView animateWithDuration:0.75 * LNNotificationAnimationDuration delay:delay usingSpringWithDamping:500 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
			frame.origin.y = 0;
			_notificationView.notificationContentView.frame = frame;
			snapshot.alpha = 0;
		} completion:^(BOOL finished) {
			[snapshot removeFromSuperview];
			_lastShowDate = [NSDate date];
			
			_pendingCompletionHandler = completionBlock;
			
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(LNNotificationCutOffDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
				if(_pendingCompletionHandler)
				{
					void (^prevPendingCompletionHandler)() = _pendingCompletionHandler;
					_pendingCompletionHandler = nil;
					prevPendingCompletionHandler();
				}
			});
		}];
	}
}

- (void)dismissNotificationViewWithCompletionBlock:(void (^)())completionBlock
{
	[self _dismissNotificationViewWithCompletionBlock:completionBlock force:NO];
}

- (void)_dismissNotificationViewWithCompletionBlock:(void (^)())completionBlock force:(BOOL)forced
{
	if(_notificationViewShown == NO)
	{
		return;
	}
	
	NSDate* targetDate = [_lastShowDate dateByAddingTimeInterval:LNNotificationFullDuration];
	
	NSTimeInterval delay = [targetDate timeIntervalSinceDate:[NSDate date]];
	
	if(forced == YES)
	{
		delay = 0;
	}
	
	[_notificationView.layer removeAllAnimations];
	
	_pendingCompletionHandler = completionBlock;
	
	_topConstraint.constant = 0;
	[self layoutIfNeeded];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		_notificationViewShown = NO;
	});
	
	[UIView animateWithDuration:LNNotificationAnimationDuration delay:delay usingSpringWithDamping:500 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
		_topConstraint.constant = -LNNotificationViewHeight;
		[self layoutIfNeeded];
	} completion:^(BOOL finished) {
		_lastShowDate = nil;
		_notificationViewShown = NO;
		[_notificationView configureForNotification:nil];
		
		if(_pendingCompletionHandler)
		{
			void (^prevPendingCompletionHandler)() = _pendingCompletionHandler;
			_pendingCompletionHandler = nil;
			prevPendingCompletionHandler();
		}
	}];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	UIView* rv = [super hitTest:point withEvent:event];
	
	if(rv == self || rv == self.rootViewController.view)
	{
		return nil;
	}
	
	if(rv == _swipeView && _notificationViewShown == NO)
	{
		return nil;
	}
	
	return rv;
}

- (void)_dismissFromSwipe
{
	[self _dismissNotificationViewWithCompletionBlock:_pendingCompletionHandler force:YES];
}

- (void)_userTappedNotification
{
	[self _dismissNotificationViewWithCompletionBlock:_pendingCompletionHandler force:YES];
	
	if(_notificationView.currentNotification != nil)
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:LNNotificationWasTappedNotification object:_notificationView.currentNotification];
	}
}


@end
