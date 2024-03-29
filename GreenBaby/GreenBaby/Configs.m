//
//  Configs.m
//  BBPush
//
//  Created by Li XiangCheng on 13-3-10.
//  Copyright (c) 2013年 Li XiangCheng. All rights reserved.
//

#import "Configs.h"

NSString *FileServer = @"http://adhoc.qiniudn.com";//@"file.huijiame.com"

// baiduMobStat app key ID
NSString *baiduMobStatAPPKey = @"09088c50e3";
NSString *baiduMobStatChannelID = @"App Store";//@"91store";@"Cydia";//自动判断:[UIDevice isJailbroken]?@"91store":@"App Store";

// WeiXin app key ID
NSString *weixinAppID = @"wx49bc895bdb3ae540";//与URL type->URL scheme中的相同
NSString *weixinAppKey = @"5aaba490an90b451ca624byfbcgd82ye";//暂时没用

//Sina　app key ID　//建议用网页应用，客户端应用只限于手机客端
NSString *SINA_APP_KEY = @"244948476";
NSString *SINA_APP_SECRET = @"edb3252033258d8187dcd340bba86faa";

//Tencent　app key ID //建议用网页应用，客户端应用只限于手机客端
NSString *Tencent_APP_KEY = @"801307650";
NSString *Tencent_APP_SECRET = @"ae36f4ee3946e1cbb98d6965b0b2ff5c";

//TencentOpen　app key ID //
NSString *TencentOpen_APP_KEY = @"100839155";
NSString *TencentOpen_APP_SECRET = @"321079098cfd2e21ab1240a2ff871ee7";

// LinkedIn
NSString *LinkedIn_APP_KEY = @"1zz3317i8jfj";
NSString *LinkedIn_APP_SECRET = @"xmZ3PRvaklkfQRJa";

// Renren
NSString *Rerren_APP_KEY = @"241477";
NSString *Rerren_APP_SECRET = @"619089569c6e471982843b043137644d";

//ShareSDK　app key ID
NSString *ShareSDK_APP_KEY = @"63b2f07d620";

//Qiniu app key id & Bucket Name
NSString *QiniuAccessKey = @"fu3r4ZNUBh7joYaNPTQst5mxHyT4VUxYisnECPNg";
NSString *QiniuSecretKey = @"q5uVQBDB-zqOpdirzx-Uw5xGTlD2uqZkwIZ-dLgR";
NSString *QiniuBucketNameImg = @"adhoc";

@implementation Configs

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+ (NSLocale*) CurrentLocale {
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	NSArray* languages = [defaults objectForKey:@"AppleLanguages"];
	if (languages.count > 0) {
		NSString* currentLanguage = [languages objectAtIndex:0];
		return [[NSLocale alloc] initWithLocaleIdentifier:currentLanguage];
	} else {
		return [NSLocale currentLocale];
	}
}
+ (NSString*) LocalizedString:(NSString*)key {//comment:没有返回key
	static NSBundle* bundle = nil;
	if (!bundle) {
		NSString* path = [[[NSBundle mainBundle] resourcePath]
						  stringByAppendingPathComponent:@"LocalizedString.bundle"];
		bundle = [[NSBundle bundleWithPath:path] copy];
	}
	
	return [bundle localizedStringForKey:key value:key table:nil];
}

+ (NSString*)documentPath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return documentsDirectory;
}
+ (NSString*) PathForBundleResource:(NSString*) relativePath{
	NSString* resourcePath = [[NSBundle mainBundle] resourcePath];
	return [resourcePath stringByAppendingPathComponent:relativePath];
}
+ (NSString*) PathForDocumentsResource:(NSString*) relativePath{
	static NSString* documentsPath = nil;
	if (!documentsPath) {
		NSArray* dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		documentsPath = [[dirs objectAtIndex:0] copy];
	}
	return [documentsPath stringByAppendingPathComponent:relativePath];
}

+ (NSDictionary *)faceMap {
    static NSDictionary *faceMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
        if ([[languages objectAtIndex:0] hasPrefix:@"zh"]) {
            
            faceMap = [NSDictionary dictionaryWithContentsOfFile:
                         [[NSBundle mainBundle] pathForResource:@"faceMap_ch"
                                                         ofType:@"plist"]];
        }
        else {
            
            faceMap = [NSDictionary dictionaryWithContentsOfFile:
                         [[NSBundle mainBundle] pathForResource:@"faceMap_en"
                                                         ofType:@"plist"]];
        }
    });
    return faceMap;
}

#pragma mark - memoryDB and files

+ (NSString*)DeviceModelCurRecordPlistPath{
    return [[Configs documentPath] stringByAppendingPathComponent:@"DeviceModelCurRecord1.plist"];
}
+ (NSString*)UserModelCurRecordPlistPath{
    return [[Configs documentPath] stringByAppendingPathComponent:@"UserModelCurRecord1.plist"];
}
+ (NSString*)CityModelRecordPlistPath{
    return [[Configs documentPath] stringByAppendingPathComponent:@"CityModelRecord1.plist"];
    //return [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"CityModelRecord1.plist"];//Mock
}
+ (NSString*)RegionModelRecordPlistPath{
    return [[Configs documentPath] stringByAppendingPathComponent:@"RegionModelRecord1.plist"];
}
+ (NSString*)MessageModelRecordPlistPath{
    return [[Configs documentPath] stringByAppendingPathComponent:@"MessageModelRecord1.plist"];
}

#pragma mark - memoryDB and sqlite3

+ (NSString*)dbPath{
    return [[Configs documentPath] stringByAppendingPathComponent:@"db.db"];
}

+ (NSString*)DeviceModelCurRecordTableName{
    return @"DeviceModelCurRecord1";
}
+ (NSString*)UserModelCurRecordTableName{
    return @"UserModelCurRecord1";
}
+ (NSString*)CityModelRecordTableName{
    return @"CityModelRecord1";
}
+ (NSString*)RegionModelRecordTableName{
    return @"RegionModelRecord1";
}
+ (NSString*)MessageModelRecordTableName{
    return @"MessageModelRecord1";
}

@end
