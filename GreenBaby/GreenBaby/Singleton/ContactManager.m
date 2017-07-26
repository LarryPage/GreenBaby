//
//  ContactManager.m
//  MobileResume
//
//  Created by LiXiangCheng on 14-4-8.
//  Copyright (c) 2014年 人人猎头. All rights reserved.
//

#import "ContactManager.h"

static NSThread* thread;

@implementation ContactManager

@synthesize mContacts;
@synthesize condition;
@synthesize bExisted;

SINGLETON_IMP(ContactManager)

void AddressBookExternalChangeCallback(ABAddressBookRef notifyAddressBook,CFDictionaryRef info,void *context);

-(id)init
{
    self = [super init];
    if (self) {
        float fSystemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        if(fSystemVersion >= 6.0f){// we're on iOS 6
            addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        }
        else{// we're on iOS 5 or older
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            addressBook = ABAddressBookCreate();
#pragma clang diagnostic pop
        }
        
        condition = [[NSCondition alloc] init];
        deadCondition = [[NSCondition alloc] init];
        lock = [[NSLock alloc] init];
        bExisted = YES;
        thread = [[NSThread alloc ] initWithTarget:self selector:@selector(getContactsFromSystem) object:nil];
        [thread start];
        //ABAddressBookRegisterExternalChangeCallback(addressBook, AddressBookExternalChangeCallback,self);
        
    }
    return self;
}

- (ABAddressBookRef)addressBook {
    if (addressBook == nil) {
		[ContactManager sharedInstance];
	}
	return addressBook;
}

-(void)stopThread
{
//    //[condition signal];
//    [deadCondition wait];
    condition = nil;
    deadCondition = nil;
    if(NULL != addressBook){
        //ABAddressBookUnregisterExternalChangeCallback(addressBook,AddressBookExternalChangeCallback,nil);
        CFRelease(addressBook);
    }
    lock = nil;
}

- (NSMutableArray *)allContacts {
	// 抓取所有联系人信息
	NSMutableArray *abArray = (__bridge NSMutableArray *)ABAddressBookCopyArrayOfAllPeople(addressBook);//accessGranted=NO,数组将为0
	NSMutableArray *contactArray = [[NSMutableArray alloc] init];
	for (id record in abArray) {
        NSMutableDictionary *contactDic = [NSMutableDictionary dictionary];
        
//        NSInteger recordID = ABRecordGetRecordID((__bridge ABRecordRef)(record));
//        BOOL isPerson = (ABRecordGetRecordType((__bridge ABRecordRef)(record)) == kABPersonType);
        
        NSString *fullname = (__bridge NSString *)ABRecordCopyCompositeName((__bridge ABRecordRef)(record));
        NSString *displayName=[fullname stringByReplacingOccurrencesOfString:@" " withString:@""];//将姓名间空格符去掉
        fullname=nil;
        [contactDic setValue:displayName?displayName:@"" forKey:@"displayName"];
        
        NSString *companyName = (__bridge NSString *)ABRecordCopyValue((__bridge ABRecordRef)(record), kABPersonOrganizationProperty);
        [contactDic setValue:companyName?companyName:@"" forKey:@"companyName"];
        companyName=nil;
        
        NSString *department = (__bridge NSString *)ABRecordCopyValue((__bridge ABRecordRef)(record), kABPersonDepartmentProperty);
        [contactDic setValue:department?department:@"" forKey:@"department"];
        department=nil;
        
        NSString *position = (__bridge NSString *)ABRecordCopyValue((__bridge ABRecordRef)(record), kABPersonJobTitleProperty);
        [contactDic setValue:position?position:@"" forKey:@"position"];
        position=nil;
        
        NSDictionary *emails = [self getEmailsByRecord:(__bridge ABRecordRef)(record)];
        NSString *defaultEmail=[self defaultEmail:emails];
        [contactDic setValue:defaultEmail?defaultEmail:@"" forKey:@"email"];
        
        NSDictionary *phones = [self getPhonesByRecord:(__bridge ABRecordRef)(record)];
        NSString *defaultPhone=[self mobile:phones];
        [contactDic setValue:defaultPhone?defaultPhone:@"" forKey:@"mobile"];
        
        
        [contactArray addObject:contactDic];
	}
	abArray=nil;
	return contactArray;
}

-(void)getContactsFromSystem
{
    @autoreleasepool {
        while (bExisted) {
            [condition lock];
            [condition wait];
            //NSMutableArray* pContacts = [[AddressBookManager defaultManager] allContacts];
            NSMutableArray* pContacts = [self allContacts];
            [lock lock];
            self.mContacts = pContacts;
            [lock unlock];
            [condition unlock];
            [[NSNotificationCenter defaultCenter] postNotificationName:ContactReadFinished object:nil];
        }
        NSLog(@"get  Contacts finished");
        [deadCondition signal];
    }
}

-(void)reSetContact{
    [lock lock];
    self.mContacts = nil;
    [lock unlock];
}

void AddressBookExternalChangeCallback(ABAddressBookRef notifyAddressBook,CFDictionaryRef info,void *context) {
    NSLog(@" MyAddressBookExternalChangeCallback ,info = %@",info);
	if (ABAddressBookHasUnsavedChanges(notifyAddressBook)) {
        // Not done saving changes, let's wait
        return;
    }
    
//    // Something changed in the address book
//    // Let's get the latest changes and reload
//    //[ContactManager sharedInstance] = context;
//    
//    ABAddressBookRevert(notifyAddressBook);
//    
//    CFArrayRef peopleRefs = ABAddressBookCopyArrayOfAllPeopleInSource(notifyAddressBook, kABSourceTypeLocal);
//    
//    CFIndex count = CFArrayGetCount(peopleRefs);
//    //NSMutableArray* people = [NSMutableArray arrayWithCapacity:count];
//    NSMutableDictionary* ABRecordDic = [ABRecord loadABRecordDic];
//    for (CFIndex i=0; i < count; i++){
//        ABRecordRef record = CFArrayGetValueAtIndex(peopleRefs, i);
//        //ABRecordID id_ = ABRecordGetRecordID(record);
//        NSInteger recordID = ABRecordGetRecordID(record);
//        NSDate *modifyDate = (NSDate *)ABRecordCopyValue(record, kABPersonModificationDateProperty);//2012-08-05 16:02:12 +0000
//        NSDate *curModifyDate = (NSDate *)[ABRecordDic valueForKey:[NSString stringWithFormat:@"%d",recordID]];
//        if (modifyDate && curModifyDate && [modifyDate isEqualToDate:curModifyDate]) {
//        }
//        else{
//            [ABRecord updateRecord:recordID modifyDate:modifyDate];
//            
//            CardBumpContact *contact = [CardBumpContact contactWithRecordRef:(ABRecordRef)record];
//            contact.type = @"private";
//            contact.uuid=[NSString stringWithFormat:@"ABAddressBook%d",contact.recordID];
//            //通过arc4random() 获取0到x-1之间的整数: arc4random() % x
//            NSInteger kCardSytleNumber= [kCardShowOrder count];
//            NSInteger randomIndex = (arc4random() % kCardSytleNumber);//真正不依靠同一时间为种子的随即函数
//            contact.style = [[kCardShowOrder objectAtIndex:randomIndex] integerValue];
//            //contact.style = 10001;
//            contact.avatar = [CardBumpContact getImageInRecord:record];
//            [ExchangeRecord updateRecordToHistory:contact];
//        }
//        [modifyDate release];
//    }
//    
//    CFRelease(peopleRefs);
    
    //重新扫描
    [[ContactManager sharedInstance] reSetContact];
    [[ContactManager sharedInstance].condition signal];
}

-(BOOL)isContactReady
{
    return ( mContacts != nil );
}

-(NSMutableArray*)getContacts
{
    if(mContacts == nil)
    {
        [condition signal];
        CLog(@"contacts is null, begin to get Contacts");
        return nil;
    }
    else
    {
        [lock lock];
        NSMutableArray* pMutableArray = [NSMutableArray arrayWithArray:mContacts];
        [lock unlock];
        return pMutableArray;
        
    }
}

#pragma mark utilities

- (NSDictionary *)getEmailsByRecord:(ABRecordRef)record {
	ABMultiValueRef emailValues = ABRecordCopyValue(record, kABPersonEmailProperty);
	NSMutableDictionary *emailDic = [NSMutableDictionary dictionary];
	NSInteger emailCount = ABMultiValueGetCount(emailValues);
	for (int i=0; i<emailCount; i++) {
		NSString *emailKey = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(emailValues, i);
		NSString *emailValue = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emailValues, i);
		if ([emailKey isEqualToString:@"_$!<Home>!$_"]) {
			[emailDic setValue:emailValue forKey:@"home"];
		} else if ([emailKey isEqualToString:@"_$!<Work>!$_"]) {
			[emailDic setValue:emailValue forKey:@"work"];
		} else {
			[emailDic setValue:emailValue forKey:@"other"];
		}
		emailKey=nil;
		emailValue=nil;
	}
	CFRelease(emailValues);
	
	return emailDic;
}

- (NSDictionary *)getPhonesByRecord:(ABRecordRef)record {
	ABMultiValueRef phoneValues = ABRecordCopyValue(record, kABPersonPhoneProperty);
	NSMutableDictionary *phoneDic = [NSMutableDictionary dictionary];
	NSInteger phoneCount = ABMultiValueGetCount(phoneValues);
	for (int i=0; i<phoneCount; i++) {
		NSString *phoneKey = (__bridge NSString *)ABMultiValueCopyLabelAtIndex(phoneValues, i);
		NSString *phoneValue = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phoneValues, i);
        
        NSCharacterSet *nonNumbers = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
        NSString *truePhoneValue = [[phoneValue componentsSeparatedByCharactersInSet:nonNumbers] componentsJoinedByString:@""];
        if ([truePhoneValue hasPrefix:@"086"]) {
            truePhoneValue=[truePhoneValue substringFromIndex:3];
        }
        
		if ([phoneKey isEqualToString:@"_$!<Mobile>!$_"]) {
			[phoneDic setValue:truePhoneValue forKey:@"mobile"];
		} else if ([phoneKey isEqualToString:@"iPhone"]) {
			[phoneDic setValue:truePhoneValue forKey:@"workmobile"];
		} else if ([phoneKey isEqualToString:@"_$!<HomeFAX>!$_"]) {
			[phoneDic setValue:truePhoneValue forKey:@"homefax"];
		} else if ([phoneKey isEqualToString:@"_$!<WorkFAX>!$_"]) {
			[phoneDic setValue:truePhoneValue forKey:@"workfax"];
		} else if ([phoneKey isEqualToString:@"_$!<Home>!$_"]) {
			[phoneDic setValue:truePhoneValue forKey:@"hometel"];
		} else if ([phoneKey isEqualToString:@"_$!<CompanyMain>!$_"]) {
			[phoneDic setValue:truePhoneValue forKey:@"companytel"];
		} else if ([phoneKey isEqualToString:@"_$!<Pager>!$_"]) {
			[phoneDic setValue:truePhoneValue forKey:@"worktel"];
		} else {
			[phoneDic setValue:truePhoneValue forKey:@"other"];
		}
		phoneKey=nil;
		phoneValue=nil;
	}
	CFRelease(phoneValues);
	
	return phoneDic;
}

- (NSString *)defaultEmail:(NSDictionary *)emails {
	for (NSString *emailKey in [emails allKeys]) {
		return [emails valueForKey:emailKey];
	}
	return @"";
}

- (NSString *)mobile:(NSDictionary *)phones {
	/*a) mobile:移动手机
	 b) workmobile:工作手机
	 c) homefax:家庭传真
	 d) workfax:工作传真
	 e) hometel:住宅电话
	 f) companytel:公司主机
	 g) worktel:工作电话
	 h) other:其他电话*/
	if ([phones valueForKey:@"mobile"]) {
		return [phones valueForKey:@"mobile"];
	}
	
	if ([phones valueForKey:@"workmobile"]) {
		return [phones valueForKey:@"workmobile"];
	}
	
	if ([phones valueForKey:@"homefax"]) {
		return [phones valueForKey:@"homefax"];
	}
	
	if ([phones valueForKey:@"workfax"]) {
		return [phones valueForKey:@"workfax"];
	}
	
	if ([phones valueForKey:@"hometel"]) {
		return [phones valueForKey:@"hometel"];
	}
	
	if ([phones valueForKey:@"companytel"]) {
		return [phones valueForKey:@"companytel"];
	}
	
	if ([phones valueForKey:@"worktel"]) {
		return [phones valueForKey:@"worktel"];
	}
	
	if ([phones valueForKey:@"other"]) {
		return [phones valueForKey:@"other"];
	}
    
	return @"";
}

@end
