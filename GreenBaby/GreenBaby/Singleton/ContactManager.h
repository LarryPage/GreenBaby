//
//  ContactManager.h
//  MobileResume
//
//  Created by LiXiangCheng on 14-4-8.
//  Copyright (c) 2014年 人人猎头. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

// Notification
#define ContactReadFinished	@"ContactReadFinished"

@interface ContactManager : NSObject
{
    ABAddressBookRef addressBook;
    
    NSMutableArray* mContacts;
    NSCondition*     condition;
    NSCondition*     deadCondition;
    NSLock*          lock;
    BOOL             bExisted;
}

@property (nonatomic,strong) NSMutableArray* mContacts;
@property (nonatomic,strong) NSCondition*     condition;
@property (nonatomic, assign)BOOL   bExisted;

SINGLETON_DEF(ContactManager)

- (ABAddressBookRef)addressBook;
-(void)reSetContact;
-(NSMutableArray*)getContacts;
-(BOOL)isContactReady;
-(void)stopThread;

@end

