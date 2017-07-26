


#import <Foundation/Foundation.h>

@interface NSData (Helper)

/**
 *计算此数据的MD5哈希使用CC_MD5。
 *
 *@返回该数据的MD5哈希
 */
 
@property (nonatomic, readonly) NSString* md5Hash;

/**
 *计算此使用CC_SHA1数据的SHA1哈希。
 *
 *@返回这个数据的SHA1哈希
 */
@property (nonatomic, readonly) NSString* sha1Hash;

- (BOOL)isJPEG;
- (BOOL)isPNG;
- (NSString *)imageType;

@end


@interface NSData (Base64)

+ (NSData *) dataFromBase64String: (NSString *) base64String;
- (id) initWithBase64String: (NSString *) base64String;
- (NSString *) base64EncodedString;

@end

@interface NSData (NSData_Utility)

- (NSString *)base64String;

@end

@interface NSData (AESAdditions)
- (NSData*)AES128EncryptWithKey:(NSString*)key;
- (NSData*)AES128DecryptWithKey:(NSString*)key;
@end