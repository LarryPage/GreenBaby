
#import <Foundation/Foundation.h>

//用法
//if ([[FFCache currentCache] hasCacheForKey:_key]) {
//    self.responseData =[NSMutableData dataWithData:[[FFCache currentCache] dataForKey:_key]];
//}
//else{
//    [[FFCache currentCache] setData:_responseData forKey:_key];
//}

@interface FFCache : NSObject {
@private
	NSMutableDictionary* cacheDictionary;
	NSOperationQueue* diskOperationQueue;
	NSTimeInterval defaultTimeoutInterval;
}

+ (FFCache*)currentCache;

+ (NSString*) defaultKeyForURL:(NSURL*)url;

- (void)clearCache;
- (void)removeCacheForKey:(NSString*)key;

- (BOOL)hasCacheForKey:(NSString*)key;
- (BOOL)hasNoCacheForKey:(NSString*)key;//不考虑缓存时间，真接判断以前缓存数据 by lxc modify

- (NSData*)dataForKey:(NSString*)key;
- (NSData*)dataNoCacheForKey:(NSString*)key;//不考虑缓存时间，真接读取以前缓存数据 by lxc modify
- (void)setData:(NSData*)data forKey:(NSString*)key;
- (void)setData:(NSData*)data forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;

- (NSString*)stringForKey:(NSString*)key;
- (void)setString:(NSString*)aString forKey:(NSString*)key;
- (void)setString:(NSString*)aString forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;

#if TARGET_OS_IPHONE
- (UIImage*)imageForKey:(NSString*)key;
- (void)setImage:(UIImage*)anImage forKey:(NSString*)key;
- (void)setImage:(UIImage*)anImage forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;
#else
- (NSImage*)imageForKey:(NSString*)key;
- (void)setImage:(NSImage*)anImage forKey:(NSString*)key;
- (void)setImage:(NSImage*)anImage forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;
#endif

- (NSData*)plistForKey:(NSString*)key;
- (void)setPlist:(id)plistObject forKey:(NSString*)key;
- (void)setPlist:(id)plistObject forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;

- (void)copyFilePath:(NSString*)filePath asKey:(NSString*)key;
- (void)copyFilePath:(NSString*)filePath asKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval;	

@property(nonatomic,assign) NSTimeInterval defaultTimeoutInterval; // Default is 1 day
@end