
#import "UIDeviceHelper.h"
#include <sys/sysctl.h>  
#import <sys/mount.h>
#import "sys/utsname.h"
#include <mach/mach.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
#import <sys/utsname.h>
#import  <CoreTelephony/CTTelephonyNetworkInfo.h>
#import  <CoreTelephony/CTCarrier.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "CKeyChain.h"
#import "Reachability.h"

static NSString *COpenUDIDKey = @"COpenUDIDKey";

@implementation UIDevice (Helper)

+ (double)availableMemory {
	vm_statistics_data_t vmStats;
	mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
	kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
	
	if(kernReturn != KERN_SUCCESS) {
		return NSNotFound;
	}
	
	return ((vm_page_size * vmStats.free_count) / 1024.0) / 1024.0;
}

//http://blog.csdn.net/uxyheaven/article/details/38167525
//http://www.07net01.com/2015/08/914397.html
+ (NSDictionary *)anotherWayToGetDiskInfo
{
    NSDictionary *systemAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    NSString *diskTotalSize = systemAttributes[@"NSFileSystemSize"];//获得磁盘实际存储大小
    NSString *diskFreeSize = systemAttributes[@"NSFileSystemFreeSize"];//获得磁盘实际剩余存储大小
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:[self fileSizeToString:[diskTotalSize longLongValue]] forKey:@"diskTotalSpace"];
    [dic setObject:[self fileSizeToString:[diskFreeSize longLongValue]] forKey:@"diskFreeSpace"];
    return dic;
}

+ (NSString*) fileSizeToString:(long long) fileSize{
    NSInteger KB = 1024;
    NSInteger MB = KB*KB;
    NSInteger GB = MB*KB;
    if (fileSize < 10) {
        return @"无";
    }else if (fileSize < KB) {
        return @"小于1KB";
    }else if (fileSize < MB){
        return [NSString stringWithFormat:@"%.1f KB", ((CGFloat)fileSize)/KB];
    }else if (fileSize < GB) {
        return [NSString stringWithFormat:@"%.1f MB", ((CGFloat)fileSize)/MB];
    }else {
        return [NSString stringWithFormat:@"%.1f GB", ((CGFloat)fileSize)/GB];
    }
}

+ (BOOL)isWiFiAvailable
{
    struct ifaddrs *addresses;
    struct ifaddrs *cursor;
    BOOL wiFiAvailable = NO;
    if (getifaddrs(&addresses) != 0) return NO;
    
    cursor = addresses;
    while (cursor != NULL) {
        if (cursor -> ifa_addr -> sa_family == AF_INET
            && !(cursor -> ifa_flags & IFF_LOOPBACK)) // Ignore the loopback address
        {
            // Check for WiFi adapter
            if (strcmp(cursor -> ifa_name, "en0") == 0) {
                wiFiAvailable = YES;
                break;
            }
        }
        cursor = cursor -> ifa_next;
    }
    
    freeifaddrs(addresses);
    return wiFiAvailable;
}

+ (NSString *)wifiName
{
    NSString *wifiName = nil;
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    if (!wifiInterfaces)
    {
        return @"";
    }
    
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    for (NSString *interfaceName in interfaces)
    {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        
        if (dictRef)
        {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            NSLog(@"network info -> %@", networkInfo);
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            CFRelease(dictRef);
        }
    }
    
    CFRelease(wifiInterfaces);
    return wifiName;
}

+ (NSString *)networkType
{
    NSString *netType = @"未知";
    if ([self isWiFiAvailable]) {
        netType = @"WIFI";
    } else {
        CTTelephonyNetworkInfo *telephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
        NSString *currentStatus = telephonyNetworkInfo.currentRadioAccessTechnology;
        if (currentStatus) {
            if ([currentStatus isEqualToString:CTRadioAccessTechnologyGPRS] || [currentStatus isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
                netType = @"2G";
            } else if ([currentStatus isEqualToString:CTRadioAccessTechnologyEdge]) {
                netType = @"3G";//2.75G
            } else if ([currentStatus isEqualToString:CTRadioAccessTechnologyWCDMA] ||[currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] || [currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] || [currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB] || [currentStatus isEqualToString:CTRadioAccessTechnologyeHRPD]) {
                netType = @"3G";
            } else if ([currentStatus isEqualToString:CTRadioAccessTechnologyHSDPA] ||[currentStatus isEqualToString:CTRadioAccessTechnologyHSUPA]){
                netType = @"4G"; //3.5G
            } else if ([currentStatus isEqualToString:CTRadioAccessTechnologyLTE]) {
                netType = @"4G";
            }
        }
    }
    return netType;
}

//http://www.tuicool.com/articles/FJzMRn
//https://en.wikipedia.org/wiki/Mobile_country_code CHINA MCC = 460
+ (NSString *)operatorName
{
    NSString *info = @"未知";
    
    CTTelephonyNetworkInfo *telephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [telephonyNetworkInfo subscriberCellularProvider];
    if (carrier.mobileCountryCode && [carrier.mobileCountryCode integerValue] == 460) {
        if (carrier.mobileNetworkCode) {
            switch ([carrier.mobileNetworkCode integerValue]) {
                case 0:
                case 2:
                case 7:
                    info = @"中国移动";
                    break;
                case 1:
                case 6:
                case 9:
                    info = @"中国联通";
                    break;
                case 3:
                case 5:
                case 11:
                    info = @"中国电信";
                    break;
                case 20:
                    info = @"中国铁通";
                    break;
                default:
                    break;
            }
        }
    }
    return info;
}

//http://bbs.51cto.com/thread-843790-1.html
+ (NSString *)batteryLevelInfo
{
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    float batteryLevel = [[UIDevice currentDevice] batteryLevel];
    NSString *batteryInfo = batteryLevel == -1 ? @"unknown" : [NSString stringWithFormat:@"%.0f%%", batteryLevel * 100];
    return batteryInfo;
}

+ (CGFloat)brightness
{
    return [UIScreen mainScreen].brightness;
}

+ (NSString *) orientationString
{
    switch ([[UIDevice currentDevice] orientation])
    {
        case UIDeviceOrientationUnknown: return @"Unknown";
        case UIDeviceOrientationPortrait: return @"Portrait"; //纵向
        case UIDeviceOrientationPortraitUpsideDown: return @"Portrait Upside Down";
        case UIDeviceOrientationLandscapeLeft: return @"Landscape Left"; //横向 左
        case UIDeviceOrientationLandscapeRight: return @"Landscape Right";
        case UIDeviceOrientationFaceUp: return @"Face Up";
        case UIDeviceOrientationFaceDown: return @"Face Down";
        default: break;
    }
    return nil;
}

+ (NSString*) curNetWorkType{
    // 检查当前网络状态,状态变化Reachability会收到通知
    NSString *netType = nil;
    NetworkStatus networkStatus = [Reachability reachabilityForInternetConnection].currentReachabilityStatus;
    switch (networkStatus) {
        case NotReachable:
            // 没有网络连接
            netType = @"no";
            break;
        case ReachableViaWWAN:
            // 使用WWAN网络2G,3G,4G
            netType = @"WWAN";
            break;
        case ReachableViaWiFi:
            // 使用WiFi网络
            netType = @"WiFi";
            break;
    }
    return netType;
}

//获取运营商信息
+ (NSString*) getCellularProviderName
{
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier*carrier = info.subscriberCellularProvider;
    //NSLog(@"description:%@",[carrier description]);
    /*
     CTCarrier (0x1a0200) {
     Carrier name: [中国联通]
     Mobile Country Code: [460]
     Mobile Network Code:[01]
     ISO Country Code:[cn]
     Allows VOIP? [YES]
     }
     */
    //NSLog(@"carrier:%@", carrier.carrierName);//中国联通  可能为空
    
    NSString *mcc = [carrier mobileCountryCode];//460   可能为（null）
    NSString *mnc = [carrier mobileNetworkCode];//01    可能为空或（null）
    return [NSString stringWithFormat:@"%@_%@",mcc,mnc];
}

// Get IP Address on wifi
+ (NSString *)getIPAddress{
    NSString *address = @"localhost";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // 1.localhost Check if interface is lo0 which is the local connection on the iPhone
                //                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"lo0"]) {
                //                    // Get NSString from C String
                //                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];//127.0.0.1
                //                }
                
                // 2.wifi Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
                
                // 3.3G Check if interface is pdp_ip0 which is the 3G connection on the iPhone
                //                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"pdp_ip0"]) {
                //                    // Get NSString from C String
                //                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                //                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

+ (BOOL)isOS2 {
	return [[UIDevice currentDevice].systemVersion hasPrefix:@"2."];
}

+ (BOOL)isOS3 {
	return [[UIDevice currentDevice].systemVersion hasPrefix:@"3."];
}
+ (BOOL)isOS4 {
	return [[UIDevice currentDevice].systemVersion hasPrefix:@"4."];
}
+ (BOOL)isOS5 {
	return [[UIDevice currentDevice].systemVersion hasPrefix:@"5."];
}
+ (BOOL)isOS6 {
	return [[UIDevice currentDevice].systemVersion hasPrefix:@"6."];
}
+ (BOOL)isOS7 {
	return [[UIDevice currentDevice].systemVersion hasPrefix:@"7."];
}
+ (BOOL)isOS8 {
    return [[UIDevice currentDevice].systemVersion hasPrefix:@"8."];
}
+ (BOOL)isOS9 {
    return [[UIDevice currentDevice].systemVersion hasPrefix:@"9."];
}
+ (BOOL)isOS10 {
    return [[UIDevice currentDevice].systemVersion hasPrefix:@"10."];
}
+ (BOOL)isOS11 {
    return [[UIDevice currentDevice].systemVersion hasPrefix:@"11."];
}



+ (BOOL) isIPad {
	BOOL iPad = NO;
#ifdef UI_USER_INTERFACE_IDIOM
	iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
#endif
	return iPad;
}

+ (BOOL) isGestureSupported {
	BOOL gesture = NO;
#if (__IPHONE_OS_VERSION_MAX_ALLOWED >= 30200)
	gesture = YES;
#endif
	return gesture;
}

+(BOOL)isPortrait//纵向
{
	return UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation]);
}

+(BOOL)isLandscape////横向
{
	return UIDeviceOrientationIsLandscape([[UIDevice currentDevice] orientation]);
}

+ (NSString *)getDevice{
    static NSString *gDevice = nil;
	if (gDevice == nil) {
		//here use sys/utsname.h
        struct utsname systemInfo;
        uname(&systemInfo);
        //get the device model
        NSString *model = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
        if ([model isEqualToString:@"i386"]) {
            gDevice = @"simulator";
        }
        if ([model isEqualToString:@"x86_64"]) {
            gDevice = @"simulator";
        }
        //以下由李香成整理，有新产品续加,
        //http://act.weiphone.com/wetools/index.php?r=iosRom/index/mid/21
        //http://www.pingapple.com/ios-official-firmware-direct-download-link
        else if ([model isEqualToString:@"iPod1,1"]) {//iPod
            gDevice = @"iPod Touch 1nd 一代";
        }
        else if ([model isEqualToString:@"iPod2,1"]) {
            gDevice = @"iPod Touch 2nd 二代";
        }
        else if ([model isEqualToString:@"iPod3,1"]) {
            gDevice = @"iPod Touch 3rd 三代";
        }
        else if ([model isEqualToString:@"iPod4,1"]) {
            gDevice = @"iPod Touch 4th 四代";
        }
        else if ([model isEqualToString:@"iPod5,1"]) {
            gDevice = @"iPod Touch 5th 五代";
        }
        else if ([model isEqualToString:@"iPod7,1"]) {
            gDevice = @"iPod Touch 6th 六代";
        }
        else if ([model isEqualToString:@"iPhone1,1"]) {//iPhone
            gDevice = @"iPhone 1 (GSM)";
        }
        else if ([model isEqualToString:@"iPhone1,2"]) {
            gDevice = @"iPhone 3G (GSM)";
        }
        else if ([model isEqualToString:@"iPhone2,1"]) {
            gDevice = @"iPhone 3GS (GSM)";
        }
        else if ([model isEqualToString:@"iPhone3,1"]) {
            gDevice = @"iPhone 4 (Verizon)";
        }
        else if ([model isEqualToString:@"iPhone3,2"]) {
            gDevice = @"iPhone 4 (GSM)";
        }
        else if ([model isEqualToString:@"iPhone3,3"]) {
            gDevice = @"iPhone 4 (CDMA2000)";
        }
        else if ([model isEqualToString:@"iPhone4,1"]) {
            gDevice = @"iPhone 4S 五代(GSM,CDMA2000)";
        }
        else if ([model isEqualToString:@"iPhone5,1"]) {
            gDevice = @"iPhone 5 (GSM)";
        }
        else if ([model isEqualToString:@"iPhone5,2"]) {
            gDevice = @"iPhone 5 (CDMA2000)";
        }
        else if ([model isEqualToString:@"iPhone5,3"]) {
            gDevice = @"iPhone 5C CDMA2000";
        }
        else if ([model isEqualToString:@"iPhone5,4"]) {
            gDevice = @"iPhone 5C GSM";
        }
        else if ([model isEqualToString:@"iPhone6,1"]) {
            gDevice = @"iPhone 5S CDMA2000";
        }
        else if ([model isEqualToString:@"iPhone6,2"]) {
            gDevice = @"iPhone 5S GSM";
        }
        else if ([model isEqualToString:@"iPhone7,1"]) {
            gDevice = @"iPhone 6Plus LTE";
        }
        else if ([model isEqualToString:@"iPhone7,2"]) {
            gDevice = @"iPhone 6 LTE";
        }
        else if ([model isEqualToString:@"iPhone8,1"]) {
            gDevice = @"iPhone 6s LTE";
        }
        else if ([model isEqualToString:@"iPhone8,2"]) {
            gDevice = @"iPhone 6s Plus LTE";
        }
        else if ([model isEqualToString:@"iPhone8,4"]) {
            gDevice = @"iPhone 5SE";
        }
        else if ([model isEqualToString:@"iPhone9,1"]) {
            gDevice = @"iPhone 7 LTE";
        }
        else if ([model isEqualToString:@"iPhone9,2"]) {
            gDevice = @"iPhone 7 Plus LTE";
        }
        else if ([model isEqualToString:@"iPhone9,3"]) {
            gDevice = @"iPhone 7 GSM";
        }
        else if ([model isEqualToString:@"iPhone9,4"]) {
            gDevice = @"iPhone 7 Plus GSM";
        }
        else if ([model isEqualToString:@"iPhone10,1"]) {
            gDevice = @"iPhone 8 LTE";
        }
        else if ([model isEqualToString:@"iPhone10,2"]) {
            gDevice = @"iPhone 8 Plus LTE";
        }
        else if ([model isEqualToString:@"iPhone10,3"]) {
            gDevice = @"iPhone X LTE";
        }
        else if ([model isEqualToString:@"iPhone10,4"]) {
            gDevice = @"iPhone 8 GSM";
        }
        else if ([model isEqualToString:@"iPhone10,5"]) {
            gDevice = @"iPhone 8 Plus GSM";
        }
        else if ([model isEqualToString:@"iPhone10,6"]) {
            gDevice = @"iPhone X GSM";
        }
        else if ([model isEqualToString:@"iPad1,1"]) {//iPad
            gDevice = @"iPad 1nd 一代 (WiFi)";
        }
        else if ([model isEqualToString:@"iPad2,1"]) {
            gDevice = @"iPad 2nd 二代 (WiFi)";
        }
        else if ([model isEqualToString:@"iPad2,2"]) {
            gDevice = @"iPad 2nd 二代 (GSM)";
        }
        else if ([model isEqualToString:@"iPad2,3"]) {
            gDevice = @"iPad 2nd 二代 (CDMA2000)";
        }
        else if ([model isEqualToString:@"iPad3,1"]) {
            gDevice = @"iPad 3rd (The new iPad) 三代 (WiFi)";
        }
        else if ([model isEqualToString:@"iPad3,2"]) {
            gDevice = @"iPad 3rd (The new iPad) 三代 (CDMA2000)";
        }
        else if ([model isEqualToString:@"iPad3,3"]) {
            gDevice = @"iPad 3rd (The new iPad) 三代 (GSM)";
        }
        else if ([model isEqualToString:@"iPad3,4"]) {
            gDevice = @"iPad 4rd 四代 (WiFi)";
        }
        else if ([model isEqualToString:@"iPad3,5"]) {
            gDevice = @"iPad 4rd 四代 (GSM)";
        }
        else if ([model isEqualToString:@"iPad3,6"]) {
            gDevice = @"iPad 4rd 四代 (CDMA2000)";
        }
        else if ([model isEqualToString:@"iPad4,1"]) {
            gDevice = @"iPad Air 五代 (WiFi)";
        }
        else if ([model isEqualToString:@"iPad4,2"]) {
            gDevice = @"iPad Air 五代 (LTE)";
        }
        else if ([model isEqualToString:@"iPad4,3"]) {
            gDevice = @"iPad Air 五代 (TD-SCDMA)";
        }
        else if ([model isEqualToString:@"iPad5,3"]) {
            gDevice = @"iPad Air2 六代 (WiFi)";
        }
        else if ([model isEqualToString:@"iPad5,4"]) {
            gDevice = @"iPad Air2 六代 (LTE)";
        }
        else if ([model isEqualToString:@"iPad2,5"]) {//iPadMini
            gDevice = @"iPad Mini 一代 (WiFi)";
        }
        else if ([model isEqualToString:@"iPad2,6"]) {
            gDevice = @"iPad Mini 一代 (GSM)";
        }
        else if ([model isEqualToString:@"iPad2,7"]) {
            gDevice = @"iPad Mini 一代 (CDMA2000)";
        }
        else if ([model isEqualToString:@"iPad4,4"]) {
            gDevice = @"iPad Mini2 二代 (WiFi)";
        }
        else if ([model isEqualToString:@"iPad4,5"]) {
            gDevice = @"iPad Mini2 二代 (LTE)";
        }
        else if ([model isEqualToString:@"iPad4,6"]) {
            gDevice = @"iPad Mini2 二代 (TD-SCDMA)";
        }
        else if ([model isEqualToString:@"iPad4,7"]) {
            gDevice = @"iPad Mini3 三代 (WiFi)";
        }
        else if ([model isEqualToString:@"iPad4,8"]) {
            gDevice = @"iPad Mini3 三代 (LTE))";
        }
        else if ([model isEqualToString:@"iPad4,9"]) {
            gDevice = @"iPad Mini3 三代 (TD-SCDMA)";
        }
        else if ([model isEqualToString:@"iPad5,1"]) {
            gDevice = @"iPad Mini4 四代 (WiFi)";
        }
        else if ([model isEqualToString:@"iPad5,2"]) {
            gDevice = @"iPad Mini4 四代 (LTE)";
        }
        else{
            gDevice = model;
        }
	}
	return gDevice;
}

+ (NSString *)getSystemName{
//    static NSString *gSystemName = nil;
//	if (gSystemName == nil) {
//		gSystemName = [[[UIDevice currentDevice] systemName] retain];
//	}
//	return gSystemName;
    return @"ios";
}

+ (NSString *)getSystemVersion{
    static NSString *gSystemVersion = nil;
	if (gSystemVersion == nil) {
		gSystemVersion = [[UIDevice currentDevice] systemVersion];
	}
	return gSystemVersion;
}

+ (BOOL)isJailbroken{
    BOOL jailbroken = NO;  
    NSString *cydiaPath = @"/Applications/Cydia.app";  
    NSString *aptPath = @"/private/var/lib/apt/";  
    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath]) {  
        jailbroken = YES;  
    }  
    if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath]) {  
        jailbroken = YES;  
    }  
    return jailbroken;
}

// 1.返回系统IMEI:IMEI获取顺序：先UUID，后 mac+bundleIndetifier,最后自已产生一个GUID.
//+ (NSString *)imei {
//	static NSString *gIMEI = nil;
//	if (gIMEI == nil) {
//		gIMEI = [[[[UIDevice currentDevice] uniqueIdentifier] lowercaseString] retain];
//        if (!gIMEI || [gIMEI length]<1) {
//            gIMEI =  [[UIDevice currentDevice] uniqueDeviceIdentifier];
//        }
//        //gIMEI = [[UIDevice GetUUID] retain];
//        //gIMEI = [@"D148C946-3BA9-4ED4-8BA8-012B63CA6549" retain];
//	}
//	return gIMEI;
//}

// 2.返回系统IMEI:IMEI获取顺序：先KeyChain中是否有OpenUDID，后 mac+bundleIndetifier,最后自已产生一个GUID.
// 注：ios7.0以上，此macaddress值总是:02:00:00:00:00:00，不能做唯一性使用
+ (NSString *)imei {
	static NSString *gIMEI = nil;
	if (gIMEI == nil) {
        gIMEI = [CKeyChain loadDataWithKey:COpenUDIDKey];
        if (!gIMEI || [gIMEI length]<1) {
            gIMEI = [OpenUDID value];
            if (!gIMEI || [gIMEI length]<1) {
                gIMEI =  [[UIDevice currentDevice] uniqueDeviceIdentifier];
            }
            //gIMEI = [[UIDevice GetUUID] retain];
            //gIMEI = [@"D148C946-3BA9-4ED4-8BA8-012B63CA6549" retain];
            [CKeyChain saveWithKey:COpenUDIDKey data:gIMEI];
        }
	}
	return gIMEI;
}

+ (NSString *)openUDID {
    static NSString *openUDID = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        openUDID = [OpenUDID value];
//        openUDID = [UIDevice GetUUID];
    });
    return openUDID;
}

+ (NSString *)IDFA{
    return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
}

@end

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

@interface UIDevice(Private)

- (NSString *) macaddress;

@end

@implementation UIDevice (IdentifierAddition)

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Methods

// Return the local MAC addy
// Courtesy of FreeBSD hackers email list
// Accidentally munged during previous update. Fixed thanks to erica sadun & mlamb.
// ios7.0以上，此macaddress值总是:02:00:00:00:00:00，不能做唯一性使用
- (NSString *) macaddress{
    
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. error!\n");
        return NULL;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", 
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark Public Methods

- (NSString *) uniqueDeviceIdentifier{
    NSString *macaddress = [[UIDevice currentDevice] macaddress];
    if (macaddress==NULL) {
        macaddress = [[self class] GetUUID];
    }
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];//com.jishike.mppp
    
    NSString *stringToHash = [NSString stringWithFormat:@"%@%@",macaddress,bundleIdentifier];
    NSString *uniqueIdentifier = [stringToHash md5Hash];
    
    return uniqueIdentifier;
}

- (NSString *) uniqueGlobalDeviceIdentifier{
    NSString *macaddress = [[UIDevice currentDevice] macaddress];
    NSString *uniqueIdentifier = [macaddress md5Hash];
    
    return uniqueIdentifier;
}

+ (NSString *)GetUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

@end

