



#import <UIKit/UIKit.h>


@interface NSFileManager (Helper)

//获取文件夹下指定文件名的文件
+ (NSString *) pathForItemNamed: (NSString *) fname inFolder: (NSString *) path;

// 不区分大小写比较，深枚举 获取文件夹下指定扩展名的所有文件
+ (NSArray *) directoryContentsAtPath: (NSString *) path  extension: (NSString *) ext;

//获取文件夹下所有文件
+ (NSArray *) directoryContentsAtPath: (NSString *) path;

@end

