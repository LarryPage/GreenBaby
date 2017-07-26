

#import <Foundation/Foundation.h>


@interface NSURL (Helper)

/*
 * 返回URL的基本字符串，将包含斜线
 *
 * 例如:
 * NSURL is http://www.cnn.com/full/path?query=string&key=value
 * baseString : http://www.cnn.com/
 */
- (NSString*)baseString;

@end
