
#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

extern CGFloat kDefaultToolbarHeight;
extern CGFloat kDefaultTabBarHeight;
extern CGFloat kKeyboardHeight;

// convenient default control sizes
extern CGFloat kDefaultButtonWidth;
extern CGFloat kDefaultButtonHeight;

extern CGFloat kDefaultTransitionDuration;
extern CGFloat kDefaultFastTransitionDuration;
extern CGFloat kDefaultFlipTransitionDuration;

extern CGFloat kSoftCornerRadius;
extern CGFloat kDefaultCornerRadius;
extern CGFloat kHardCornerRadius;

static CGRect kApplicationFrame();
static CGRect kApplicationBounds();

static CGRect kTabViewFrame();

void INLog(NSString *message, ...);

@interface FFHelperCommon : NSObject 
{
	
}
//iOS 晃动手势 http://www.2cto.com/kf/201404/290786.html
+(BOOL)accelerationIsShaking:(CMAccelerometerData *)last current:(CMAccelerometerData *)current threshold:(double)threshold; //是否摇晃
+(CGPoint)centerPointBetweenTwoPoints:(CGPoint)firstPoint secondPoint:(CGPoint)secondPoint;// 两点之间的中间点
+(CGFloat)distanceBetweenTwoPoints:(CGPoint)fromPoint toPoint:(CGPoint)toPoint;// 两点之间的距离
+(void)swapf:(CGFloat*)f1 with:(CGFloat*)f2; // 交换两个float

@end