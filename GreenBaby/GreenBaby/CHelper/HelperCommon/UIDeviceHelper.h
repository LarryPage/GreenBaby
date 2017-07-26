

#import <UIKit/UIKit.h>
#include "OpenUDID.h"
#import <AdSupport/ASIdentifierManager.h>


@interface UIDevice (Helper)

+ (double)availableMemory;// 可用的设备内存  :xxx MB
+ (NSDictionary *)anotherWayToGetDiskInfo;
+ (BOOL)isWiFiAvailable;
+ (NSString *)wifiName;
+ (NSString *)networkType;//2G/4G
+ (NSString *)operatorName;//中国移动
+ (NSString *)batteryLevelInfo;//电池
+ (CGFloat)brightness;//当前的屏幕亮度
+ (NSString *)orientationString;// 方向

//获取当前检查网络状态 #import "Reachability.h"
+ (NSString*) curNetWorkType;//no WWAN WiFi

//获取运营商信息。这个信息由MCC和MNC两部分组成，中间以下划线分隔。详见 http://en.wikipedia.org/wiki/Mobile_country_code
//使用CTTelephonyNetworkInfo与CTCarrier这两个类获取运营商相关信息
+ (NSString*) getCellularProviderName;

// Get IP Address on wifi
+ (NSString *)getIPAddress;

+ (BOOL)isOS2;
+ (BOOL)isOS3;
+ (BOOL)isOS4;
+ (BOOL)isOS5;
+ (BOOL)isOS6;
+ (BOOL)isOS7;
+ (BOOL)isOS8;
+ (BOOL)isOS9;

+ (BOOL)isIPad ;// 是否是IPAD
+ (BOOL)isGestureSupported ;// 是否支持手势

+ (BOOL)isPortrait;// 是否是竖屏
+ (BOOL)isLandscape;// 是否是横屏

+ (NSString *)getDevice;//获取设备类型:iPhone 3GS
+ (NSString *)getSystemName;//获取OS名称
+ (NSString *)getSystemVersion;//获取OS版本

+ (BOOL)isJailbroken;//判断当前设备是否已经越狱,判断方法根据 apt和Cydia.app的path来判断

// 返回系统IMEI
+ (NSString *)imei;
// 返回系统OpenUDID
+ (NSString *)openUDID;
//返回IDFA
+ (NSString *)IDFA;

@end

@interface UIDevice (IdentifierAddition)

/*
 * @method uniqueDeviceIdentifier
 * @description use this method when you need a unique identifier in one app.
 * It generates a hash from the MAC-address in combination with the bundle identifier
 * of your app.
 */

- (NSString *) uniqueDeviceIdentifier;

/*
 * @method uniqueGlobalDeviceIdentifier
 * @description use this method when you need a unique global identifier to track a device
 * with multiple apps. as example a advertising network will use this method to track the device
 * from different apps.
 * It generates a hash from the MAC-address only.
 */

- (NSString *) uniqueGlobalDeviceIdentifier;

+ (NSString *)GetUUID;//随即产生一个GUID，如：3911E7E1-023B-483A-8C28-19A7A8D88572

@end
