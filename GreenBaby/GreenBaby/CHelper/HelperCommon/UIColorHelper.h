

/*
* 在RGB模式中，由红、绿、蓝相叠加可以产生其它颜色，因此该模式也叫加色模式。
* 所有显示器、投影设备以及电视机等等许多设备都依赖于这种加色模式来实现的。

* CMYK代表印刷上用的四种颜色，C代表青色，M代表洋红色，Y代表黄色，K代表黑色。
* 因为在实际引用中，青色、洋红色和黄色很难叠加形成真正的黑色，最多不过是褐色而已。
* 因此才引入了K——黑色。黑色的作用是强化暗调，加深暗部色彩。

* Lab模式由三个通道组成，但不是R、G、B通道。它的一个通道是亮度，即L。另外两个是色彩通道，用A和B来表示。
* A通道包括的颜色是从深绿色（底亮度值）到灰色（中亮度值）再到亮粉红色（高亮度值）；
* B通道则是从亮蓝色（底亮度值）到灰色（中亮度值）再到黄色（高亮度值）。
* 因此，这种色彩混合后将产生明亮的色彩。

* 在HSB模式中，H表示色相，S表示饱和度，B表示亮度。
* 色相：是纯色，即组成可见光谱的单色。红色在0度，绿色在120度，蓝色在240度。它基本上是RGB模式全色度的饼状图。
* 饱和度：表示色彩的纯度，为0时为会色。白、黑和其他灰色色彩都没有饱和度的。在最大饱和度时，每一色相具有最纯的色光。
* 亮度：是色彩的明亮读。为0时即为黑色。最大亮度是色彩最鲜明的状态。
*/
#import <UIKit/UIKit.h>

#define SUPPORTS_UNDOCUMENTED_API	0

@interface UIColor (Helper)
// 获取CGColorSpaceModel
@property (nonatomic, readonly) CGColorSpaceModel colorSpaceModel;
// 判断是否能被转换RGB
@property (nonatomic, readonly) BOOL canProvideRGBComponents;


// With the exception of -alpha, these properties will function
// correctly only if this color is an RGB or white color.
// In these cases, canProvideRGBComponents returns YES.
// 返回当前UIColor的属性
@property (nonatomic, readonly) CGFloat red;// Only valid if canProvideRGBComponents is YES
@property (nonatomic, readonly) CGFloat green;// Only valid if canProvideRGBComponents is YES
@property (nonatomic, readonly) CGFloat blue;// Only valid if canProvideRGBComponents is YES
@property (nonatomic, readonly) CGFloat white;// Only valid if colorSpaceModel == kCGColorSpaceModelMonochrome
@property (nonatomic, readonly) CGFloat alpha;
@property (nonatomic, readonly) UInt32 rgbHex;

@property (nonatomic, readonly) CGFloat hue;// Only valid if canProvideRGBComponents is YES
@property (nonatomic, readonly) CGFloat saturation;// Only valid if canProvideRGBComponents is YES
@property (nonatomic, readonly) CGFloat brightness;// Only valid if canProvideRGBComponents is YES
@property (nonatomic, readonly) CGFloat luminance;// (same as brightness, added for naming consistency)



- (NSString *)colorSpaceString;
- (NSArray *)arrayFromRGBAComponents;

// 在HSB模式中，H表示色相，S表示饱和度，B表示亮度。
// Bulk access to RGB and HSB components of the color
// HSB components are converted from the RGB components
- (BOOL)red:(CGFloat *)r green:(CGFloat *)g blue:(CGFloat *)b alpha:(CGFloat *)a;
- (BOOL)hue:(CGFloat *)h saturation:(CGFloat *)s brightness:(CGFloat *)b alpha:(CGFloat *)a;

// 返回一个颜色的灰度表现
// 灰度级颜色
- (UIColor *)colorByLuminanceMapping;


//pragma mark Arithmetic算术运算 operations

// 彩色算术运算
// 乘法
- (UIColor *)colorByMultiplyingByRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
// 加法
- (UIColor *)       colorByAddingRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
// 减法 加亮
- (UIColor *) colorByLighteningToRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
// 昏暗
- (UIColor *)  colorByDarkeningToRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;

- (UIColor *)colorByMultiplyingBy:(CGFloat)f;
- (UIColor *)       colorByAdding:(CGFloat)f;
- (UIColor *) colorByLighteningTo:(CGFloat)f;
- (UIColor *)  colorByDarkeningTo:(CGFloat)f;

- (UIColor *)colorByMultiplyingByColor:(UIColor *)color;
- (UIColor *)       colorByAddingColor:(UIColor *)color;
- (UIColor *) colorByLighteningToColor:(UIColor *)color;
- (UIColor *)  colorByDarkeningToColor:(UIColor *)color;


//pragma mark Complementary Colors互补色, etc

// Related colors 相近的颜色
// 最接近的黑白对比度
- (UIColor *)contrastingColor;			// A good contrasting极不相同的，差异大的 color: will be either black or white
// 最接近的蜡笔色
- (UIColor *)complementaryColor;		// A complementary color互补色 that should look good with this color
- (NSArray*)triadicColors;				// Two colors that should look good with this color 三色系Triadic 以2种相对色系的颜色配合主色做成色彩平衡的效果让版面感觉更丰富.
- (NSArray*)analogousColorsWithStepAngle:(CGFloat)stepAngle pairCount:(int)pairs;	// Multiple pairs of colors  analogous:模拟的 Angle:角 stepAngle:步距角

//pragma mark String utilities

// String representations of the color
// String表示的颜色
- (NSString *)stringFromColor;
// Hex表示的颜色
- (NSString *)hexStringFromColor;

// 已命名的颜色，符合一个最密切的 The named color that matches this one most closely

// 最接近的颜色名称
- (NSString *)closestColorName;
// 最接近的蜡笔颜色名称
- (NSString *)closestCrayonName;


//pragma mark Class methods

// 建立颜色
+ (UIColor *)randomColor;
+ (UIColor *)colorWithRGBHex:(UInt32)hex;
+ (UIColor *)colorWithString:(NSString *)stringToConvert;//例子，stringToConvert {12,254,255,255}
+ (UIColor *)colorWithHexString:(NSString *)stringToConvert;//例子，stringToConvert #ffffff
+ (UIColor *)colorWithName:(NSString *)cssColorName;
+ (UIColor *)crayonWithName:(NSString *)crayonColorName;
+ (UIColor *)color:(UIColor *)color_ withAlpha:(float)alpha_;

// Return a dictionary mapping color names to colors.
// The named are from the css3 color specification.
// 返回一个字典映射的颜色名称。
// 命名来自CSS3的颜色规范。
+ (NSDictionary *)namedColors;

// Return a dictionary mapping color names to colors
// The named are standard Crayola style colors
// 返回一个字典映射的颜色名称。
// 命名来自Crayola蜡笔的颜色规范。
+ (NSDictionary *)namedCrayons;

// Build a color with the given HSB values
// 在HSB模式中，H表示色相，S表示饱和度，B表示亮度。
//+ (UIColor *)colorWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha;

//pragma mark Color Space Conversions

// Low level conversions between RGB and HSL spaces
+ (void)hue:(CGFloat)h saturation:(CGFloat)s brightness:(CGFloat)v toRed:(CGFloat *)r green:(CGFloat *)g blue:(CGFloat *)b;
+ (void)red:(CGFloat)r green:(CGFloat)g blue:(CGFloat)b toHue:(CGFloat *)h saturation:(CGFloat *)s brightness:(CGFloat *)v;

@end


