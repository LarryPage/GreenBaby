

#if TARGET_OS_IPHONE
#import "UIImageHelper.h"
#import <CoreGraphics/CoreGraphics.h>
#import "NSDataHelper.h"

//交换宽和高
static CGRect swapWidthAndHeight(CGRect rect)
{
	CGFloat  swap = rect.size.width;
	
	rect.size.width  = rect.size.height;
	rect.size.height = swap;
	
	return rect;
}

@implementation UIImage (Helper)

//转换度值
static CGFloat degreesToRadiens(CGFloat degrees){
	return degrees * M_PI / 180.0f;
}

+ (UIImage*)imageWithContentsOfURL:(NSURL*)url {
	NSError* error;
	NSData* data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url] returningResponse:NULL error:&error];
	//NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imgPath]];
	if(error || !data) {
		return nil;
	} else {
		return [UIImage imageWithData:data];
	}
}

+ (UIImage*)imageWithResourceName:(NSString*)pathCompontent {
	return [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:pathCompontent]];
}

- (UIImage *)imageTintedWithColor:(UIColor *)inColor
{
	CGRect theFrame = CGRectMake(0, 0, self.size.width, self.size.height);
	UIGraphicsBeginImageContext(theFrame.size);
	CGContextRef theContext = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(theContext, [inColor CGColor]);
	CGContextFillRect(theContext, theFrame);
	[self drawInRect:theFrame blendMode:kCGBlendModeDestinationIn alpha:1.0];
	[self drawInRect:theFrame blendMode:kCGBlendModeMultiply alpha:1.0];
	UIImage *theTintedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return(theTintedImage);
}

- (UIImage*)scaleToSize:(CGSize)size {
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
		UIGraphicsBeginImageContextWithOptions(size, NO, [[UIScreen mainScreen] scale]);
	} else {
		UIGraphicsBeginImageContext(size);
	}
#else
	UIGraphicsBeginImageContext(size);
#endif
	
	[self drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
	UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return scaledImage;
}

- (UIImage*)aspectScaleToMaxSize:(CGFloat)size withBorderSize:(CGFloat)borderSize borderColor:(UIColor*)aColor cornerRadius:(CGFloat)aRadius shadowOffset:(CGSize)aOffset shadowBlurRadius:(CGFloat)aBlurRadius shadowColor:(UIColor*)aShadowColor{
	
	CGSize imageSize = CGSizeMake(self.size.width, self.size.height);
	
	CGFloat hScaleFactor = imageSize.width / size;
	CGFloat vScaleFactor = imageSize.height / size;
	
	CGFloat scaleFactor = MAX(hScaleFactor, vScaleFactor);
	
	CGFloat newWidth = imageSize.width   / scaleFactor;
	CGFloat newHeight = imageSize.height / scaleFactor;
	
	CGRect imageRect = CGRectMake(borderSize, borderSize, newWidth, newHeight);
	
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
		UIGraphicsBeginImageContextWithOptions(CGSizeMake(newWidth + (borderSize*2), newHeight + (borderSize*2)), NO, [[UIScreen mainScreen] scale]);
	} else {
		UIGraphicsBeginImageContext(CGSizeMake(newWidth + (borderSize*2), newHeight + (borderSize*2)));
	}
#else
	UIGraphicsBeginImageContext(CGSizeMake(newWidth + (borderSize*2), newHeight + (borderSize*2)));
#endif
	
	
	CGContextRef imageContext = UIGraphicsGetCurrentContext();
	CGContextSaveGState(imageContext);
	CGPathRef path = NULL;
	
	if (aRadius > 0.0f) {
		
		CGFloat radius;	
		radius = MIN(aRadius, floorf(imageRect.size.width/2));
		float x0 = CGRectGetMinX(imageRect), y0 = CGRectGetMinY(imageRect), x1 = CGRectGetMaxX(imageRect), y1 = CGRectGetMaxY(imageRect);
		
		CGContextBeginPath(imageContext);
		CGContextMoveToPoint(imageContext, x0+radius, y0);
		CGContextAddArcToPoint(imageContext, x1, y0, x1, y1, radius);
		CGContextAddArcToPoint(imageContext, x1, y1, x0, y1, radius);
		CGContextAddArcToPoint(imageContext, x0, y1, x0, y0, radius);
		CGContextAddArcToPoint(imageContext, x0, y0, x1, y0, radius);
		CGContextClosePath(imageContext);
		path = CGContextCopyPath(imageContext);
		CGContextClip(imageContext);
		
	} 
	
	[self drawInRect:imageRect];	
	CGContextRestoreGState(imageContext);
	
	if (borderSize > 0.0f) {
		
		CGContextSetLineWidth(imageContext, borderSize);
		[aColor != nil ? aColor : [UIColor blackColor] setStroke];
		
		if(path == NULL){
			
			CGContextStrokeRect(imageContext, imageRect);
			
		} else {
			
			CGContextAddPath(imageContext, path);
			CGContextStrokePath(imageContext);
			
		}
	}
	
	if(path != NULL){
		CGPathRelease(path);
	}
	
	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	if (aBlurRadius > 0.0f) {
		
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			UIGraphicsBeginImageContextWithOptions(CGSizeMake(scaledImage.size.width + (aBlurRadius*2), scaledImage.size.height + (aBlurRadius*2)), NO, [[UIScreen mainScreen] scale]);
		} else {
			UIGraphicsBeginImageContext(CGSizeMake(scaledImage.size.width + (aBlurRadius*2), scaledImage.size.height + (aBlurRadius*2)));
		}
#else
		UIGraphicsBeginImageContext(CGSizeMake(scaledImage.size.width + (aBlurRadius*2), scaledImage.size.height + (aBlurRadius*2)));
#endif
		
		CGContextRef imageShadowContext = UIGraphicsGetCurrentContext();
		
		if (aShadowColor!=nil) {
			CGContextSetShadowWithColor(imageShadowContext, aOffset, aBlurRadius, aShadowColor.CGColor);
		} else {
			CGContextSetShadow(imageShadowContext, aOffset, aBlurRadius);
		}
		
		[scaledImage drawInRect:CGRectMake(aBlurRadius, aBlurRadius, scaledImage.size.width, scaledImage.size.height)];
		scaledImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
	}
	
	return scaledImage;	
}

- (UIImage*)aspectScaleToMaxSize:(CGFloat)size withShadowOffset:(CGSize)aOffset blurRadius:(CGFloat)aRadius color:(UIColor*)aColor{
	return [self aspectScaleToMaxSize:size	withBorderSize:0 borderColor:nil cornerRadius:0 shadowOffset:aOffset shadowBlurRadius:aRadius shadowColor:aColor];
}

- (UIImage*)aspectScaleToMaxSize:(CGFloat)size withCornerRadius:(CGFloat)aRadius{
	
	return [self aspectScaleToMaxSize:size withBorderSize:0 borderColor:nil cornerRadius:aRadius shadowOffset:CGSizeZero shadowBlurRadius:0.0f shadowColor:nil];
}

- (UIImage*)aspectScaleToMaxSize:(CGFloat)size{
	
	return [self aspectScaleToMaxSize:size withBorderSize:0 borderColor:nil cornerRadius:0 shadowOffset:CGSizeZero shadowBlurRadius:0.0f shadowColor:nil];
}

- (UIImage*)aspectScaleToSize:(CGSize)size{
	
	CGSize imageSize = CGSizeMake(self.size.width, self.size.height);
	
	CGFloat hScaleFactor = imageSize.width / size.width;
	CGFloat vScaleFactor = imageSize.height / size.height;
	
	CGFloat scaleFactor = MAX(hScaleFactor, vScaleFactor);
	
	CGFloat newWidth = imageSize.width   / scaleFactor;
	CGFloat newHeight = imageSize.height / scaleFactor;
	
	// center vertically or horizontally in size passed
	CGFloat leftOffset = (size.width - newWidth) / 2;
	CGFloat topOffset = (size.height - newHeight) / 2;
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
	if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
		UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, size.height), NO, [[UIScreen mainScreen] scale]);
	} else {
		UIGraphicsBeginImageContext(CGSizeMake(size.width, size.height));
	}
#else
	UIGraphicsBeginImageContext(CGSizeMake(size.width, size.height));
#endif
	
	[self drawInRect:CGRectMake(leftOffset, topOffset, newWidth, newHeight)];
	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return scaledImage;	
}

+(UIImage *)rotateImage:(UIImage *)aImage withOrientation:(UIImageOrientation)imageOrientation
{
    CGImageRef imgRef = aImage.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    CGFloat scaleRatio = 1;
    
    CGFloat boundHeight;
    UIImageOrientation orient = imageOrientation;//aImage.imageOrientation;
    switch(orient)
    {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(width, height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(height, width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

-(UIImage*)rotate:(UIImageOrientation)orient scale:(CGSize)newSize
{
	CGRect             bnds = CGRectZero;
	UIImage*           copy = nil;
	CGContextRef       ctxt = nil;
	CGImageRef         imag = self.CGImage;
	CGRect             rect = CGRectZero;
	CGAffineTransform  tran = CGAffineTransformIdentity;
	
	//	rect.size.width  = CGImageGetWidth(imag);
	//	rect.size.height = CGImageGetHeight(imag);
	rect.size.width  = newSize.width;
	rect.size.height = newSize.height;
	
	bnds = rect;
	CGFloat scaleRatio = bnds.size.width / self.size.width;
	
	switch (orient)
	{
		case UIImageOrientationUp:
			tran = CGAffineTransformIdentity;
			break;
			
		case UIImageOrientationUpMirrored:
			tran = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
			tran = CGAffineTransformScale(tran, -1.0, 1.0);
			break;
			
		case UIImageOrientationDown:
			tran = CGAffineTransformMakeTranslation(rect.size.width,
													rect.size.height);
			tran = CGAffineTransformRotate(tran, M_PI);
			break;
			
		case UIImageOrientationDownMirrored:
			tran = CGAffineTransformMakeTranslation(0.0, rect.size.height);
			tran = CGAffineTransformScale(tran, 1.0, -1.0);
			break;
			
		case UIImageOrientationLeft:
			bnds = swapWidthAndHeight(bnds);
			tran = CGAffineTransformMakeTranslation(0.0, rect.size.width);
			tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationLeftMirrored:
			bnds = swapWidthAndHeight(bnds);
			tran = CGAffineTransformMakeTranslation(rect.size.height,
													rect.size.width);
			tran = CGAffineTransformScale(tran, -1.0, 1.0);
			tran = CGAffineTransformRotate(tran, 3.0 * M_PI / 2.0);
			break;
			
		case UIImageOrientationRight:
			bnds = swapWidthAndHeight(bnds);
			tran = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
			tran = CGAffineTransformRotate(tran, M_PI / 2.0);
			break;
			
		case UIImageOrientationRightMirrored:
			bnds = swapWidthAndHeight(bnds);
			tran = CGAffineTransformMakeScale(-1.0, 1.0);
			tran = CGAffineTransformRotate(tran, M_PI / 2.0);
			break;
			
		default:
			// orientation value supplied is invalid
			assert(false);
			return nil;
	}
	
	UIGraphicsBeginImageContext(bnds.size);
	ctxt = UIGraphicsGetCurrentContext();
	
	switch (orient)
	{
		case UIImageOrientationLeft:
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRight:
		case UIImageOrientationRightMirrored:
			//			CGContextScaleCTM(ctxt, -1.0, 1.0);
			CGContextScaleCTM(ctxt, -scaleRatio, scaleRatio);
			CGContextTranslateCTM(ctxt, -rect.size.height, 0.0);
			break;
			
		default:
			//			CGContextScaleCTM(ctxt, 1.0, -1.0);
			CGContextScaleCTM(ctxt, scaleRatio, -scaleRatio);
			CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
			break;
	}
	
	CGContextConcatCTM(ctxt, tran);
	CGContextDrawImage(UIGraphicsGetCurrentContext(), rect, imag);
	
	copy = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return copy;
}

- (CGSize)aspectScaleSize:(CGFloat)size{
	
	CGSize imageSize = CGSizeMake(self.size.width, self.size.height);
	
	CGFloat hScaleFactor = imageSize.width / size;
	CGFloat vScaleFactor = imageSize.height / size;
	
	CGFloat scaleFactor = MAX(hScaleFactor, vScaleFactor);
	
	CGFloat newWidth = imageSize.width   / scaleFactor;
	CGFloat newHeight = imageSize.height / scaleFactor;
	
	return CGSizeMake(newWidth, newHeight);
	
}

- (void)drawInRect:(CGRect)rect withAlphaMaskColor:(UIColor*)aColor{
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSaveGState(context);
	
	CGContextTranslateCTM(context, 0.0, rect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	rect.origin.y = rect.origin.y * -1;
	const CGFloat *color = CGColorGetComponents(aColor.CGColor);//Alpha
	CGContextClipToMask(context, rect, self.CGImage);
	CGContextSetRGBFillColor(context, color[0], color[1], color[2], color[3]);
	CGContextFillRect(context, rect);
	
	CGContextRestoreGState(context);
}

- (void)drawInRect:(CGRect)rect withAlphaMaskGradient:(NSArray*)colors{
	
	NSAssert([colors count]==2, @"an array containing two UIColor variables must be passed to drawInRect:withAlphaMaskGradient:");
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSaveGState(context);
	
	CGContextTranslateCTM(context, 0.0, rect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	rect.origin.y = rect.origin.y * -1;
	
	CGContextClipToMask(context, rect, self.CGImage);
	
	const CGFloat *top = CGColorGetComponents(((UIColor*)[colors objectAtIndex:0]).CGColor);
	const CGFloat *bottom = CGColorGetComponents(((UIColor*)[colors objectAtIndex:1]).CGColor);
	
	CGColorSpaceRef _rgb = CGColorSpaceCreateDeviceRGB();
	size_t _numLocations = 2;
	CGFloat _locations[2] = { 0.0, 1.0 };
	CGFloat _colors[8] = { top[0], top[1], top[2], top[3], bottom[0], bottom[1], bottom[2], bottom[3] };
	CGGradientRef gradient = CGGradientCreateWithColorComponents(_rgb, _colors, _locations, _numLocations);
	CGColorSpaceRelease(_rgb);
	
	CGPoint start = CGPointMake(CGRectGetMidX(rect), rect.origin.y);
	CGPoint end = CGPointMake(CGRectGetMidX(rect), rect.size.height);
	
	CGContextClipToRect(context, rect);
	CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
	
	CGGradientRelease(gradient);
	
	CGContextRestoreGState(context);
	
}
- (void)drawInRect:(CGRect)rect withAlphaMaskGradientTop:(UIColor*)colorTop Bottom:(UIColor*)colorBottom{
	
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSaveGState(context);
	
	CGContextTranslateCTM(context, 0.0, rect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	rect.origin.y = rect.origin.y * -1;
	
	CGContextClipToMask(context, rect, self.CGImage);
	
	const CGFloat *top = CGColorGetComponents(colorTop.CGColor);
	const CGFloat *bottom = CGColorGetComponents(colorBottom.CGColor);
	
	CGColorSpaceRef _rgb = CGColorSpaceCreateDeviceRGB();
	size_t _numLocations = 2;
	CGFloat _locations[2] = { 0.0, 1.0 };
	CGFloat _colors[8] = { top[0], top[1], top[2], top[3], bottom[0], bottom[1], bottom[2], bottom[3] };
	CGGradientRef gradient = CGGradientCreateWithColorComponents(_rgb, _colors, _locations, _numLocations);
	CGColorSpaceRelease(_rgb);
	
	CGPoint start = CGPointMake(CGRectGetMidX(rect), rect.origin.y);
	CGPoint end = CGPointMake(CGRectGetMidX(rect), rect.size.height);
	
	CGContextClipToRect(context, rect);
	CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
	
	CGGradientRelease(gradient);
	
	CGContextRestoreGState(context);
	
}

- (CGImageRef)mask
{
	CGImageRef theImage = self.CGImage;
	CGImageRef theMask = CGImageMaskCreate(CGImageGetWidth(theImage), CGImageGetHeight(theImage), CGImageGetBitsPerComponent(theImage), CGImageGetBitsPerPixel(theImage), CGImageGetBytesPerRow(theImage), CGImageGetDataProvider(theImage), NULL, YES);
	
	return(theMask);
}
@end

@implementation UIImage (Utility)

- (UIImage *)scaleToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (NSString *)base64String {
	NSData *pngData = UIImagePNGRepresentation(self);
	if (pngData) {
		return [pngData base64EncodedString];
	}
	NSData *jpegData = UIImageJPEGRepresentation(self, 1.0);
	if (jpegData) {
		return [jpegData base64EncodedString];
	}
	return nil;
}

#define MAX_IMAGEPIX 100.0

- (UIImage *)compressedImage:(CGSize)size {
    CGSize imageSize = self.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
	
	if (width <= size.width && height<= size.height) {
		// no need to compress.
		return self;
	}
	
	if (width == 0 || height == 0) {
		// void zero exception
		return self;
	}
	
    UIImage *newImage = nil;
	CGFloat widthFactor = size.width / width;
	CGFloat heightFactor = size.height / height;
	CGFloat scaleFactor = 0.0;
	if (widthFactor > heightFactor)
		scaleFactor = heightFactor; // scale to fit height
	else
		scaleFactor = widthFactor; // scale to fit width
    CGFloat scaledWidth  = ceilf(width * scaleFactor);
    CGFloat scaledHeight = ceilf(height * scaleFactor);
	
	CGSize targetSize = CGSizeMake(scaledWidth, scaledHeight);
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [self drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
	
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)compressedImage {
	return [self compressedImage:CGSizeMake(MAX_IMAGEPIX, MAX_IMAGEPIX)];
}

- (NSData *)compressedData:(CGFloat)compressionQuality {
	assert(compressionQuality<=1.0 && compressionQuality >=0);
	return UIImageJPEGRepresentation(self, compressionQuality);
}

- (CGFloat)compressionQuality {
	NSData *data = UIImageJPEGRepresentation(self, 1.0);
	NSUInteger dataLength = [data length];
	if(dataLength>10000.0) {//200K
		return 1.0-10000.0/dataLength;
	} else {
		return 1.0;
	}
}

- (NSData *)compressedData {
	CGFloat quality = [self compressionQuality];
	return [self compressedData:quality];
}

- (NSString *)contentType{
    NSData * data = UIImagePNGRepresentation(self);
    if (!data) {
        data = UIImageJPEGRepresentation(self, 1.0);
    }
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}

+ (UIImage *)createImageWithColor: (UIColor *) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+ (UIImage *)createImageWithColor: (UIColor *) color withSize:(CGSize)size{
    CGRect rect=CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}


//裁剪部分为新图
- (UIImage *)cropToRect:(CGRect)rect{
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return cropped;
}

//生成指定大小的字图
+ (UIImage*)imageWithString:(NSString *)word ToSize:(CGSize)size{
    CGFloat scale = [[UIScreen mainScreen] scale];
    CGRect frame = CGRectMake(0, 0, size.width*scale, size.height*scale);
    
    UIView* view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor=MKRGBA(246,246,248,255);
    
//    UIImageView *bgImg = [[UIImageView alloc] initWithFrame:frame];
//    bgImg.image = [UIImage imageNamed:@"avatar_feed"];//设置图片的背景图片
//    [view addSubview:bgImg];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height-2)];//设置图片上面的文字显示
    lab.textAlignment = NSTextAlignmentCenter;//水平居中
    //默认垂直居中
    lab.textColor = MKRGBA(66,66,66,255);
    lab.backgroundColor = [UIColor clearColor];
    lab.font = [UIFont fontWithName:@"Helvetica Neue" size:28*scale];
    //lab.font = [UIFont boldSystemFontOfSize:26];
    lab.text = [word uppercaseString];
    [view addSubview:lab];
    
    UIGraphicsBeginImageContext(frame.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *aImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *imageData = UIImagePNGRepresentation(aImage);
    UIImage *img = [UIImage imageWithData:imageData];//生成的图片
    
	return img;
}

+ (UIImage*)imageFromColors:(NSArray*)colors ByGradientType:(GradientType)gradientType ToSize:(CGSize)size{
    NSMutableArray *ar = [NSMutableArray array];
    for(UIColor *c in colors) {
        [ar addObject:(id)c.CGColor];
    }
    UIGraphicsBeginImageContextWithOptions(size, NO, 1);//NO:透明
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)ar, NULL);
    CGPoint start;
    CGPoint end;
    switch (gradientType) {
        case 0:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(0.0, size.height);
            break;
        case 1:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(size.width, 0.0);
            break;
        case 2:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(size.width, size.height);
            break;
        case 3:
            start = CGPointMake(size.width, 0.0);
            end = CGPointMake(0.0, size.height);
            break;
        default:
            break;
    }
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)getErWeiMaImageFormCIImage:(CIImage *)image withSize:(CGFloat)size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}
- (UIImage*)imageBlackToWithRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue{
    const int imageWidth = self.size.width;
    const int imageHeight = self.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), self.CGImage);
    // 遍历像素
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900)    // 将白色变成透明
        {
            // 改成下面的代码，会将图片转成想要的颜色
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }
        else
        {
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // 输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // 清理空间
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}

@end

@implementation UIImage (ColorImage)

+ (UIImage *)blueColorImage {
    return [UIImage imageNamed:@"blue.png"];
}

+ (UIImage *)blueHighlightColorImage {
    return [UIImage imageNamed:@"blue_hl.png"];
}

+ (UIImage *)greenColorImage {
    return [UIImage imageNamed:@"green.png"];
}

+ (UIImage *)greenHighlightColorImage {
    return [UIImage imageNamed:@"green_hl.png"];
}

+ (UIImage *)grayColorImage {
    NSString *versions = [[UIDevice currentDevice] systemVersion];
    if ([versions compare:@"5.0"] != NSOrderedAscending ) { // 5.0以上
        return [[UIImage imageNamed:@"gray.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
    } else { // 4.3
        return [[UIImage imageNamed:@"gray.png"] stretchableImageWithLeftCapWidth:2 topCapHeight:2];
    }
}

+ (UIImage *)grayHighlightColorImage {
    NSString *versions = [[UIDevice currentDevice] systemVersion];
    if ([versions compare:@"5.0"] != NSOrderedAscending ) { // 5.0以上
        return [[UIImage imageNamed:@"gray_hl.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
    } else { // 4.3
        return [[UIImage imageNamed:@"gray_hl.png"] stretchableImageWithLeftCapWidth:2 topCapHeight:2];
    }
}

+ (UIImage *)roundedGrayColorImage {
    NSString *versions = [[UIDevice currentDevice] systemVersion];
    if ([versions compare:@"5.0"] != NSOrderedAscending ) { // 5.0以上
        return [[UIImage imageNamed:@"rounded_gray.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
    } else { // 4.3
        return [[UIImage imageNamed:@"rounded_gray.png"] stretchableImageWithLeftCapWidth:2 topCapHeight:2];
    }
}

+ (UIImage *)roundedGrayHighlightColorImage {
    NSString *versions = [[UIDevice currentDevice] systemVersion];
    if ([versions compare:@"5.0"] != NSOrderedAscending ) { // 5.0以上
        return [[UIImage imageNamed:@"rounded_gray_hl.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
    } else { // 4.3
        return [[UIImage imageNamed:@"rounded_gray_hl.png"] stretchableImageWithLeftCapWidth:2 topCapHeight:2];
    }
}

+ (UIImage *)transparentBlueColorImage {
    NSString *versions = [[UIDevice currentDevice] systemVersion];
    if ([versions compare:@"5.0"] != NSOrderedAscending ) { // 5.0以上
        return [[UIImage imageNamed:@"transparent_blue.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
    } else { // 4.3
        return [[UIImage imageNamed:@"transparent_blue.png"] stretchableImageWithLeftCapWidth:2 topCapHeight:2];
    }
}

+ (UIImage *)transparentBlueHighlightColorImage {
    NSString *versions = [[UIDevice currentDevice] systemVersion];
    if ([versions compare:@"5.0"] != NSOrderedAscending ) { // 5.0以上
        return [[UIImage imageNamed:@"transparent_blue_hl.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
    } else { // 4.3
        return [[UIImage imageNamed:@"transparent_blue_hl.png"] stretchableImageWithLeftCapWidth:2 topCapHeight:2];
    }
}

@end

@implementation UIImage (Capture)

// get the current UITableView screen shot
+(UIImage *)captureImageFromView:(UITableView *)tableview{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(tableview.contentSize.width, tableview.contentSize.height), NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect previousFrame = tableview.frame;
    tableview.frame = CGRectMake(tableview.frame.origin.x, tableview.frame.origin.y, tableview.contentSize.width, tableview.contentSize.height);
    [tableview.layer renderInContext:context];
    tableview.frame = previousFrame;
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

// get the current screen shot
+(UIImage *)captureScreen{
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    
    UIGraphicsBeginImageContextWithOptions([keyWindow bounds].size,NO,0);
    [keyWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end

#endif /* TARGET_OS_IPHONE */
