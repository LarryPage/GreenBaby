
#import <Foundation/Foundation.h>

@interface NSString (Helper)
- (BOOL) isEmpty;
/**
 * Determines if the string contains only whitespace and newlines.
 */
- (BOOL)isWhitespaceAndNewlines;
/**
 * Determines if the string is empty or contains only whitespace.
 */
- (BOOL)isEmptyOrWhitespace;
- (BOOL)isMobileNumber;
///////////////////////////////////////////////////////////////////////////////////////////////////
// MD5值
- (NSString*)md5Hash  ;
// Hash值
- (NSString*)sha1Hash ;
///////////////////////////////////////////////////////////////////////////////////////////////////
// 转换URL第一种方式
- (NSString*)stringByURLEncodingStringParameter;
// 转换URL第二种方式
- (NSString*)stringByURLEncodingStringParameterWithEncoding:(NSStringEncoding)stringEncoding ;


- (NSString *)urlencode;
- (NSString *)urldecode;

// 返回一个自适应的高度给予所需属性
- (CGFloat)heightWithPadding:(float)padding minimumHeight:(float)minimumHeight maximumHeight:(float)maximumHeight fontSize:(float)fontSize;
//dynamically adjust its height and width to fit the text in UILabel
- (CGSize)adjustSizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size;

/**
 * Parses a URL query string into a dictionary.
 */
- (NSDictionary*)queryDictionaryUsingEncoding:(NSStringEncoding)encoding;

/**
 * Parses a URL, adds query parameters to its query, and re-encodes it as a new URL.
 */
- (NSString*)stringByAddingQueryDictionary:(NSDictionary*)query;

/**
 * Compares two strings expressing software versions.
 *
 * The comparison is (except for the development version provisions noted below) lexicographic
 * string comparison. So as long as the strings being compared use consistent version formats,
 * a variety of schemes are supported. For example "3.02" < "3.03" and "3.0.2" < "3.0.3". If you
 * mix such schemes, like trying to compare "3.02" and "3.0.3", the result may not be what you
 * expect.
 *
 * Development versions are also supported by adding an "a" character and more version info after
 * it. For example "3.0a1" or "3.01a4". The way these are handled is as follows: if the parts
 * before the "a" are different, the parts after the "a" are ignored. If the parts before the "a"
 * are identical, the result of the comparison is the result of NUMERICALLY comparing the parts
 * after the "a". If the part after the "a" is empty, it is treated as if it were "0". If one
 * string has an "a" and the other does not (e.g. "3.0" and "3.0a1") the one without the "a"
 * is newer.
 *
 * Examples (?? means undefined):
 *   "3.0" = "3.0"
 *   "3.0a2" = "3.0a2"
 *   "3.0" > "2.5"
 *   "3.1" > "3.0"
 *   "3.0a1" < "3.0"
 *   "3.0a1" < "3.0a4"
 *   "3.0a2" < "3.0a19"  <-- numeric, not lexicographic
 *   "3.0a" < "3.0a1"
 *   "3.02" < "3.03"
 *   "3.0.2" < "3.0.3"
 *   "3.00" ?? "3.0"
 *   "3.02" ?? "3.0.3"
 *   "3.02" ?? "3.0.2"
 */
- (NSComparisonResult)versionStringCompare:(NSString *)other;

// 使用NSArray作为参数格式化字符串
+ (NSString *)stringWithFormat:(NSString *) format withArray:(NSArray *) valueArray;

@end


@interface NSString (NSString_ChineseToPinyin)
//中文转拼音
- (NSString *) pinyinFromChiniseString;
- (char) sortSectionTitle;
// 获取拼音首字母
- (NSString *)intialLettles;
- (NSData *)base64Data;
@end

@interface NSString (QOAEncoding) 
- (NSString *)URLEncodedString;
- (NSString*)URLDecodedString;
@end

@interface NSString (NSStringUtils)
- (NSString*)encodeAsURIComponent;
- (NSString*)escapeHTML;
- (NSString*)unescapeHTML;
+ (NSString*)localizedString:(NSString*)key;
+ (NSString*)base64encode:(NSString*)str;
@end
