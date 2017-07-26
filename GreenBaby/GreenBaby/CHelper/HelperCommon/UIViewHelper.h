
#import <UIKit/UIKit.h>


@interface UIView (Helper)

//ios8.0 和 SMSViewController 中picker.view似有方法有冲突
//-(void)setOrigin:(CGPoint)newOrigin;
//-(void)setSize:(CGSize)heightWidth;

-(void)centerInView:(UIView*)containingView;
-(void)centerInView:(UIView*)containingView xOffset:(CGFloat)x_offset yOffset:(CGFloat)y_offset;
// 保存成图片
-(UIImage*)dumpImage;


// 递归设置clipsToBounds
- (void)setClipsToBoundsRecursively:(BOOL)clips;
// 输出部分属性信息
- (void)dumpInfo:(NSInteger)inDepth;
// 移动至上层
- (void)moveToSuperview:(UIView *)inSuperview;
//通过UIView获取它的UIViewController
-(UIViewController*)getViewController;

// 便捷方法
- (CGFloat)x;
- (CGFloat)y;
- (CGFloat)width;
- (CGFloat)height;

@end
