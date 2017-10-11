//
//  LNNotificationCenter.m
//  LNNotificationsUI
//
//  Created by LiXiangCheng on 14/12/1.
//  Copyright (c) 2014年 LiXiangCheng. All rights reserved.
//

#import "LNNotificationCenter.h"
#import "LNNotification.h"
#import "LNNotificationWindow.h"

static LNNotificationCenter* __ln_defaultNotificationCenter;

static const NSString* _nameKey = @"LNNotificationCenterAppNameKey";
static const NSString* _iconKey = @"LNNotificationCenterAppIconKey";

NSString* const LNNotificationWasTappedNotification = @"LNNotificationWasTappedNotification";;

@implementation LNNotificationCenter
{
	NSMutableDictionary* _applicationMapping;
	LNNotificationWindow* _notificationWindow;
	NSMutableArray* _pendingNotifications;
	
	BOOL _currentlyAnimating;
}

+ (instancetype)defaultCenter
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		__ln_defaultNotificationCenter = [LNNotificationCenter new];
	});
	
	return __ln_defaultNotificationCenter;
}

- (instancetype)init
{
	self = [super init];
	if(self)
	{
		_applicationMapping = [NSMutableDictionary new];
		_pendingNotifications = [NSMutableArray new];
	}
	return self;
}

- (void)registerApplicationWithIdentifier:(NSString*)appIdentifer name:(NSString*)name icon:(UIImage*)icon
{
	NSParameterAssert(appIdentifer != nil);
	NSParameterAssert(name != nil);
	
    _applicationMapping[appIdentifer] = [NSDictionary dictionaryWithObjectsAndKeys:name,_nameKey,icon?icon:[UIImage imageNamed:@"EH_Icon"],_iconKey, nil];
}

- (void)presentNotification:(LNNotification*)notification forApplicationIdentifier:(NSString*)appIdentifer
{
	NSParameterAssert(_applicationMapping[appIdentifer] != nil);
	NSParameterAssert(notification.message != nil);
	
	LNNotification* pendingNotification = [notification copy];
	
	pendingNotification.title = notification.title ? notification.title : _applicationMapping[appIdentifer][_nameKey];
	pendingNotification.icon = notification.icon ? notification.icon : _applicationMapping[appIdentifer][_iconKey];

	[_pendingNotifications addObject:pendingNotification];

	[self _handlePendingNotifications];
}

- (void)_handlePendingNotifications
{
	if(_notificationWindow == nil)
	{
		_notificationWindow = [[LNNotificationWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
		
		[_notificationWindow setHidden:NO];
	}
	
	if(_currentlyAnimating)
	{
		return;
	}
	
	_currentlyAnimating = YES;
	
    void(^block)(void) = ^ {
		_currentlyAnimating = NO;
		
		[self _handlePendingNotifications];
	};
	
	if(_pendingNotifications.count == 0)
	{
		if(![_notificationWindow isNotificationViewShown])
		{
			_currentlyAnimating = NO;
			return;
		}
		
		[_notificationWindow dismissNotificationViewWithCompletionBlock:block];
	}
	else
	{
		LNNotification* notification = _pendingNotifications.firstObject;
		[_pendingNotifications removeObjectAtIndex:0];
		
		[_notificationWindow presentNotification:notification completionBlock:block];
	}
}

@end
