//
//  FSMediaPicker.m
//  Pods
//
//  Created by LiXiangCheng on 2/3/15.
//  sbtjfdn@hotmail.com
//

#import "FSMediaPicker.h"
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <objc/runtime.h>

#define kIsIPad [[[UIDevice currentDevice] model] hasPrefix:@"iPad"]

NSString const * UIImagePickerControllerCircularEditedImage = @" UIImagePickerControllerCircularEditedImage;";
NSString const * UIImagePickerControllerRectangleEditedImage = @" UIImagePickerControllerRectangleEditedImage;";

@interface FSMediaPicker ()<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (UIWindow *)currentVisibleWindow;
- (UIViewController *)currentVisibleController;

- (void)delegatePerformFinishWithMediaInfo:(NSDictionary *)mediaInfo;
- (void)delegatePerformWillPresentImagePicker:(UIImagePickerController *)imagePicker;
- (void)delegatePerformCancel;

- (void)showAlertController:(UIView *)view;
- (void)showActionSheet:(UIView *)view;

- (void)takePhotoFromCamera;
- (void)takePhotoFromPhotoLibrary;
- (void)takeVideoFromCamera;
- (void)takeVideoFromPhotoLibrary;

@end

@implementation FSMediaPicker

#pragma mark - Life Cycle

- (instancetype)initWithDelegate:(id<FSMediaPickerDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
    }
    return self;
}

#pragma mark - Public

- (void)show
{
    [self showFromView:self.currentVisibleController.view];
}

- (void)showFromView:(UIView *)view
{
    if ([UIAlertController class]) {
        [self showAlertController:view];
    } else {
        [self showActionSheet:view];
    }
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    switch (buttonIndex) {
        case 0:
        {
            if (self.mediaType == FSMediaTypePhoto || self.mediaType == FSMediaTypeAll) {
                [self takePhotoFromCamera];
            } else if (self.mediaType == FSMediaTypeVideo) {
                [self takeVideoFromCamera];
            }
            break;
        }
        case 1:
        {
            if (self.mediaType == FSMediaTypePhoto || self.mediaType == FSMediaTypeAll) {
                [self takePhotoFromPhotoLibrary];
            } else if (self.mediaType == FSMediaTypeVideo) {
                [self takeVideoFromPhotoLibrary];
            }
            break;
        }
        case 2:
        {
            if (self.mediaType == FSMediaTypeAll) {
                [self takeVideoFromCamera];
            }
            break;
        }
        case 3:
        {
            if (self.mediaType == FSMediaTypeAll) {
                [self takeVideoFromPhotoLibrary];
            }
            break;
        }
        default:
            break;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        [self delegatePerformCancel];
    }
}

#pragma mark - UIImagePickerController Delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [self delegatePerformFinishWithMediaInfo:info];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [self delegatePerformCancel];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController isKindOfClass:NSClassFromString(@"PLUIImageViewController")] && self.editMode && [navigationController.viewControllers count] == 3) {
        UIView *plCropOverlay = [[viewController.view.subviews objectAtIndex:1] subviews][0];
        plCropOverlay.hidden = YES;
        
        CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
        switch (self.editMode) {
            case FSEditModeCircular://圆形
            {
                CAShapeLayer *circleLayer = [CAShapeLayer layer];
                //直径
                CGFloat diameter = kIsIPad ? MAX(plCropOverlay.frame.size.width, plCropOverlay.frame.size.height) : MIN(plCropOverlay.frame.size.width, plCropOverlay.frame.size.height);
                int position = (screenHeight-diameter)/2;
                
                UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0.0f, position, diameter, diameter)];//圆形
                [circlePath setUsesEvenOddFillRule:YES];
                [circleLayer setPath:[circlePath CGPath]];
                [circleLayer setFillColor:[[UIColor clearColor] CGColor]];
                
                
                CGFloat bottomBarHeight = kIsIPad ? 51 : 72;
                UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, diameter, screenHeight - bottomBarHeight) cornerRadius:0];
                [path appendPath:circlePath];
                [path setUsesEvenOddFillRule:YES];
                
                CAShapeLayer *fillLayer = [CAShapeLayer layer];
                fillLayer.name = @"fillLayer";
                fillLayer.path = path.CGPath;
                fillLayer.fillRule = kCAFillRuleEvenOdd;
                fillLayer.fillColor = [UIColor blackColor].CGColor;
                fillLayer.opacity = 0.5;
                [viewController.view.layer addSublayer:fillLayer];
            }
                break;
            case FSEditModeRectangle://长方形
            {
                CAShapeLayer *rectLayer = [CAShapeLayer layer];
                //长方形宽高
                CGFloat rectWidth = kIsIPad ? MAX(plCropOverlay.frame.size.width, plCropOverlay.frame.size.height) : MIN(plCropOverlay.frame.size.width, plCropOverlay.frame.size.height);
                CGFloat rectHeight=rectWidth*RectangleRatio;
                int position = (screenHeight-rectHeight)/2;
                
                UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:CGRectMake(0.0f, position, rectWidth, rectHeight)];//长方形
                [rectPath setUsesEvenOddFillRule:YES];
                [rectLayer setPath:[rectPath CGPath]];
                [rectLayer setFillColor:[[UIColor clearColor] CGColor]];
                
                CGFloat bottomBarHeight = kIsIPad ? 51 : 72;
                
                UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, rectWidth, screenHeight - bottomBarHeight) cornerRadius:0];
                [path appendPath:rectPath];
                [path setUsesEvenOddFillRule:YES];
                
                CAShapeLayer *fillLayer = [CAShapeLayer layer];
                fillLayer.name = @"fillLayer";
                fillLayer.path = path.CGPath;
                fillLayer.fillRule = kCAFillRuleEvenOdd;
                fillLayer.fillColor = [UIColor blackColor].CGColor;
                fillLayer.opacity = 0.5;
                [viewController.view.layer addSublayer:fillLayer];
            }
                break;
            default:
                break;
        }
        
        if (!kIsIPad) {
            UILabel *moveLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 320, 50)];
            [moveLabel setText:@"Move and Scale"];
            [moveLabel setTextAlignment:NSTextAlignmentCenter];
            [moveLabel setTextColor:[UIColor whiteColor]];
            [viewController.view addSubview:moveLabel];
        }
        
    }
}

#pragma mark - Setter & Getter

- (UIWindow *)currentVisibleWindow
{
    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows){
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible = !window.hidden && window.alpha > 0;
        BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;
        if (windowOnMainScreen && windowIsVisible && windowLevelNormal) {
            return window;
        }
    }
    return [[[UIApplication sharedApplication] delegate] window];
}

- (UIViewController *)currentVisibleController
{
    UIViewController *topController = self.currentVisibleWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}

#pragma mark - Private

- (void)delegatePerformFinishWithMediaInfo:(NSDictionary *)mediaInfo
{
    if ([[mediaInfo allKeys] containsObject:UIImagePickerControllerEditedImage]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:mediaInfo];
        
        switch (self.editMode) {
            case FSEditModeCircular://圆形
                dic[UIImagePickerControllerCircularEditedImage] = [dic[UIImagePickerControllerEditedImage] circularImage];
                break;
            case FSEditModeRectangle://长方形
                dic[UIImagePickerControllerRectangleEditedImage] = [dic[UIImagePickerControllerEditedImage] rectangleImage];
                break;
            default:
                break;
        }
        mediaInfo = [NSDictionary dictionaryWithDictionary:dic];
    }
    if (_finishBlock) {
        _finishBlock(self,mediaInfo);
    } else if (_delegate && [_delegate respondsToSelector:@selector(mediaPicker:didFinishWithMediaInfo:)]) {
        [_delegate mediaPicker:self didFinishWithMediaInfo:mediaInfo];
    }
}

- (void)delegatePerformWillPresentImagePicker:(UIImagePickerController *)imagePicker
{
    if (_willPresentImagePickerBlock) {
        _willPresentImagePickerBlock(self,imagePicker);
    } else if (_delegate && [_delegate respondsToSelector:@selector(mediaPicker:willPresentImagePickerController:)]) {
        [_delegate mediaPicker:self willPresentImagePickerController:imagePicker];
    }
}

- (void)delegatePerformCancel
{
    if (_cancelBlock) {
        _cancelBlock(self);
    } else if (_delegate && [_delegate respondsToSelector:@selector(mediaPickerDidCancel:)]) {
        [_delegate mediaPickerDidCancel:self];
    }
}

- (void)showActionSheet:(UIView *)view
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.mediaPicker = self;
    switch (self.mediaType) {
        case FSMediaTypePhoto:
        {
            [actionSheet addButtonWithTitle:@"Take photo"];
            [actionSheet addButtonWithTitle:@"Select photo from photo library"];
            [actionSheet addButtonWithTitle:@"Cancel"];
            actionSheet.cancelButtonIndex = 2;
            break;
        }
        case FSMediaTypeVideo:
        {
            [actionSheet addButtonWithTitle:@"Record video"];
            [actionSheet addButtonWithTitle:@"Select video from photo library"];
            [actionSheet addButtonWithTitle:@"Cancel"];
            actionSheet.cancelButtonIndex = 2;
            break;
        }
        case FSMediaTypeAll:
        {
            [actionSheet addButtonWithTitle:@"Take photo"];
            [actionSheet addButtonWithTitle:@"Select photo from photo library"];
            [actionSheet addButtonWithTitle:@"Record video"];
            [actionSheet addButtonWithTitle:@"Select video from photo library"];
            [actionSheet addButtonWithTitle:@"Cancel"];
            actionSheet.cancelButtonIndex = 4;
            break;
        }
        default:
            break;
    }
    actionSheet.delegate = self;
    [actionSheet showFromRect:view.bounds inView:view animated:YES];
}

- (void)showAlertController:(UIView *)view
{
    UIAlertController *alertController = [[UIAlertController alloc] init];
    alertController.mediaPicker = self;
    switch (self.mediaType) {
        case FSMediaTypePhoto:
        {
            [alertController addAction:[UIAlertAction actionWithTitle:@"Take photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self takePhotoFromCamera];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Select photo from photo library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self takePhotoFromPhotoLibrary];
            }]];
            break;
        }
        case FSMediaTypeVideo:
        {
            [alertController addAction:[UIAlertAction actionWithTitle:@"Record video" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self takeVideoFromCamera];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Select video from photo library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self takeVideoFromPhotoLibrary];
            }]];
            break;
        }
        case FSMediaTypeAll:
        {
            [alertController addAction:[UIAlertAction actionWithTitle:@"Take photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self takePhotoFromCamera];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Select photo from photo library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self takePhotoFromPhotoLibrary];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Record video" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self takeVideoFromCamera];
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Select video from photo library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self takeVideoFromPhotoLibrary];
            }]];
            break;
        }
        default:
            break;
    }
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        [self delegatePerformCancel];
    }]];
    alertController.popoverPresentationController.sourceView = view;
    alertController.popoverPresentationController.sourceRect = view.bounds;
    [self.currentVisibleController presentViewController:alertController animated:YES completion:nil];
}

- (void)takePhotoFromCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePicker = [UIImagePickerController new];
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        imagePicker.mediaPicker = self;
        [self delegatePerformWillPresentImagePicker:imagePicker];
        [self.currentVisibleController presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)takePhotoFromPhotoLibrary
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imagePicker = [UIImagePickerController new];
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        imagePicker.mediaPicker = self;
        [self delegatePerformWillPresentImagePicker:imagePicker];
        [self.currentVisibleController presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)takeVideoFromCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePicker = [UIImagePickerController new];
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
        imagePicker.mediaPicker = self;
        [self delegatePerformWillPresentImagePicker:imagePicker];
        [self.currentVisibleController presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)takeVideoFromPhotoLibrary
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imagePicker = [UIImagePickerController new];
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
        imagePicker.mediaPicker = self;
        [self delegatePerformWillPresentImagePicker:imagePicker];
        [self.currentVisibleController presentViewController:imagePicker animated:YES completion:nil];
    }
}

@end

@implementation NSDictionary (FSMediaPicker)

- (UIImage *)originalImage
{
    if ([self.allKeys containsObject:UIImagePickerControllerOriginalImage]) {
        return self[UIImagePickerControllerOriginalImage];
    }
    return nil;
}

- (UIImage *)editedImage
{
    if ([self.allKeys containsObject:UIImagePickerControllerEditedImage]) {
        return self[UIImagePickerControllerEditedImage];
    }
    return nil;
}

- (NSURL *)mediaURL
{
    if ([self.allKeys containsObject:UIImagePickerControllerMediaURL]) {
        return self[UIImagePickerControllerMediaURL];
    }
    return nil;
}

- (NSDictionary *)mediaMetadata
{
    if ([self.allKeys containsObject:UIImagePickerControllerMediaMetadata]) {
        return self[UIImagePickerControllerMediaMetadata];
    }
    return nil;
}

- (FSMediaType)mediaType
{
    if ([self.allKeys containsObject:UIImagePickerControllerMediaType]) {
        NSString *type = self[UIImagePickerControllerMediaType];
        if ([type isEqualToString:(NSString *)kUTTypeImage]) {
            return FSMediaTypePhoto;
        } else if ([type isEqualToString:(NSString *)kUTTypeMovie]) {
            return FSMediaTypeVideo;
        }
    }
    return FSMediaTypePhoto;
}

- (UIImage *)circularEditedImage
{
    if ([self.allKeys containsObject:UIImagePickerControllerCircularEditedImage]) {
        return self[UIImagePickerControllerCircularEditedImage];
    }
    return nil;
}

- (UIImage *)rectangleEditedImage
{
    if ([self.allKeys containsObject:UIImagePickerControllerRectangleEditedImage]) {
        return self[UIImagePickerControllerRectangleEditedImage];
    }
    return nil;
}

@end


@implementation UIImage (FSMediaPicker)
- (UIImage *)circularImage{
    // This function returns a newImage, based on image, that has been:
    // - scaled to fit in (CGRect) rect
    // - and cropped within a circle of radius: rectWidth/2
    
    //Create the bitmap graphics context
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(self.size.width, self.size.height), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //Get the width and heights
    CGFloat imageWidth = self.size.width;
    CGFloat imageHeight = self.size.height;
    CGFloat rectWidth = self.size.width;
    CGFloat rectHeight = self.size.height;
    
    //Calculate the scale factor
    CGFloat scaleFactorX = rectWidth/imageWidth;
    CGFloat scaleFactorY = rectHeight/imageHeight;
    
    //Calculate the centre of the circle
    CGFloat imageCentreX = rectWidth/2;
    CGFloat imageCentreY = rectHeight/2;
    
    // Create and CLIP to a CIRCULAR Path
    // (This could be replaced with any closed path if you want a different shaped clip)
    CGFloat radius = rectWidth/2;
    CGContextBeginPath (context);
    CGContextAddArc (context, imageCentreX, imageCentreY, radius, 0, 2*M_PI, 0);
    CGContextClosePath (context);
    CGContextClip (context);
    
    //Set the SCALE factor for the graphics context
    //All future draw calls will be scaled by this factor
    CGContextScaleCTM (context, scaleFactorX, scaleFactorY);
    
    // Draw the IMAGE
    CGRect myRect = CGRectMake(0, 0, imageWidth, imageHeight);
    [self drawInRect:myRect];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
- (UIImage *)rectangleImage{
    // This function returns a newImage, based on image, that has been:
    // - scaled to fit in (CGRect) rect
    // - and cropped within a rectangle of ratio//长方形高宽比
    
    //Get the width and heights
    //CGFloat imageWidth = self.size.width;
    CGFloat imageHeight = self.size.height;
    CGFloat rectWidth = self.size.width;
    CGFloat rectHeight = rectWidth*RectangleRatio;
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], CGRectMake(0, (imageHeight-rectHeight)/2, rectWidth, rectHeight));
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return cropped;
}
@end

const char * mediaPickerKey;

@implementation UIActionSheet (FSMediaPicker)

- (void)setMediaPicker:(FSMediaPicker *)mediaPicker
{
    objc_setAssociatedObject(self, &mediaPickerKey, mediaPicker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FSMediaPicker *)mediaPicker
{
    return objc_getAssociatedObject(self, &mediaPickerKey);
}

@end

@implementation UIAlertController (FSMediaPicker)

- (void)setMediaPicker:(FSMediaPicker *)mediaPicker
{
    objc_setAssociatedObject(self, &mediaPickerKey, mediaPicker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FSMediaPicker *)mediaPicker
{
    return objc_getAssociatedObject(self, &mediaPickerKey);
}

@end

@implementation UIImagePickerController (FSMediaPicker)

- (void)setMediaPicker:(FSMediaPicker *)mediaPicker
{
    objc_setAssociatedObject(self, &mediaPickerKey, mediaPicker, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (FSMediaPicker *)mediaPicker
{
    return objc_getAssociatedObject(self, &mediaPickerKey);
}

@end

