
#import "CHelperCommon.h"

CGFloat kDefaultToolbarHeight = 44.0f;
CGFloat kDefaultTabBarHeight = 49.0f;
CGFloat kKeyboardHeight = 216.0f;

CGFloat kDefaultButtonWidth = 80.0f;
CGFloat kDefaultButtonHeight = 30.0f;

CGFloat kDefaultTransitionDuration = 0.3f;
CGFloat kDefaultFastTransitionDuration = 0.2f;
CGFloat kDefaultFlipTransitionDuration = 0.7f;

CGFloat kSoftCornerRadius = 15.0f;
CGFloat kDefaultCornerRadius = 8.0f;
CGFloat kHardCornerRadius = 5.0f;

static CGRect kApplicationFrame()
{
	CGRect app_frame = [UIScreen mainScreen].applicationFrame;//r=0，20，320，460
	return app_frame;
}
static CGRect kApplicationBounds()
{
	CGRect app_bounds = [UIScreen mainScreen].bounds;//r=0，0，320，480
	return app_bounds;
}

static CGRect kTabViewFrame()
{
	CGRect app_frame = [UIScreen mainScreen].applicationFrame;
	CGRect table_frame = CGRectMake(0.0f, 0.0f, app_frame.size.width, app_frame.size.height - kDefaultTabBarHeight);
	return table_frame;
}

void INLog(NSString *message, ...)
{
    va_list args;//VA_LIST 是在C语言中解决变参问题的一组宏
    va_start(args, message);
    NSString *output = [[NSString alloc] initWithFormat:message arguments:args];
    va_end(args);
    
#ifdef DEBUG
    NSLog(@"%@", output);
#else
    
#endif
}

@implementation FFHelperCommon
#pragma mark CoreMotion Methods 加速计方法 threshold:极限值
//是否摇晃
+(BOOL)accelerationIsShaking:(CMAccelerometerData*)last current:(CMAccelerometerData*)current threshold:(double)threshold
{
	double
	deltaX = fabs(last.acceleration.x - current.acceleration.x),
	deltaY = fabs(last.acceleration.y - current.acceleration.y),
	deltaZ = fabs(last.acceleration.z - current.acceleration.z);
	
	return
	(deltaX > threshold && deltaY > threshold) ||
	(deltaX > threshold && deltaZ > threshold) ||
	(deltaY > threshold && deltaZ > threshold);
}
#pragma mark Math Point methods 点函数
//两点之间的中间点
+(CGPoint)centerPointBetweenTwoPoints:(CGPoint)firstPoint secondPoint:(CGPoint)secondPoint 
{
	float dx = fabs( firstPoint.x - secondPoint.x);
	float dy = fabs( firstPoint.y - secondPoint.y);
	
	float x =  firstPoint.x > secondPoint.x ? secondPoint.x : firstPoint.x;
	float y =  firstPoint.y > secondPoint.y ? secondPoint.y : firstPoint.y;
	
	return CGPointMake( x + (dx/2), y + (dy/2) );
}

//两点之间的距离
+(CGFloat)distanceBetweenTwoPoints:(CGPoint)fromPoint toPoint:(CGPoint)toPoint {	
	float x = toPoint.x - fromPoint.x;
	float y = toPoint.y - fromPoint.y;
	
	return sqrt(x * x + y * y);
}
#pragma mark utility Float methods 浮点函数
//交换两个float 
+(void)swapf:(CGFloat*)f1 with:(CGFloat*)f2
{
	CGFloat t = *f1;
	*f1 = *f2;
	*f2 = t;
}

@end