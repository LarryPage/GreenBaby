

#import "FFCache.h"

#ifndef __OPTIMIZE__
#define CHECK_FOR_FFCACHE_PLIST() if([key isEqualToString:@"directoryInfo.plist"]) { \
		NSLog(@"directoryInfo.plist is a reserved key and can not be modified."); \
		return; }
#else
#define CHECK_FOR_FFCACHE_PLIST() if([key isEqualToString:@"directoryInfo.plist"]) return;
#endif


static NSString* _FFCacheDirectory;

static inline NSString* FFCacheDirectory() {
	if(!_FFCacheDirectory) {
		NSString* cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		_FFCacheDirectory = [[cachesDirectory  stringByAppendingPathComponent:@"FFCache"] copy];
	}
	
	return _FFCacheDirectory;
}

static inline NSString* cachePathForKey(NSString* key) {
	return [FFCacheDirectory() stringByAppendingPathComponent:key];
}

static FFCache* __instance;

@interface FFCache ()
- (void)removeItemFromCache:(NSString*)key;
- (void)performDiskWriteOperation:(NSInvocation *)invoction;
- (void)saveCacheDictionary;
@end

#pragma mark -

@implementation FFCache
@synthesize defaultTimeoutInterval;

+ (FFCache*)currentCache {
	@synchronized(self) {
		if(!__instance) {
			__instance = [[FFCache alloc] init];
			__instance.defaultTimeoutInterval = 86400;//60*60*24
		}
	}
	
	return __instance;
}
+ (NSString*) defaultKeyForURL:(NSURL*)url {
	return [NSString stringWithFormat:@"%@", @([[url description] hash])];
}

- (id)init {
	if((self = [super init])) {
		NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:cachePathForKey(@"directoryInfo.plist")];
		
		if([dict isKindOfClass:[NSDictionary class]]) {
			cacheDictionary = [dict mutableCopy];
		} else {
			cacheDictionary = [[NSMutableDictionary alloc] init];
		}
		
		diskOperationQueue = [[NSOperationQueue alloc] init];
		
		[[NSFileManager defaultManager] createDirectoryAtPath:FFCacheDirectory() 
								  withIntermediateDirectories:YES 
												   attributes:nil 
														error:NULL];
		
        //考虑 有可能不考虑缓存时间　不删除过期数据 by lxc modify
//		for(NSString* key in cacheDictionary) {
//			NSDate* date = [cacheDictionary objectForKey:key];
//			if([[[NSDate date] earlierDate:date] isEqualToDate:date]) {
//				[[NSFileManager defaultManager] removeItemAtPath:cachePathForKey(key) error:NULL];
//			}
//		}
	}
	
	return self;
}

- (void)clearCache {
	for(NSString* key in [cacheDictionary allKeys]) {
		[self removeItemFromCache:key];
	}
	
	[self saveCacheDictionary];
}

- (void)removeCacheForKey:(NSString*)key {
	CHECK_FOR_FFCACHE_PLIST();

	[self removeItemFromCache:key];
	[self saveCacheDictionary];
}

- (void)removeItemFromCache:(NSString*)key {
	NSString* cachePath = cachePathForKey(key);
	
	NSInvocation* deleteInvocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(deleteDataAtPath:)]];
	[deleteInvocation setTarget:self];
	[deleteInvocation setSelector:@selector(deleteDataAtPath:)];
	[deleteInvocation setArgument:&cachePath atIndex:2];
	
	[self performDiskWriteOperation:deleteInvocation];
	[cacheDictionary removeObjectForKey:key];
}

- (BOOL)hasCacheForKey:(NSString*)key {
	NSDate* date = [cacheDictionary objectForKey:key];
	if(!date) return NO;
	if([[[NSDate date] earlierDate:date] isEqualToDate:date]) return NO;
	return [[NSFileManager defaultManager] fileExistsAtPath:cachePathForKey(key)];
}

- (BOOL)hasNoCacheForKey:(NSString*)key{
    return [[NSFileManager defaultManager] fileExistsAtPath:cachePathForKey(key)];
}

#pragma mark -
#pragma mark Copy file methods

- (void)copyFilePath:(NSString*)filePath asKey:(NSString*)key {
	[self copyFilePath:filePath asKey:key withTimeoutInterval:self.defaultTimeoutInterval];
}

- (void)copyFilePath:(NSString*)filePath asKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval {
	[[NSFileManager defaultManager] copyItemAtPath:filePath toPath:cachePathForKey(key) error:NULL];
	[cacheDictionary setObject:[NSDate dateWithTimeIntervalSinceNow:timeoutInterval] forKey:key];
	[self performSelectorOnMainThread:@selector(saveAfterDelay) withObject:nil waitUntilDone:YES];
}																												   

#pragma mark -
#pragma mark Data methods

- (void)setData:(NSData*)data forKey:(NSString*)key {
	[self setData:data forKey:key withTimeoutInterval:self.defaultTimeoutInterval];
}

- (void)setData:(NSData*)data forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval {
	CHECK_FOR_FFCACHE_PLIST();
	
	NSString* cachePath = cachePathForKey(key);
	NSInvocation* writeInvocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:@selector(writeData:toPath:)]];
	[writeInvocation setTarget:self];
	[writeInvocation setSelector:@selector(writeData:toPath:)];
	[writeInvocation setArgument:&data atIndex:2];
	[writeInvocation setArgument:&cachePath atIndex:3];
	
	[self performDiskWriteOperation:writeInvocation];
	[cacheDictionary setObject:[NSDate dateWithTimeIntervalSinceNow:timeoutInterval] forKey:key];
	
	[self performSelectorOnMainThread:@selector(saveAfterDelay) withObject:nil waitUntilDone:YES]; // Need to make sure the save delay get scheduled in the main runloop, not the current threads
}

- (void)saveAfterDelay { // Prevents multiple-rapid saves from happening, which will slow down your app
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(saveCacheDictionary) object:nil];
	[self performSelector:@selector(saveCacheDictionary) withObject:nil afterDelay:0.3];
}

- (NSData*)dataForKey:(NSString*)key {
	if([self hasCacheForKey:key]) {
		return [NSData dataWithContentsOfFile:cachePathForKey(key) options:0 error:NULL];
	} else {
		return nil;
	}
}

- (NSData*)dataNoCacheForKey:(NSString*)key {
	if([[NSFileManager defaultManager] fileExistsAtPath:cachePathForKey(key)]) {
		return [NSData dataWithContentsOfFile:cachePathForKey(key) options:0 error:NULL];
	} else {
		return nil;
	}
}

- (void)writeData:(NSData*)data toPath:(NSString *)path; {
	[data writeToFile:path atomically:YES];
} 

- (void)deleteDataAtPath:(NSString *)path {
	[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

- (void)saveCacheDictionary {
	@synchronized(self) {
		[cacheDictionary writeToFile:cachePathForKey(@"directoryInfo.plist") atomically:YES];
	}
}

#pragma mark -
#pragma mark String methods

- (NSString*)stringForKey:(NSString*)key {
	return [[[NSString alloc] initWithData:[self dataForKey:key] encoding:NSUTF8StringEncoding] autorelease];
}

- (void)setString:(NSString*)aString forKey:(NSString*)key {
	[self setString:aString forKey:key withTimeoutInterval:self.defaultTimeoutInterval];
}

- (void)setString:(NSString*)aString forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval {
	[self setData:[aString dataUsingEncoding:NSUTF8StringEncoding] forKey:key withTimeoutInterval:timeoutInterval];
}

#pragma mark -
#pragma mark Image methds

#if TARGET_OS_IPHONE

- (UIImage*)imageForKey:(NSString*)key {
	return [UIImage imageWithData:[self dataForKey:key]];
}

- (void)setImage:(UIImage*)anImage forKey:(NSString*)key {
	[self setImage:anImage forKey:key withTimeoutInterval:self.defaultTimeoutInterval];
}

- (void)setImage:(UIImage*)anImage forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval {
	[self setData:UIImagePNGRepresentation(anImage) forKey:key withTimeoutInterval:timeoutInterval];
}


#else

- (NSImage*)imageForKey:(NSString*)key {
	return [[[NSImage alloc] initWithData:[self dataForKey:key]] autorelease];
}

- (void)setImage:(NSImage*)anImage forKey:(NSString*)key {
	[self setImage:anImage forKey:key withTimeoutInterval:self.defaultTimeoutInterval];
}

- (void)setImage:(NSImage*)anImage forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval {
	[self setData:[[[anImage representations] objectAtIndex:0] representationUsingType:NSPNGFileType properties:nil]
		   forKey:key withTimeoutInterval:timeoutInterval];
}

#endif

#pragma mark -
#pragma mark Property List methods

- (NSData*)plistForKey:(NSString*)key; {  
	NSData* plistData = [self dataForKey:key];
	
	return [NSPropertyListSerialization propertyListFromData:plistData
											mutabilityOption:NSPropertyListImmutable
													  format:nil
											errorDescription:nil];
}

- (void)setPlist:(id)plistObject forKey:(NSString*)key; {
	[self setPlist:plistObject forKey:key withTimeoutInterval:self.defaultTimeoutInterval];
}

- (void)setPlist:(id)plistObject forKey:(NSString*)key withTimeoutInterval:(NSTimeInterval)timeoutInterval; {
	// Binary plists are used over XML for better performance
	NSData* plistData = [NSPropertyListSerialization dataFromPropertyList:plistObject 
																   format:NSPropertyListBinaryFormat_v1_0
														 errorDescription:NULL];
	
	[self setData:plistData forKey:key withTimeoutInterval:timeoutInterval];
}

#pragma mark -
#pragma mark Disk writing operations

- (void)performDiskWriteOperation:(NSInvocation *)invoction {
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithInvocation:invoction];
	[diskOperationQueue addOperation:operation];
	[operation release];
}

#pragma mark -

- (void)dealloc {
	[diskOperationQueue release];
	[cacheDictionary release];
	[super dealloc];
}

@end