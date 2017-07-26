

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>


@interface UIImage (Helper)

/*
 * 创建一个图像的内容从URL
 */
+ (UIImage*)imageWithContentsOfURL:(NSURL*)url;

/*
 * 创建一个图像的内容从资源文件中取得(相对路径)
 * the main bundle's resource path
 */
+ (UIImage*)imageWithResourceName:(NSString*)pathCompontent;

/*
 * 创建一个TintedColor的UIImage
 */
- (UIImage *)imageTintedWithColor:(UIColor *)inColor;
/*
 * 旋转：根据图片方向旋转
 */
+(UIImage *)rotateImage:(UIImage *)aImage withOrientation:(UIImageOrientation)imageOrientation;
/*
 * 旋转 包括: 方向 大小
 */
- (UIImage*)rotate:(UIImageOrientation)orient scale:(CGSize)size; 
/*
 * 尺寸缩放到指定大小的图像，不是内容
 */
- (UIImage*)scaleToSize:(CGSize)size;

/* 缩放 包括: 大小, 边框颜色, 圆角半径, 阴影
 * Aspect scale with border color, and corner radius, and shadow
 */
- (UIImage*)aspectScaleToMaxSize:(CGFloat)size withBorderSize:(CGFloat)borderSize borderColor:(UIColor*)aColor cornerRadius:(CGFloat)aRadius shadowOffset:(CGSize)aOffset shadowBlurRadius:(CGFloat)aBlurRadius shadowColor:(UIColor*)aShadowColor;

/*
 * 缩放 包括: 大小, 阴影
 */
- (UIImage*)aspectScaleToMaxSize:(CGFloat)size withShadowOffset:(CGSize)aOffset blurRadius:(CGFloat)aRadius color:(UIColor*)aColor;

/*
 * 缩放 包括: 大小, 圆角半径
 */
- (UIImage*)aspectScaleToMaxSize:(CGFloat)size withCornerRadius:(CGFloat)aRadius;

/*
 * 缩放 包括: 大小
 */
- (UIImage*)aspectScaleToMaxSize:(CGFloat)size;

/*
 * 缩放 包括: 正方体(矩形)大小
 */
- (UIImage*)aspectScaleToSize:(CGSize)size;


/*
 * 定义图像CGRect，然后填充颜色
 */
- (void)drawInRect:(CGRect)rect withAlphaMaskColor:(UIColor*)aColor;

/*
 * 定义图像CGRect，然后填充颜色渐变(NSArray中包含两种颜色)
 */
- (void)drawInRect:(CGRect)rect withAlphaMaskGradient:(NSArray*)colors;
- (void)drawInRect:(CGRect)rect withAlphaMaskGradientTop:(UIColor*)colorTop Bottom:(UIColor*)colorBottom;

- (CGImageRef)mask;

@end

typedef enum  {
    topToBottom = 0,//从上到小
    leftToRight = 1,//从左到右
    upleftTolowRight = 2,//左上到右下
    uprightTolowLeft = 3,//右上到左下
}GradientType;

@interface UIImage (Utility)

- (UIImage *)scaleToSize:(CGSize)size;
- (NSString *)base64String;

- (UIImage *)compressedImage;
- (UIImage *)compressedImage:(CGSize)size;
- (CGFloat)compressionQuality;
- (NSData *)compressedData;
- (NSData *)compressedData:(CGFloat)compressionQuality;

- (NSString *)contentType;

+ (UIImage *)createImageWithColor: (UIColor *) color;
+ (UIImage *)createImageWithColor: (UIColor *) color withSize:(CGSize)size;

//裁剪部分为新图
- (UIImage *)cropToRect:(CGRect)rect;
//生成指定大小的字图
+ (UIImage*)imageWithString:(NSString *)word ToSize:(CGSize)size;

//!@brief 建议颜色设置为2个相近色为佳，设置3个相近色能形成拟物化的凸起感
+ (UIImage*)imageFromColors:(NSArray *)colors ByGradientType:(GradientType)gradientType ToSize:(CGSize)size;

@end

@interface UIImage (ColorImage)

+ (UIImage *)blueColorImage;
+ (UIImage *)blueHighlightColorImage;
+ (UIImage *)greenColorImage;
+ (UIImage *)greenHighlightColorImage;
+ (UIImage *)grayColorImage;
+ (UIImage *)grayHighlightColorImage;
+ (UIImage *)roundedGrayColorImage;
+ (UIImage *)roundedGrayHighlightColorImage;
+ (UIImage *)transparentBlueColorImage;
+ (UIImage *)transparentBlueHighlightColorImage;

@end

@interface UIImage (Capture)

+(UIImage *)captureImageFromView:(UITableView *)tableview;
+(UIImage *)captureScreen;

@end

#endif