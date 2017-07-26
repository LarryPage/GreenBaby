

#import <Foundation/Foundation.h>


@interface NSDate (Helper)

// dateString : 格式化选项, dateFormatterString: NSDateFormatter
+ (NSDate*)dateWithString:(NSString*)dateString formatString:(NSString*)dateFormatterString;

//返回一个"yyyy-MM-dd'T'HH:mm:ssZ"格式NSDate,如：2011-09-26T17:23:10+08:00
+ (NSDate *)parseRFC3339Date:(NSString *)dateString;

// 返回一个ISO8610格式NSDate, 又称: yyyy-MM-dd'T'HH:mm:ssZZZ 
+ (NSDate*)dateWithISO8601String:(NSString*)str;

// 'yyyy-MM-dd' 字符串
+ (NSDate*)dateWithDateString:(NSString*)str;

// 'yyyy-MM-dd HH:mm:ss' 字符串
+ (NSDate*)dateWithDateTimeString:(NSString*)str;

// 'dd MMM yyyy HH:mm:ss' 字符串
+ (NSDate*)dateWithLongDateTimeString:(NSString*)str;

// RSS 格式 : 'EEE, d MMM yyyy HH:mm:ss ZZZ' 字符串
+ (NSDate*)dateWithRSSDateString:(NSString*)str;

// 另外一种 RSS 格式 : 'd MMM yyyy HH:mm:ss ZZZ' 字符串
+ (NSDate*)dateWithAltRSSDateString:(NSString*)str;

// 和当前比较:, 2 minutes ago, 2 hours ago, 2 days ago, 等等.
- (NSString*)formattedExactRelativeDate;

// 和当前比较:,2秒前 , 2 分钟前, 2 小时前, 2 天前, 等等.
- (NSString*)formattedExactRelativeTimestamp;

// 将字符串格式化成时间
- (NSString*)formattedDateWithFormatString:(NSString*)dateFormatterString;

// 格式 : EEE, d MMM 'at' h:mma
- (NSString*)formattedDate;

// 格式 : NSDateFormatterShortStyle
- (NSString*)formatTime;

// Returns date formatted to: Weekday if within last 7 days, Yesterday/Tomorrow, or NSDateFormatterShortStyle for everything else
- (NSString*)relativeFormattedDate;

// Returns date formatted to: Weekday if within last 7 days, Yesterday/Today/Tomorrow, or NSDateFormatterShortStyle for everything else
// If date is today, returns no Date, instead returns NSDateFormatterShortStyle for time
- (NSString*)relativeFormattedDateOnly;

// Returns date formatted to: Weekday if within last 7 days, Yesterday/Today/Tomorrow, or NSDateFormatterFullStyle for everything else
// Also returns NSDateFormatterShortStyle for time
- (NSString*)relativeFormattedDateTime;

// Returns date formatted to: Weekday if within last 7 days, Yesterday/Today/Tomorrow, or NSDateFormatterFullStyle for everything else
- (NSString*)relativeLongFormattedDate;

// 返回一个ISO8610格式NSDate, 又称: yyyy-MM-dd'T'HH:mm:ssZZZ 
- (NSString*)iso8601Formatted;

// 判断当前日期是否是过去
- (BOOL)isPastDate;

// 检查当前日期是否是今天
- (BOOL)isDateToday;

// 检查当前日期是否是昨天
- (BOOL)isDateYesterday;

// 返回当前的日期，午夜时间
- (NSDate*)midnightDate;

@end

@interface NSDate (NSDate_Utility)

- (NSString*)formatString;

+ (NSString *)currentDateTimeString;

@end

@interface NSDate (NSDate_Helper)

//获取年月日如:19871127.
- (NSString *)getFormatYearMonthDay;

//返回当前月一共有几周(可能为4,5,6)
- (int )getWeekNumOfMonth;

//该日期是该年的第几周
- (int )getWeekOfYear;

//返回day天后的日期(若day为负数,则为|day|天前的日期)
- (NSDate *)dateAfterDay:(int)day;

//month个月后的日期
- (NSDate *)dateafterMonth:(int)month;

//获取日
- (NSUInteger)getDay;

//获取月
- (NSUInteger)getMonth;

//获取年
- (NSUInteger)getYear;

//获取小时
- (int )getHour ;

//获取分钟
- (int)getMinute ;
- (int)getHour:(NSDate *)date ;
- (int)getMinute:(NSDate *)date ;

//在当前日期前几天
- (NSUInteger)daysAgo ;

//午夜时间距今几天
- (NSUInteger)daysAgoAgainstMidnight ;
- (NSString *)stringDaysAgo ;
- (NSString *)stringDaysAgoAgainstMidnight:(BOOL)flag;

//返回一周的第几天(周末为第一天)
- (NSUInteger)weekday ;//转为NSString类型的

+ (NSDate *)dateFromString:(NSString *)string ;
+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format ;
+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format ;
+ (NSString *)stringFromDate:(NSDate *)date ;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed ;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date ;
- (NSString *)stringWithFormat:(NSString *)format;
- (NSString *)string ;
- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;

//返回周日的的开始时间
- (NSDate *)beginningOfWeek;

//返回当前天的年月日.
- (NSDate *)beginningOfDay ;

//返回该月的第一天
- (NSDate *)beginningOfMonth;

//该月的最后一天
- (NSDate *)endOfMonth;

//返回当前周的周末
- (NSDate *)endOfWeek;

//return RFC 822 timestamp
-(double)RFC822TimeInteral;

+ (NSString *)dateFormatString ;
+ (NSString *)timeFormatString ;
+ (NSString *)timestampFormatString ;

// preserving for compatibility
+ (NSString *)dbFormatString ;

@end

#define D_MINUTE	60
#define D_HOUR		3600
#define D_DAY		86400
#define D_WEEK		604800
#define D_YEAR		31556926

@interface NSDate (IM)

// Retrieving intervals
- (NSInteger) minutesAfterDate: (NSDate *) aDate;
- (NSInteger) minutesBeforeDate: (NSDate *) aDate;
- (float) hoursAfterDate: (NSDate *) aDate;
- (NSInteger) hoursBeforeDate: (NSDate *) aDate;
- (NSInteger) daysAfterDate: (NSDate *) aDate;
- (NSInteger) daysBeforeDate: (NSDate *) aDate;
- (NSInteger)distanceInDaysToDate:(NSDate *)anotherDate;

- (NSString *)formattedTime;
@end
