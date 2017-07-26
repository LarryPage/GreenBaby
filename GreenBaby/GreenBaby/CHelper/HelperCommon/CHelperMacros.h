
///////////////////////////////////////////////////////////////////////////////////////////////////
// 设备
#define IS_IPHONE_SIMULATOR ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone Simulator" ] )
#define IS_IPHONE ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPhone" ] )
#define IS_IPOD ( [ [ [ UIDevice currentDevice ] model ] isEqualToString: @"iPod touch" ] )
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

//http://magicalboy.com/wp-content/uploads/2014/12/iPhone_6_and_6P_screen_size.png
#define IS_IPHONE_4_OR_LESS (SCREEN_MAX_LENGTH < 568.0)//640, 960
#define IS_IPHONE_5 (SCREEN_MAX_LENGTH == 568.0)//640, 1136
#define IS_IPHONE_6_7 (SCREEN_MAX_LENGTH == 667.0)//750, 1334 缩放模式：640X1136
#define IS_IPHONE_6P_7P (SCREEN_MAX_LENGTH == 736.0)//标准模式：1242, 2208 缩放模式：1125X2001

#define KUIScreeHeight [UIScreen mainScreen].bounds.size.height
#define KUIScreeWidth  [UIScreen mainScreen].bounds.size.width
#define KUIScale       [[UIScreen mainScreen] scale]
///////////////////////////////////////////////////////////////////////////////////////////////////
// iOS系统
#define IS_IOS7 ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
// block self
#define WEAKSELF typeof(self) __weak weakSelf = self;
#define STRONGSELF typeof(weakSelf) __strong strongSelf = weakSelf;
/**
 *  单例函数声明
 *
 *  @param __class ClassName
 */
#undef  SINGLETON_DEF
#define SINGLETON_DEF( __class ) \
+ (__class *)sharedInstance;


/**
 *  单例函数实现
 *
 *  @param __class ClassName
 */
#undef  SINGLETON_IMP
#define SINGLETON_IMP( __class ) \
+ (__class *)sharedInstance \
{ \
    static id __singleton__ = nil; \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        __singleton__ = [[self alloc] init]; \
    }); \
    return __singleton__; \
}
///////////////////////////////////////////////////////////////////////////////////////////////////
// 网络
#define kNetActivityOn					[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
#define kNetActivityOff					[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
///////////////////////////////////////////////////////////////////////////////////////////////////
// Josn解析，可参考RestKit
#define RKMapping(value) (value!=[NSNull null]?value:@"")
///////////////////////////////////////////////////////////////////////////////////////////////////
// 软件显示名称
#define kProductName					[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]
#define kBundleIdentifier               [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]
// 软件版本号
#define kVersion                        [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define kBuildVersion                   [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
///////////////////////////////////////////////////////////////////////////////////////////////////
// 文件
#define kDocument						[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex: 0]
#define kDocumentFolder					[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define kDocumentFolderWithPath(X)		[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:X];

//kCachesFolder==kLibraryCacheFolder
#define kCachesFolder                   [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex: 0]
#define kLibraryFolder					[NSHomeDirectory() stringByAppendingPathComponent:@"Library"]
#define kLibraryCacheFolder				[NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches"] 

#define kTmpFolder						[NSHomeDirectory() stringByAppendingPathComponent:@"tmp"]
#define kBundleFolder					[[NSBundle mainBundle] bundlePath] 
#define kDCIMFolder						@"/var/mobile/Media/DCIM" 

#define kUserDatabaseFolder				[kLibraryCacheFolder stringByAppendingPathComponent:@"lib_database"] 
#define kUserXmlntFolder				[kLibraryCacheFolder stringByAppendingPathComponent:@"lib_xml"] 
#define kUserImageFolder				[kLibraryCacheFolder stringByAppendingPathComponent:@"lib_image"] 
#define kUserAudioFolder				[kLibraryCacheFolder stringByAppendingPathComponent:@"lib_audio"] 
#define kUserVideoFolder				[kLibraryCacheFolder stringByAppendingPathComponent:@"lib_video"] 
#define kUserBooksFolder				[kLibraryCacheFolder stringByAppendingPathComponent:@"lib_books"] 
//#define kUserBooksFolder				[kLibraryCacheFolder stringByAppendingPathComponent:@"lib_books"] 

///////////////////////////////////////////////////////////////////////////////////////////////////
// 字母表
#define kAlphabet [[NSArray alloc] initWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L",@"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"#",nil]
//UITextField 只能输入字母\数字的方法
#define ALPHA @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "
#define NUMBERS @"0123456789"
#define ALPHANUM @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 "
#define NUMBERSPERIOD @"0123456789."

///////////////////////////////////////////////////////////////////////////////////////////////////
// 时间
#define CF_MINUTE 60
#define CF_HOUR   (60 * CF_MINUTE)
#define CF_DAY    (24 * CF_HOUR)
#define CF_5_DAYS (5 * CF_DAY)
#define CF_WEEK   (7 * CF_DAY)
#define CF_MONTH  (30.5 * CF_DAY)
#define CF_YEAR   (365 * CF_DAY)

///////////////////////////////////////////////////////////////////////////////////////////////////
// 定义第三方字体
//#define CFont(fontSize)		[UIFont fontWithName:@"FZLTXHK--GBK1-0" size:fontSize]
#define CFont(fontSize)		[UIFont systemFontOfSize:fontSize]//[UIFont fontWithName:@"HYQiHei" size:fontSize]
#define CFontB(fontSize)	[UIFont boldSystemFontOfSize:fontSize]//[UIFont fontWithName:@"HYQiHei" size:fontSize]
// 颜色
#define kClearColor						[UIColor clearColor]
#define MKRGBA(r,g,b,a)					[UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:(float)a/255.0f]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define HEXCOLOR(c) [UIColor colorWithRed:((c>>24)&0xFF)/255.0 green:((c>>16)&0xFF)/255.0 blue:((c>>8)&0xFF)/255.0 alpha:((c)&0xFF)/255.0]; // usage: UIColor* c = HEXCOLOR(0xff00ffff);

//UIStatusBarStyle
#define DefaultStatusBarStyle   UIStatusBarStyleLightContent
// Navigation Color&Font
#define DefaultNavbarTintColor  MKRGBA(0,195,147,255)
#define DefaultNavTitleColor    [UIColor whiteColor]
#define DefaultNavTitleFont     CFontB(20)
#define DefaultNavTintColor     [UIColor whiteColor]
#define DefaultNavBarButtonFont CFontB(15)
//TabBar Color&Font
#define DefaultTabbarTintColor  MKRGBA(246,246,246,255)//a color tab bar
#define DefaultTabTintColor     MKRGBA(27,155,246,255)//selected icons and text
#define DefaultTabTitleColor_N  MKRGBA(146,146,146,255)//text normal
#define DefaultTabTitleFont_N   CFontB(10)
#define DefaultTabTitleColor_S  MKRGBA(27,155,246,255)//text Selected
#define DefaultTabTitleFont_S   CFontB(10)
//UIWindow
#define DefaultWindowBgColor     MKRGBA(235,235,235,255)
//UIViewController
#define DefaultVCViewBgColor     UIColorFromRGB(0xebebeb)
///////////////////////////////////////////////////////////////////////////////////////////////////
// 字符串
#define MKLocalizedString(s)					NSLocalizedString(s,s)

#define MKLocalizedStringWithFormat(s,...)		[NSString stringWithFormat:NSLocalizedString(s,s),##__VA_ARGS__]

///////////////////////////////////////////////////////////////////////////////////////////////////
// 输出
#ifndef __OPTIMIZE__
#define	 CFLog(...) \
NSLog(__VA_ARGS__)
# define CFPError \
NSLog(@"文件名->:%s \n方法->:%s \n行->:%d \n <-错误!", __FILE__, __PRETTY_FUNCTION__, __LINE__)
# define CFP \
NSLog(@"文件名->:%s \n方法->:%s \n行->:%d", __FILE__, __PRETTY_FUNCTION__, __LINE__)
#else
# define CFLog(...)						;
# define CFPError						;
# define CFP							;
#endif

#ifdef DEBUG
#define NSLog(format, ...) printf("[%s] %s [第%d行] %s\n", __TIME__, __FUNCTION__, __LINE__, [[NSString stringWithFormat:format, ## __VA_ARGS__] UTF8String]);
#else
#define NSLog(format, ...)
#endif

#ifdef DEBUG
#define CLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define CLog(format, ...)
#endif

#if __LP64__
#define NSI "ld"
#define NSU "lu"
#else
#define NSI "d"
#define NSU "u"
#endif

///////////////////////////////////////////////////////////////////////////////////////////////////
// 调试
#define CFLOGRECT(rect) \
CFLog(@"%s x=%f, y=%f, w=%f, h=%f", #rect, rect.origin.x, rect.origin.y, \
rect.size.width, rect.size.height)

#define CFLOGPOINT(pt) \
CFLog(@"%s x=%f, y=%f", #pt, pt.x, pt.y)

#define CFLOGSIZE(size) \
CFLog(@"%s w=%f, h=%f", #size, size.width, size.height)

#define CFLOGEDGES(edges) \
CFLog(@"%s left=%f, right=%f, top=%f, bottom=%f", #edges, edges.left, edges.right, \
edges.top, edges.bottom)

#define CFLOGHSV(_COLOR) \
CFLog(@"%s h=%f, s=%f, v=%f", #_COLOR, _COLOR.hue, _COLOR.saturation, _COLOR.value)

