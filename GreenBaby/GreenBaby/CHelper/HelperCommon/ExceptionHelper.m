

#import "ExceptionHelper.h"

#ifdef ENABLE_EXCEPTIONS

@implementation ExceptionHelper
+ (void)generateStackTraceForException:(NSException*)exception {
	NSString* processIdentifier = [[NSNumber numberWithInt:[[NSProcessInfo processInfo] processIdentifier]] stringValue];
	NSString* stackAddresses = [[exception callStackReturnAddresses] componentsJoinedByString:@" "];
	NSMutableString* debugInfo = [NSMutableString string];
	[debugInfo appendString:@"\n"];
	[debugInfo appendString:@"================================\n"];
	[debugInfo appendString:@"异常捕获:\n"];
	[debugInfo appendString:@"--------------------------------\n"];
	[debugInfo appendFormat:@"名字: %@\n", exception.name];
	[debugInfo appendFormat:@"原因: %@\n", exception.reason];
	if(exception.userInfo) {
		[debugInfo appendFormat:@"附加信息: %@\n", exception.userInfo];
	} else {
		[debugInfo appendString:@"没有附加信息..\n"];
	}
	[debugInfo appendString:@"--------------------------------\n"];
	[debugInfo appendFormat:@"在GDB中运行以下命令来查看完整的堆栈跟踪:\n\nshell atos -p %@ %@\n\n", processIdentifier, stackAddresses];
	[debugInfo appendString:@"================================\n"];
	NSLog(@"%@", debugInfo);

	while(1) {
		// 当你运行此命令时，保持进程在线
	}
}
@end

#endif
