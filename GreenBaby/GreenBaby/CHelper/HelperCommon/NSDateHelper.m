

#import "NSDateHelper.h"

#define LocalizedString(s)					NSLocalizedString(s,s)
#define LocalizedStringWithFormat(s,...)	[NSString stringWithFormat:NSLocalizedString(s,s),##__VA_ARGS__]
@implementation NSDate (Helper)

+ (NSDate*)dateWithString:(NSString*)dateString formatString:(NSString*)dateFormatterString {
	if(!dateString) return nil;
	
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:dateFormatterString];
	
	NSDate *theDate = [formatter dateFromString:dateString];
	return theDate;
}

+ (NSDate *)parseRFC3339Date:(NSString *)dateString {
    NSDateFormatter *rfc3339TimestampFormatterWithTimeZone = [[NSDateFormatter alloc] init];
    [rfc3339TimestampFormatterWithTimeZone setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [rfc3339TimestampFormatterWithTimeZone setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
	
    NSDate *theDate = nil;
    NSError *error = nil; 
    if (![rfc3339TimestampFormatterWithTimeZone getObjectValue:&theDate forString:dateString range:nil error:&error]) {
        NSLog(@"Date '%@' could not be parsed: %@", dateString, error);
    }
    return theDate;
}

+ (NSDate*)dateWithISO8601String:(NSString*)dateString {
	if(!dateString) return nil;
	
	if([dateString hasSuffix:@" 00:00"]) {
		dateString = [[dateString substringToIndex:(dateString.length-6)] stringByAppendingString:@"GMT"];
	} else if ([dateString hasSuffix:@"Z"]) {
		dateString = [[dateString substringToIndex:(dateString.length-1)] stringByAppendingString:@"GMT"];
	}
	
	return [[self class] dateWithString:dateString formatString:@"yyyy-MM-dd'T'HH:mm:ssZZZ"];
}

+ (NSDate*)dateWithDateString:(NSString*)dateString {
	return [[self class] dateWithString:dateString formatString:@"yyyy-MM-dd"];
}

+ (NSDate*)dateWithDateTimeString:(NSString*)dateString {
	return [[self class] dateWithString:dateString formatString:@"yyyy-MM-dd HH:mm:ss"];
}

+ (NSDate*)dateWithLongDateTimeString:(NSString*)dateString {
	return [[self class] dateWithString:dateString formatString:@"dd MMM yyyy HH:mm:ss"];
}

+ (NSDate*)dateWithRSSDateString:(NSString*)dateString {
	if ([dateString hasSuffix:@"Z"]) {
		dateString = [[dateString substringToIndex:(dateString.length-1)] stringByAppendingString:@"GMT"];
	}
	
	return [[self class] dateWithString:dateString formatString:@"EEE, d MMM yyyy HH:mm:ss ZZZ"];
}

+ (NSDate*)dateWithAltRSSDateString:(NSString*)dateString {
	if ([dateString hasSuffix:@"Z"]) {
		dateString = [[dateString substringToIndex:(dateString.length-1)] stringByAppendingString:@"GMT"];
	}
	
	return [[self class] dateWithString:dateString formatString:@"d MMM yyyy HH:mm:ss ZZZ"];
}

- (NSString*)formattedExactRelativeDate {
	NSTimeInterval time = [self timeIntervalSince1970];
	NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
	NSTimeInterval diff = now - time;
	
	if(diff < 10) {
		return LocalizedString(@"just now");	
	} else if(diff < 60) {
		return LocalizedStringWithFormat(@"%d seconds ago", (int)diff);
	}
	
	diff = round(diff/60);
	if(diff < 60) {
		if(diff == 1) {
			return LocalizedStringWithFormat(@"%d minute ago", (int)diff);
		} else {
			return LocalizedStringWithFormat(@"%d minutes ago", (int)diff);
		}
	}
	
	diff = round(diff/60);
	if(diff < 24) {
		if(diff == 1) {
			return LocalizedStringWithFormat(@"%d hour ago", (int)diff);
		} else {
			return LocalizedStringWithFormat(@"%d hours ago", (int)diff);
		}
	}
	
	if(diff < 7) {
		if(diff == 1) {
			return LocalizedString(@"yesterday");
		} else {
			return LocalizedStringWithFormat(@"%d days ago", (int)diff);
		}
	}
	
	return [self formattedDateWithFormatString:LocalizedString(@"MM/dd/yy")];
}

- (NSString*)formattedExactRelativeTimestamp {
	NSTimeInterval time = [self timeIntervalSince1970];
	NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
	int distance = now - time;
	
    NSString *_timestamp;
    if (distance < 0) distance = 0;
    
    if (distance < 60) {
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, (distance == 1) ? @"秒前" : @"秒前"];
    }
    else if (distance < 60 * 60) {  
        distance = distance / 60;
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, (distance == 1) ? @"分钟前" : @"分钟前"];
    }  
    else if (distance < 60 * 60 * 24) {
        distance = distance / 60 / 60;
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, (distance == 1) ? @"小时前" : @"小时前"];
    }
    else if (distance < 60 * 60 * 24 * 7) {
        distance = distance / 60 / 60 / 24;
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, (distance == 1) ? @"天前" : @"天前"];
    }
    else if (distance < 60 * 60 * 24 * 7 * 4) {
        distance = distance / 60 / 60 / 24 / 7;
        _timestamp = [NSString stringWithFormat:@"%d%@", distance, (distance == 1) ? @"周前" : @"周前"];
    }
    else {
        _timestamp = [self formatString];
    }
    return _timestamp;
}

- (NSString*)formattedDateWithFormatString:(NSString*)dateFormatterString {
	if(!dateFormatterString) return nil;
	
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:dateFormatterString];
	[formatter setAMSymbol:@"am"];
	[formatter setPMSymbol:@"pm"];
	return [formatter stringFromDate:self];
}

- (NSString*)formattedDate {
	return [self formattedDateWithFormatString:@"EEE, d MMM 'at' h:mma"];
}

- (NSString*)relativeFormattedDate {
    // Initialize the formatter.
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
	
    // Initialize the calendar and flags.
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitWeekday;
    NSCalendar* calendar = [NSCalendar currentCalendar];
	
    // Create reference date for supplied date.
    NSDateComponents *comps = [calendar components:unitFlags fromDate:self];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
	
    NSDate* suppliedDate = [calendar dateFromComponents:comps];
	
    // Iterate through the eight days (tomorrow, today, and the last six).
    int i;
    for (i = -1; i < 7; i++) {
        // Initialize reference date.
        comps = [calendar components:unitFlags fromDate:[NSDate date]];
        [comps setHour:0];
        [comps setMinute:0];
        [comps setSecond:0];
        [comps setDay:[comps day] - i];
        NSDate* referenceDate = [calendar dateFromComponents:comps];
        // Get week day (starts at 1).
        NSInteger weekday = [[calendar components:unitFlags fromDate:referenceDate] weekday] - 1;
		
        if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == 0) {
            // Today
			[formatter setDateStyle:NSDateFormatterNoStyle];
			[formatter setTimeStyle:NSDateFormatterShortStyle];
			break;
        } else if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == 1) {
            // Yesterday
            [formatter setDateStyle:NSDateFormatterNoStyle];
            return [NSString stringWithString:LocalizedString(@"Yesterday")];
        } else if ([suppliedDate compare:referenceDate] == NSOrderedSame) {
            // Day of the week
            return [[formatter weekdaySymbols] objectAtIndex:weekday];
        }
    }
	
    // It's not in those eight days.
    return [formatter stringFromDate:self];	
}

- (NSString*)relativeFormattedDateOnly {
    // Initialize the formatter.
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
	
    // Initialize the calendar and flags.
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitWeekday;
    NSCalendar* calendar = [NSCalendar currentCalendar];
	
    // Create reference date for supplied date.
    NSDateComponents *comps = [calendar components:unitFlags fromDate:self];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
	
    NSDate* suppliedDate = [calendar dateFromComponents:comps];
	
    // Iterate through the eight days (tomorrow, today, and the last six).
    int i;
    for (i = -1; i < 7; i++) {
        // Initialize reference date.
        comps = [calendar components:unitFlags fromDate:[NSDate date]];
        [comps setHour:0];
        [comps setMinute:0];
        [comps setSecond:0];
        [comps setDay:[comps day] - i];
        NSDate* referenceDate = [calendar dateFromComponents:comps];
        // Get week day (starts at 1).
        NSInteger weekday = [[calendar components:unitFlags fromDate:referenceDate] weekday] - 1;
		
        if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == 0) {
            // Today
            [formatter setDateStyle:NSDateFormatterNoStyle];
            return [NSString stringWithString:LocalizedString(@"Today")];
        } else if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == 1) {
            // Yesterday
            [formatter setDateStyle:NSDateFormatterNoStyle];
            return [NSString stringWithString:LocalizedString(@"Yesterday")];
        } else if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == -1) {
            // Yesterday
            [formatter setDateStyle:NSDateFormatterNoStyle];
            return [NSString stringWithString:LocalizedString(@"Tomorrow")];
        } else if ([suppliedDate compare:referenceDate] == NSOrderedSame) {
            // Day of the week
            return [[formatter weekdaySymbols] objectAtIndex:weekday];
        }
    }
	
    // It's not in those eight days.
    return [formatter stringFromDate:self];	
}

- (NSString*)relativeFormattedDateTime {
    // Initialize the formatter.
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
	[formatter setAMSymbol:@"am"];
	[formatter setPMSymbol:@"pm"];
	
    // Initialize the calendar and flags.
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitWeekday;
    NSCalendar* calendar = [NSCalendar currentCalendar];
	
    // Create reference date for supplied date.
    NSDateComponents *comps = [calendar components:unitFlags fromDate:self];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
	
    NSDate* suppliedDate = [calendar dateFromComponents:comps];
	
    // Iterate through the eight days (tomorrow, today, and the last six).
    int i;
    for (i = -1; i < 7; i++) {
        // Initialize reference date.
        comps = [calendar components:unitFlags fromDate:[NSDate date]];
        [comps setHour:0];
        [comps setMinute:0];
        [comps setSecond:0];
        [comps setDay:[comps day] - i];
        NSDate* referenceDate = [calendar dateFromComponents:comps];
        // Get week day (starts at 1).
        NSInteger weekday = [[calendar components:unitFlags fromDate:referenceDate] weekday] - 1;
		
        if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == 0) {
            // Today
            [formatter setDateStyle:NSDateFormatterNoStyle];
  			return [NSString stringWithFormat:@"Today, %@", [formatter stringFromDate:self]];
		} else if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == 1) {
            // Yesterday
            [formatter setDateStyle:NSDateFormatterNoStyle];
			return [NSString stringWithFormat:@"Yesterday, %@", [formatter stringFromDate:self]];
        } else if ([suppliedDate compare:referenceDate] == NSOrderedSame) {
            // Day of the week
            NSString* day = [[formatter weekdaySymbols] objectAtIndex:weekday];
			[formatter setDateStyle:NSDateFormatterNoStyle];
			return [NSString stringWithFormat:@"%@, %@", day, [formatter stringFromDate:self]];
        }
    }
	
    // It's not in those eight days.
    [formatter setDateStyle:NSDateFormatterShortStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
	NSString* date = [formatter stringFromDate:self];
	
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
	NSString* time = [formatter stringFromDate:self];
	
	return [NSString stringWithFormat:@"%@, %@", date, time];
}

- (NSString*)relativeLongFormattedDate {
    // Initialize the formatter.
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterFullStyle];
    [formatter setTimeStyle:NSDateFormatterNoStyle];
	
    // Initialize the calendar and flags.
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitWeekday;
    NSCalendar* calendar = [NSCalendar currentCalendar];
	
    // Create reference date for supplied date.
    NSDateComponents *comps = [calendar components:unitFlags fromDate:self];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
	
    NSDate* suppliedDate = [calendar dateFromComponents:comps];
	
    // Iterate through the eight days (tomorrow, today, and the last six).
    int i;
    for (i = -1; i < 7; i++) {
        // Initialize reference date.
        comps = [calendar components:unitFlags fromDate:[NSDate date]];
        [comps setHour:0];
        [comps setMinute:0];
        [comps setSecond:0];
        [comps setDay:[comps day] - i];
        NSDate* referenceDate = [calendar dateFromComponents:comps];
        // Get week day (starts at 1).
        NSInteger weekday = [[calendar components:unitFlags fromDate:referenceDate] weekday] - 1;
		
        if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == 0) {
            // Today
            [formatter setDateStyle:NSDateFormatterNoStyle];
            return [NSString stringWithString:LocalizedString(@"Today")];
        } else if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == 1) {
            // Yesterday
            [formatter setDateStyle:NSDateFormatterNoStyle];
            return [NSString stringWithString:LocalizedString(@"Yesterday")];
        } else if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == -1) {
            // Tomorrow
            [formatter setDateStyle:NSDateFormatterNoStyle];
            return [NSString stringWithString:LocalizedString(@"Tomorrow")];
        } else if ([suppliedDate compare:referenceDate] == NSOrderedSame) {
            // Day of the week
            return [[formatter weekdaySymbols] objectAtIndex:weekday];
        }
    }
	
    // It's not in those eight days.
    return [formatter stringFromDate:self];	
}

- (NSString*)formatTime {
    // Initialize the formatter.
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
	
    return [formatter stringFromDate:self];	
}

- (NSString*)iso8601Formatted {
	return [self formattedDateWithFormatString:@"yyyy-MM-dd'T'HH:mm:ssZ"];
}

- (BOOL)isPastDate {
	NSDate* now = [NSDate date];
	if([[now earlierDate:self] isEqualToDate:self]) {
		return YES;
	} else {
		return NO;
	}	
}

- (BOOL)isDateToday {
	return [[[NSDate date] midnightDate] isEqual:[self midnightDate]];
}

- (BOOL)isDateYesterday {
	return [[[NSDate dateWithTimeIntervalSinceNow:-86400] midnightDate] isEqual:[self midnightDate]];
}

- (NSDate*)midnightDate {
	return [[NSCalendar currentCalendar] dateFromComponents:[[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self]];
}

@end

@implementation NSDate (NSDate_Utility)

- (NSString*)formatString {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	NSString *dateInString = [dateFormatter stringFromDate:self];
	return dateInString;
}

+ (NSString *)currentDateTimeString {
	return [[NSDate date] formatString];
}

@end

@implementation NSDate (NSDate_Helper)

/*
 
 * This guy can be a little unreliable and produce unexpected results,
 
 * you’re better off using daysAgoAgainstMidnight
 
 */

//获取年月日如:19871127.
- (NSString *)getFormatYearMonthDay
{
    
    NSString *string = [NSString stringWithFormat:@"%lu%02lu%02lu",(unsigned long)[self getYear],(unsigned long)[self getMonth],(unsigned long)[self getDay]];
    
    return string;
    
}

//返回当前月一共有几周(可能为4,5,6)
- (int )getWeekNumOfMonth
{
    return [[self endOfMonth] getWeekOfYear] - [[self beginningOfMonth] getWeekOfYear] + 1;
}

//该日期是该年的第几周
- (int )getWeekOfYear
{
    int i;
    
    NSUInteger year = [self getYear];
    
    NSDate *date = [self endOfWeek];
    
    for (i = 1;[[date dateAfterDay:-7 * i] getYear] == year;i++)
        
    {
        
    }
    
    return i;
}

//返回day天后的日期(若day为负数,则为|day|天前的日期)
- (NSDate *)dateAfterDay:(int)day
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // Get the weekday component of the current date
    
    // NSDateComponents *weekdayComponents = [calendar components:NSWeekdayCalendarUnit fromDate:self];
    
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    
    // to get the end of week for a particular date, add (7 – weekday) days
    
    [componentsToAdd setDay:day];
    
    NSDate *dateAfterDay = [calendar dateByAddingComponents:componentsToAdd toDate:self options:0];
    
    return dateAfterDay;
}

//month个月后的日期
- (NSDate *)dateafterMonth:(int)month
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    
    [componentsToAdd setMonth:month];
    
    NSDate *dateAfterMonth = [calendar dateByAddingComponents:componentsToAdd toDate:self options:0];
    
    return dateAfterMonth;
}

//获取日
- (NSUInteger)getDay{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *dayComponents = [calendar components:(NSCalendarUnitDay) fromDate:self];
    
    return [dayComponents day];
}

//获取月
- (NSUInteger)getMonth
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *dayComponents = [calendar components:(NSCalendarUnitMonth) fromDate:self];
    
    return [dayComponents month];
}

//获取年
- (NSUInteger)getYear
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *dayComponents = [calendar components:(NSCalendarUnitYear) fromDate:self];
    
    return [dayComponents year];
}

//获取小时
- (int )getHour {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSUInteger unitFlags =NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute;
    
    NSDateComponents *components = [calendar components:unitFlags fromDate:self];
    
    NSInteger hour = [components hour];
    
    return (int)hour;
}

//获取分钟
- (int)getMinute {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSUInteger unitFlags =NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute;
    
    NSDateComponents *components = [calendar components:unitFlags fromDate:self];
    
    NSInteger minute = [components minute];
    
    return (int)minute;
}

- (int )getHour:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSUInteger unitFlags =NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute;
    
    NSDateComponents *components = [calendar components:unitFlags fromDate:date];
    
    NSInteger hour = [components hour];
    
    return (int)hour;
}

- (int)getMinute:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSUInteger unitFlags =NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay |NSCalendarUnitHour |NSCalendarUnitMinute;
    
    NSDateComponents *components = [calendar components:unitFlags fromDate:date];
    
    NSInteger minute = [components minute];
    
    return (int)minute;
}

//在当前日期前几天
- (NSUInteger)daysAgo {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *components = [calendar components:(NSCalendarUnitDay)
                                    
                                               fromDate:self
                                    
                                                 toDate:[NSDate date]
                                    
                                                options:0];
    
    return [components day];
}

//午夜时间距今几天
- (NSUInteger)daysAgoAgainstMidnight {
    // get a midnight version of ourself:
    
    NSDateFormatter *mdf = [[NSDateFormatter alloc] init];
    
    [mdf setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *midnight = [mdf dateFromString:[mdf stringFromDate:self]];
    
    return (int)[midnight timeIntervalSinceNow] / (60*60*24) *-1;
}

- (NSString *)stringDaysAgo {
    return [self stringDaysAgoAgainstMidnight:YES];
}

- (NSString *)stringDaysAgoAgainstMidnight:(BOOL)flag {
    NSUInteger daysAgo = (flag) ? [self daysAgoAgainstMidnight] : [self daysAgo];
    
    NSString *text = nil;
    
    switch (daysAgo) {
            
        case 0:
            
            text = @"Today";
            
            break;
            
        case 1:
            
            text = @"Yesterday";
            
            break;
            
        default:
            
            text = [NSString stringWithFormat:@"%@ days ago", @(daysAgo)];
            
    }
    
    return text;
}

-(double)RFC822TimeInteral{
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* component = [[NSDateComponents alloc] init];
    [component setYear:-31];
    NSDate* date = [calendar dateByAddingComponents:component toDate:self options:0];
    //DebugLog(@"date is %@", [date description]);
    //DebugLog(@"year is %i, month is %i, day is %i", [date getYear], [date getMonth], [date getDay]);
    
    return [date timeIntervalSince1970];
}

//返回一周的第几天(周末为第一天)
- (NSUInteger)weekday {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *weekdayComponents = [calendar components:(NSCalendarUnitWeekday) fromDate:self];
    
    return [weekdayComponents weekday];
}

//转为NSString类型的
+ (NSDate *)dateFromString:(NSString *)string {
    return [NSDate dateFromString:string withFormat:[NSDate dbFormatString]];
}

+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format {
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    
    [inputFormatter setDateFormat:format];
    
    NSDate *date = [inputFormatter dateFromString:string];
    
    return date;
}

+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format {
    return [date stringWithFormat:format];
}

+ (NSString *)stringFromDate:(NSDate *)date {
    return [date string];
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed {
    /*
     
     * if the date is in today, display 12-hour time with meridian,
     
     * if it is within the last 7 days, display weekday name (Friday)
     
     * if within the calendar year, display as Jan 23
     
     * else display as Nov 11, 2008
     
     */
    
    NSDate *today = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDateComponents *offsetComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                          
                                                     fromDate:today];
    
    NSDate *midnight = [calendar dateFromComponents:offsetComponents];
    
    NSDateFormatter *displayFormatter = [[NSDateFormatter alloc] init];
    
    NSString *displayString = nil;
    
    // comparing against midnight
    
    if ([date compare:midnight] == NSOrderedDescending) {
        
        if (prefixed) {
            
            [displayFormatter setDateFormat:@"'at' h:mm a"]; // at 11:30 am
            
        } else {
            
            [displayFormatter setDateFormat:@"h:mm a"]; // 11:30 am
            
        }
        
    } else {
        
        // check if date is within last 7 days
        
        NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
        
        [componentsToSubtract setDay:-7];
        
        NSDate *lastweek = [calendar dateByAddingComponents:componentsToSubtract toDate:today options:0];
        
        if ([date compare:lastweek] == NSOrderedDescending) {
            
            [displayFormatter setDateFormat:@"EEEE"]; // Tuesday
            
        } else {
            
            // check if same calendar year
            
            NSInteger thisYear = [offsetComponents year];
            
            NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                                
                                                           fromDate:date];
            
            NSInteger thatYear = [dateComponents year];
            
            if (thatYear >= thisYear) {
                
                [displayFormatter setDateFormat:@"MMM d"];
                
            } else {
                
                [displayFormatter setDateFormat:@"MMM d, yyyy"];
                
            }
            
        }
        
        if (prefixed) {
            
            NSString *dateFormat = [displayFormatter dateFormat];
            
            NSString *prefix = @"‘on’ ";
            
            [displayFormatter setDateFormat:[prefix stringByAppendingString:dateFormat]];
            
        }
        
    }
    
    // use display formatter to return formatted date string
    
    displayString = [displayFormatter stringFromDate:date];
    
    return displayString;
}

+ (NSString *)stringForDisplayFromDate:(NSDate *)date {
    return [self stringForDisplayFromDate:date prefixed:NO];
}

- (NSString *)stringWithFormat:(NSString *)format {
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    
    [outputFormatter setDateFormat:format];
    
    NSString *timestamp_str = [outputFormatter stringFromDate:self];
    
    return timestamp_str;
}

- (NSString *)string {
    return [self stringWithFormat:[NSDate dbFormatString]];
}

- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle {
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    
    [outputFormatter setDateStyle:dateStyle];
    
    [outputFormatter setTimeStyle:timeStyle];
    
    NSString *outputString = [outputFormatter stringFromDate:self];
    
    return outputString;
}

//返回周日的的开始时间
- (NSDate *)beginningOfWeek {
    // largely borrowed from "Date and Time Programming Guide for Cocoa"
    // we’ll use the default calendar and hope for the best
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSDate *beginningOfWeek = nil;
    
    BOOL ok = [calendar rangeOfUnit:NSCalendarUnitWeekOfMonth
                          startDate:&beginningOfWeek
                           interval:NULL
                            forDate:self];
    if (ok) {
        return beginningOfWeek;
    }
    
    // couldn’t calc via range, so try to grab Sunday, assuming gregorian style
    // Get the weekday component of the current date
    
    NSDateComponents *weekdayComponents = [calendar components:NSCalendarUnitWeekday fromDate:self];
    
    /*
     
     Create a date components to represent the number of days to subtract from the current date.
     
     The weekday value for Sunday in the Gregorian calendar is 1, so subtract 1 from the number of days to subtract from the date in question.  (If today’s Sunday, subtract 0 days.)
     
     */
    
    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    
    [componentsToSubtract setDay: 0 - ([weekdayComponents weekday] - 1)];
    
    beginningOfWeek = nil;
    
    beginningOfWeek = [calendar dateByAddingComponents:componentsToSubtract toDate:self options:0];
    
    //normalize to midnight, extract the year, month, and day components and create a new date from those components.
    
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                    
                                               fromDate:beginningOfWeek];
    
    return [calendar dateFromComponents:components];
}

//返回当前天的年月日.
- (NSDate *)beginningOfDay {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // Get the weekday component of the current date
    
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                    
                                               fromDate:self];
    
    return [calendar dateFromComponents:components];
}

//返回该月的第一天
- (NSDate *)beginningOfMonth
{
    return [[self dateAfterDay:-(int)[self getDay] + 1] beginningOfDay];
}

//该月的最后一天
- (NSDate *)endOfMonth
{
    return [[[[self beginningOfMonth] dateafterMonth:1] dateAfterDay:-1] beginningOfDay];
}

//返回当前周的周末
- (NSDate *)endOfWeek {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // Get the weekday component of the current date
    
    NSDateComponents *weekdayComponents = [calendar components:NSCalendarUnitWeekday fromDate:self];
    
    NSDateComponents *componentsToAdd = [[NSDateComponents alloc] init];
    
    // to get the end of week for a particular date, add (7 – weekday) days
    
    [componentsToAdd setDay:(7 - [weekdayComponents weekday])];
    
    NSDate *endOfWeek = [calendar dateByAddingComponents:componentsToAdd toDate:self options:0];
    
    return endOfWeek;
}

+ (NSString *)dateFormatString {
    return @"yyyy-MM-dd";
}

+ (NSString *)timeFormatString {
    return @"HH:mm:ss";
}

+ (NSString *)timestampFormatString {
    return @"yyyy-MM-dd HH:mm:ss";
}

// preserving for compatibility
+ (NSString *)dbFormatString {
    return [NSDate timestampFormatString];
}

@end

@implementation NSDate (IM)

#pragma mark Retrieving Intervals

- (NSInteger) minutesAfterDate: (NSDate *) aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger) minutesBeforeDate: (NSDate *) aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_MINUTE);
}

- (float) hoursAfterDate: (NSDate *) aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (ti*1.00 / D_HOUR);
}

- (NSInteger) hoursBeforeDate: (NSDate *) aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_HOUR);
}

- (NSInteger) daysAfterDate: (NSDate *) aDate
{
    NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
    return (NSInteger) (ti / D_DAY);
}

- (NSInteger) daysBeforeDate: (NSDate *) aDate
{
    NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
    return (NSInteger) (ti / D_DAY);
}

// Thanks, dmitrydims
// I have not yet thoroughly tested this
- (NSInteger)distanceInDaysToDate:(NSDate *)anotherDate
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay fromDate:self toDate:anotherDate options:0];
    return components.day;
}

/*标准时间日期描述*/
-(NSString *)formattedTime{
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    NSString * dateNow = [formatter stringFromDate:[NSDate date]];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:[[dateNow substringWithRange:NSMakeRange(8,2)] intValue]];
    [components setMonth:[[dateNow substringWithRange:NSMakeRange(5,2)] intValue]];
    [components setYear:[[dateNow substringWithRange:NSMakeRange(0,4)] intValue]];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *date = [gregorian dateFromComponents:components]; //今天 0点时间
    
    
    float hour = [self hoursAfterDate:date];
    NSString *ret = @"";
    
    //hasAMPM==TURE为12小时制，否则为24小时制
    NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange containsA = [formatStringForHours rangeOfString:@"a"];
    BOOL hasAMPM = containsA.location != NSNotFound;
    
    if (!hasAMPM) { //24小时制
        if (hour <= 24 && hour >= 0) {
            ret = [self formattedDateWithFormatString:@"HH:mm"];
        }else if (hour < 0 && hour >= -24) {
            ret = [self formattedDateWithFormatString:NSLocalizedString(@"NSDateCategory.text8", @"")];
        }else {
            ret = [self formattedDateWithFormatString:@"yyyy-MM-dd"];
        }
    }else {
        if (hour >= 0 && hour <= 6) {
            ret = [self formattedDateWithFormatString:NSLocalizedString(@"NSDateCategory.text9", @"")];
        }else if (hour > 6 && hour <=11 ) {
            ret = [self formattedDateWithFormatString:NSLocalizedString(@"NSDateCategory.text10", @"")];
        }else if (hour > 11 && hour <= 17) {
            ret = [self formattedDateWithFormatString:NSLocalizedString(@"NSDateCategory.text11", @"")];
        }else if (hour > 17 && hour <= 24) {
            ret = [self formattedDateWithFormatString:NSLocalizedString(@"NSDateCategory.text12", @"")];
        }else if (hour < 0 && hour >= -24){
            ret = [self formattedDateWithFormatString:NSLocalizedString(@"NSDateCategory.text13", @"")];
        }else  {
            ret = [self formattedDateWithFormatString:@"yyyy-MM-dd"];
        }
        
    }
    
    return ret;
}

@end
