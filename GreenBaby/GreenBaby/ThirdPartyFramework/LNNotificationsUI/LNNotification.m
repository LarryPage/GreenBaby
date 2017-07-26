//
//  LNNotification.m
//  LNNotificationsUI
//
//  Created by LiXiangCheng on 14/12/1.
//  Copyright (c) 2014年 LiXiangCheng. All rights reserved.
//

#import "LNNotification.h"

@implementation LNNotification

+ (BOOL)supportsSecureCoding
{
	return YES;
}

+ (instancetype)notificationWithMessage:(NSString*)message
{
	return [[LNNotification alloc] initWithTitle:nil message:message icon:nil date:[NSDate date]];
}

+ (instancetype)notificationWithTitle:(NSString*)title message:(NSString*)message
{
	return [[LNNotification alloc] initWithTitle:title message:message icon:nil date:[NSDate date]];
}

+ (instancetype)notificationWithTitle:(NSString*)title message:(NSString*)message icon:(UIImage*)icon date:(NSDate*)date
{
	return [[LNNotification alloc] initWithTitle:title message:message icon:icon date:date];
}

- (instancetype)initWithMessage:(NSString*)message
{
	return [self initWithTitle:nil message:message icon:nil date:[NSDate date]];
}

- (instancetype)initWithTitle:(NSString*)title message:(NSString*)message
{
	return [self initWithTitle:title message:message icon:nil date:[NSDate date]];
}

- (instancetype)initWithTitle:(NSString*)title message:(NSString*)message icon:(UIImage*)icon date:(NSDate*)date
{
	self = [super init];
	if(self)
	{
		self.title = title;
		self.message = message;
		self.icon = icon;
		self.date = date;
		self.displaysWithRelativeDateFormatting = YES;
//		self.alertAction = NSLocalizedString(@"View", @"");
	}
	return self;
}

- (instancetype)init{
    return [self init];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
	self = [super init];
	if(self)
	{
		self.title = [coder decodeObjectOfClass:[NSString class] forKey:@"title"];
		self.message = [coder decodeObjectOfClass:[NSString class] forKey:@"message"];
		self.icon = [coder decodeObjectOfClass:[NSString class] forKey:@"icon"];
		self.date = [coder decodeObjectOfClass:[NSString class] forKey:@"date"];
		self.displaysWithRelativeDateFormatting = [coder decodeBoolForKey:@"displaysWithRelativeDate"];
//		self.alertAction = [coder decodeObjectOfClass:[NSString class] forKey:@"alertAction"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:self.title forKey:@"title"];
	[aCoder encodeObject:self.message forKey:@"message"];
	[aCoder encodeObject:self.icon forKey:@"icon"];
	[aCoder encodeObject:self.date forKey:@"date"];
	[aCoder encodeBool:self.displaysWithRelativeDateFormatting forKey:@"displaysWithRelativeDate"];
//	[aCoder encodeObject:self.alertAction forKey:@"alertAction"];
}

- (id)copyWithZone:(NSZone *)zone
{
	LNNotification* copy = [[LNNotification allocWithZone:zone] initWithTitle:self.title message:self.message icon:self.icon date:self.date];
	copy.displaysWithRelativeDateFormatting = self.displaysWithRelativeDateFormatting;
	
	return copy;
}

@end
