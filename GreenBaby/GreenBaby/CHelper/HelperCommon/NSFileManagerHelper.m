
#import "NSFileManagerHelper.h"


@implementation NSFileManager (Helper)
+ (NSString *) pathForItemNamed: (NSString *) fname inFolder: (NSString *) path
{
	NSString *file;
	NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:path];
	while (file = [dirEnum nextObject]) 
		if ([[file lastPathComponent] isEqualToString:fname]) 
			return [path stringByAppendingPathComponent:file];
	return nil;
}


+ (NSArray *) directoryContentsAtPath: (NSString *) path  extension: (NSString *) ext
{
	NSString *file;
	NSMutableArray *results = [NSMutableArray array];
	NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:path];
	while (file = [dirEnum nextObject]) 
		if ([[file pathExtension] caseInsensitiveCompare:ext] == NSOrderedSame)
			[results addObject:[path stringByAppendingPathComponent:file]];
	return results;
}

+ (NSArray *) directoryContentsAtPath: (NSString *) path
{
	NSString *file;
	NSMutableArray *results = [NSMutableArray array];
	NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:path];
	while (file = [dirEnum nextObject])
	{
		BOOL isDir;
		[[NSFileManager defaultManager] fileExistsAtPath:[path stringByAppendingPathComponent:file] isDirectory: &isDir];
		if (!isDir) [results addObject:file];
	}
	return results;
}

@end



