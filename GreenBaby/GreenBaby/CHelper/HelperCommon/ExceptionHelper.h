

#ifdef ENABLE_EXCEPTIONS
#import <Foundation/Foundation.h>

@interface ExceptionHelper : NSObject {

}

//显示完整的可用的信息异常
+ (void)generateStackTraceForException:(NSException*)exception;

@end
#endif