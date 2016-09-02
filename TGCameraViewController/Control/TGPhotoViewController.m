//
//  TGPhotoViewController.m
//  TGCameraViewController
//
//  Created by Bruno Tortato Furtado on 15/09/14.
//  Copyright (c) 2014 Tudo Gostoso Internet. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

@import AssetsLibrary;
#import "TGPhotoViewController.h"
#import "TGAssetsLibrary.h"
#import "TGCameraColor.h"
#import "TGCameraFilterView.h"
#import "UIImage+CameraFilters.h"

#import "ColorPickerView.h"


static NSString* const kTGCacheSatureKey = @"TGCacheSatureKey";
static NSString* const kTGCacheCurveKey = @"TGCacheCurveKey";
static NSString* const kTGCacheVignetteKey = @"TGCacheVignetteKey";



@interface TGPhotoViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *photoView;
@property (strong, nonatomic) IBOutlet UIView *bottomView;
@property (strong, nonatomic) IBOutlet TGCameraFilterView *filterView;
@property (strong, nonatomic) IBOutlet UIButton *defaultFilterButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeight;

@property (weak) id<TGCameraDelegate> delegate;
@property (strong, nonatomic) UIView *detailFilterView;
@property (strong, nonatomic) UIImage *photo;
@property (strong, nonatomic) NSCache *cachePhoto;
@property (nonatomic) BOOL albumPhoto;

@property (nonatomic, retain) IBOutlet UITextField *m_pCaptionText;
@property (nonatomic, retain) IBOutlet UILabel *m_pCationLabel;
@property (nonatomic, retain) IBOutlet UIImageView *m_pImagePicker;

@property (nonatomic, retain) IBOutlet UIImageView *m_pImage1;
@property (nonatomic, retain) IBOutlet UIButton *m_pEditCaption;
@property (nonatomic, retain) IBOutlet UIButton *m_pEditColor;
@property (nonatomic, retain) IBOutlet UIButton *m_pBackword;

@property (nonatomic, retain) IBOutlet UIImageView *m_pSharingView;
@property (nonatomic, retain) IBOutlet UIButton *m_pSharingClose;


- (IBAction)backTapped;
- (IBAction)confirmTapped;
- (IBAction)filtersTapped;

- (IBAction)defaultFilterTapped:(UIButton *)button;
- (IBAction)satureFilterTapped:(UIButton *)button;
- (IBAction)curveFilterTapped:(UIButton *)button;
- (IBAction)vignetteFilterTapped:(UIButton *)button;

- (void)addDetailViewToButton:(UIButton *)button;
+ (instancetype)newController;

- (IBAction) onEditCaptionText:(UIButton *)button;
- (IBAction) onSelectColor:(UIButton *)button;
- (IBAction) onShareImage:(UIButton *)button;
- (IBAction) onBackword:(UIButton *)button;

- (IBAction) onSaveCameraRoll:(UIButton *)button;
- (IBAction) onShareFacebook:(UIButton *)button;
- (IBAction) onShareTwitter:(UIButton *)button;
- (IBAction) onShareEmail:(UIButton *)button;
- (IBAction) onShareText:(UIButton *)button;
- (IBAction) onShareClose:(UIButton *)button;

@end



@implementation TGPhotoViewController

+ (instancetype)newWithDelegate:(id<TGCameraDelegate>)delegate photo:(UIImage *)photo
{
    TGPhotoViewController *viewController = [TGPhotoViewController newController];
    
    if (viewController) {
        viewController.delegate = delegate;
        viewController.photo = photo;
        viewController.cachePhoto = [[NSCache alloc] init];
    }
    
    return viewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (CGRectGetHeight([[UIScreen mainScreen] bounds]) <= 480) {
        _topViewHeight.constant = 0;
    }
    
    _photoView.clipsToBounds = YES;
    _photoView.image = _photo;
    
    [self addDetailViewToButton:_defaultFilterButton];
    
    _m_pCaptionText.delegate = self;
    
    [_m_pImagePicker setHidden: YES];
    [_m_pBackword setHidden: YES];
    
    [_m_pCaptionText setHidden: YES];
    [_m_pCationLabel setHidden: NO];
    [_m_pEditCaption setHidden: NO];
    
    isCaptionTextEditing = NO;
    isColorSelecting = NO;
    
    redColor = 0.0f; greenColor = 0.0f; blueColor = 0.0f;
    
    tempImageCount = 0;
    
//    UIGraphicsBeginImageContext(_photoView.frame.size);
//    [_photoView.image drawInRect:CGRectMake(0, 0, _photoView.frame.size.width, _photoView.frame.size.height)];
//    _photoView.image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();

    tempImage[0] = [[UIImage alloc] init];
    tempImage[0] = _photoView.image;

    [_m_pSharingView setHidden: YES];
}

//Touch parts :

// Scales down the view and moves it to the new position.
- (void)animateView:(UIImageView *)theView toPosition:(CGPoint) thePosition
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.4];
	// Set the center to the final postion
	theView.center = thePosition;
	// Set the transform back to the identity, thus undoing the previous scaling effect.
	theView.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];
}

-(void) dispatchTouchEvent:(CGPoint)position
{
	if (CGRectContainsPoint([_m_pImagePicker frame], position))
	{
//		[self animateView:crossHairs toPosition: position];
		[self updateHueSatWithMovement:position];
	}
}

- (void) updateHueSatWithMovement : (CGPoint) position
{
	[_m_pImage1 setBackgroundColor: [self getRGBPixelColorAtPoint: position]];
}

- (UIColor*)getRGBPixelColorAtPoint:(CGPoint)point
{
    UIColor* color = nil;
    
    CGImageRef cgImage = [_m_pImagePicker.image CGImage];
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);
    
    int y1 = point.y - _m_pImagePicker.frame.origin.y;
    
    NSUInteger x = 20;
    NSUInteger y = y1 * (height / _m_pImagePicker.frame.size.height);
    
    if ((x < width) && (y < height)) {
    	CGDataProviderRef provider = CGImageGetDataProvider(cgImage);
    	CFDataRef bitmapData = CGDataProviderCopyData(provider);
    	const UInt8* data = CFDataGetBytePtr(bitmapData);
    	size_t offset = ((width * y) + x) * 4;
//    	UInt8 red = data[offset];
//    	UInt8 blue = data[offset+1];
//    	UInt8 green = data[offset+2];
        UInt8 red = data[offset];
    	UInt8 green = data[offset+1];
    	UInt8 blue = data[offset+2];

    	UInt8 alpha = data[offset+3];
    	CFRelease(bitmapData);
    	color = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha/255.0f];
        
        redColor = (float) red / 255.f;
        greenColor = (float) green / 255.f;
        blueColor = (float) blue / 255.f;

    }
    return color;
}

// Handles the start of a touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (UITouch *touch in touches) {
        CGPoint position= [touch locationInView:touch.view];
        
        if (CGRectContainsPoint([_m_pImagePicker frame], position))
        {
            [self updateHueSatWithMovement:position];
        }
        
        if (isColorSelecting) {
            mouseSwiped = NO;
            lastPoint = [touch locationInView: _photoView];
        }
    }
}

// Handles the continuation of a touch.
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    BOOL isDrawing;
	for (UITouch *touch in touches){
        isDrawing = YES;
        CGPoint position= [touch locationInView:touch.view];
        
        if (CGRectContainsPoint([_m_pImagePicker frame], position))
        {
            isDrawing = NO;
            //		[self animateView:crossHairs toPosition: position];
            [self updateHueSatWithMovement:position];
        }
        
        if (CGRectContainsPoint([_m_pCationLabel frame], position)) {
            if (isColorSelecting || isCaptionTextEditing) {
            } else {
                [_m_pCationLabel setFrame: CGRectMake(position.x - [_m_pCationLabel frame].size.width / 2, position.y - [_m_pCationLabel frame].size.height / 2, [_m_pCationLabel frame].size.width, [_m_pCationLabel frame].size.height)];
            }
        }
        
        if (isColorSelecting && isDrawing && ([_m_pSharingView isHidden]))
        {
            mouseSwiped = YES;
            CGPoint currentPoint = [touch locationInView: _photoView];
            
            UIGraphicsBeginImageContext(_photoView.frame.size);
            [_photoView.image drawInRect:CGRectMake(0, 0, _photoView.frame.size.width, _photoView.frame.size.height)];
            CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
            CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
            CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
            CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 10.0 );
            CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), redColor, greenColor, blueColor, 1.0);
            CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
            
            CGContextStrokePath(UIGraphicsGetCurrentContext());
            _photoView.image = UIGraphicsGetImageFromCurrentImageContext();
            [_photoView setAlpha:1.0];
            
            UIGraphicsEndImageContext();
            
            lastPoint = currentPoint;
        }
	}
	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    BOOL isDrawing;
    isDrawing = YES;
    for (UITouch *touch in touches){
        CGPoint position= [touch locationInView:touch.view];
        
        if (CGRectContainsPoint([_m_pImagePicker frame], position))
        {
            isDrawing = NO;
        }
    }
    
    if (isColorSelecting && isDrawing)
    {
        if (tempImageCount < 0) {
            tempImageCount = 0;
        }
        
        if (tempImageCount > 99) {
            tempImageCount = 99;
        }
        
        tempImageCount++;
        tempImage[tempImageCount] = [[UIImage alloc] init];
        tempImage[tempImageCount] = _photoView.image;
    }

}

- (UIColor*)colorFromImage:(UIImage*)image sampledAtPoint:(CGPoint)p {
    CGImageRef cgImage = [image CGImage];
    CGDataProviderRef provider = CGImageGetDataProvider(cgImage);
    CFDataRef bitmapData = CGDataProviderCopyData(provider);
    const UInt8* data = CFDataGetBytePtr(bitmapData);
    size_t bytesPerRow = CGImageGetBytesPerRow(cgImage);
    size_t width = CGImageGetWidth(cgImage);
    size_t height = CGImageGetHeight(cgImage);
    int col = p.x*(width-1);
    int row = p.y*(height-1);
    const UInt8* pixel = data + row*bytesPerRow+col*4;
    UIColor* returnColor = [UIColor colorWithRed:pixel[0]/255. green:pixel[1]/255. blue:pixel[2]/255. alpha:1.0];
    CFRelease(bitmapData);
    return returnColor;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)dealloc
{
    _photoView = nil;
    _bottomView = nil;
    _filterView = nil;
    _defaultFilterButton = nil;
    _detailFilterView = nil;
    _photo = nil;
    _cachePhoto = nil;
}

#pragma mark -
#pragma mark - Controller actions

- (IBAction)backTapped
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confirmTapped
{
    if ( [_delegate respondsToSelector:@selector(cameraWillTakePhoto)]) {
        [_delegate cameraWillTakePhoto];
    }
    
    if ([_delegate respondsToSelector:@selector(cameraDidTakePhoto:)]) {
        _photo = _photoView.image;
        
        if (_albumPhoto) {
            [_delegate cameraDidSelectAlbumPhoto:_photo];
        } else {
            [_delegate cameraDidTakePhoto:_photo];
        }
        
        ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
        TGAssetsLibrary *library = [TGAssetsLibrary defaultAssetsLibrary];
        
        void (^saveJPGImageAtDocumentDirectory)(UIImage *) = ^(UIImage *photo) {
            [library saveJPGImageAtDocumentDirectory:_photo resultBlock:^(NSURL *assetURL) {
                [_delegate cameraDidSavePhotoAtPath:assetURL];
            } failureBlock:^(NSError *error) {
                if ([_delegate respondsToSelector:@selector(cameraDidSavePhotoWithError:)]) {
                    [_delegate cameraDidSavePhotoWithError:error];
                }
            }];
        };
        
        if ([[TGCamera getOption:kTGCameraOptionSaveImageToAlbum] boolValue] && status != ALAuthorizationStatusDenied) {
            [library saveImage:_photo resultBlock:^(NSURL *assetURL) {
                if ([_delegate respondsToSelector:@selector(cameraDidSavePhotoAtPath:)]) {
                    [_delegate cameraDidSavePhotoAtPath:assetURL];
                }
            } failureBlock:^(NSError *error) {
                saveJPGImageAtDocumentDirectory(_photo);
            }];
        } else {
            if ([_delegate respondsToSelector:@selector(cameraDidSavePhotoAtPath:)]) {
                saveJPGImageAtDocumentDirectory(_photo);
            }
        }
    }
}

- (IBAction)filtersTapped
{
//    if ([_filterView isDescendantOfView:self.view]) {
//        [_filterView removeFromSuperviewAnimated];
//    } else {
//        [_filterView addToView:self.view aboveView:_bottomView];
//        [self.view sendSubviewToBack:_filterView];
//        [self.view sendSubviewToBack:_photoView];
//    }
}

#pragma mark -
#pragma mark - Filter view actions

- (IBAction)defaultFilterTapped:(UIButton *)button
{
    [self addDetailViewToButton:button];
    _photoView.image = _photo;
}

- (IBAction)satureFilterTapped:(UIButton *)button
{
    [self addDetailViewToButton:button];
    
    if ([_cachePhoto objectForKey:kTGCacheSatureKey]) {
        _photoView.image = [_cachePhoto objectForKey:kTGCacheSatureKey];
    } else {
        [_cachePhoto setObject:[_photo saturateImage:1.8 withContrast:1] forKey:kTGCacheSatureKey];
        _photoView.image = [_cachePhoto objectForKey:kTGCacheSatureKey];
    }
    
}

- (IBAction)curveFilterTapped:(UIButton *)button
{
    [self addDetailViewToButton:button];
    
    if ([_cachePhoto objectForKey:kTGCacheCurveKey]) {
        _photoView.image = [_cachePhoto objectForKey:kTGCacheCurveKey];
    } else {
        [_cachePhoto setObject:[_photo curveFilter] forKey:kTGCacheCurveKey];
        _photoView.image = [_cachePhoto objectForKey:kTGCacheCurveKey];
    }
}

- (IBAction)vignetteFilterTapped:(UIButton *)button
{
    [self addDetailViewToButton:button];
    
    if ([_cachePhoto objectForKey:kTGCacheVignetteKey]) {
        _photoView.image = [_cachePhoto objectForKey:kTGCacheVignetteKey];
    } else {
        [_cachePhoto setObject:[_photo vignetteWithRadius:0 intensity:6] forKey:kTGCacheVignetteKey];
        _photoView.image = [_cachePhoto objectForKey:kTGCacheVignetteKey];
    }
}


#pragma mark -
#pragma mark - Private methods

- (void)addDetailViewToButton:(UIButton *)button
{
//    [_detailFilterView removeFromSuperview];
//    
//    CGFloat height = 2.5;
//    
//    CGRect frame = button.frame;
//    frame.size.height = height;
//    frame.origin.x = 0;
//    frame.origin.y = CGRectGetMaxY(button.frame) - height;
//    
//    _detailFilterView = [[UIView alloc] initWithFrame:frame];
//    _detailFilterView.backgroundColor = [TGCameraColor orangeColor];
//    _detailFilterView.userInteractionEnabled = NO;
//    
//    [button addSubview:_detailFilterView];
}

+ (instancetype)newController
{
    return [super new];
}

- (IBAction) onEditCaptionText:(UIButton *)button;
{
    if (isColorSelecting) {
        return;
    }
    
    if (isCaptionTextEditing) {
        isCaptionTextEditing = NO;
        
        [_m_pCaptionText setHidden: YES];
        [_m_pCationLabel setText: _m_pCaptionText.text];
        [[_m_pCationLabel text] stringByReplacingOccurrencesOfString:@" " withString:@""];

        [_m_pCationLabel sizeToFit];
        
    } else {
        isCaptionTextEditing = YES;
        
        [_m_pCaptionText setHidden: NO];
    }
    
}

- (IBAction) onSelectColor:(UIButton *)button;
{
    if (isCaptionTextEditing) {
        return;
    }
    
    if (isColorSelecting) {
        isColorSelecting = NO;
        
        [_m_pBackword setHidden: YES];
        [_m_pImagePicker setHidden: YES];
        [_m_pEditCaption setHidden: NO];

    } else {
        isColorSelecting = YES;

        [_m_pBackword setHidden: NO];
        [_m_pImagePicker setHidden: NO];
        [_m_pEditCaption setHidden: YES];

    }
}

- (IBAction) onShareImage:(UIButton *)button
{
    UIGraphicsBeginImageContext(_photoView.frame.size);
    [_photoView.image drawInRect:CGRectMake(0, 0, _photoView.frame.size.width, _photoView.frame.size.height)];
    CGRect rect = CGRectMake(_m_pCationLabel.frame.origin.x, _m_pCationLabel.frame.origin.y, _m_pCationLabel.frame.size.width, _m_pCationLabel.frame.size.height);
    [[UIColor whiteColor] set];
    NSString *text = [_m_pCationLabel text];
    
    [text drawInRect:CGRectIntegral(rect) withFont:[_m_pCationLabel font]];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    _m_pSharingView.image = newImage;
    [_m_pSharingView setHidden: NO];
    [_m_pSharingClose setHidden: NO];
    
    NSString * message = @"Simple Camera App";
    
    NSArray * shareItems = @[message, newImage];
    
    UIActivityViewController * avc = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
    
    avc.excludedActivityTypes = @[UIActivityTypePostToWeibo,
                                         UIActivityTypePrint,
                                         UIActivityTypeCopyToPasteboard,
                                         UIActivityTypeAssignToContact,
                                         UIActivityTypeSaveToCameraRoll,
                                         UIActivityTypeAddToReadingList,
                                         UIActivityTypePostToFlickr,
                                         UIActivityTypePostToVimeo,
                                         UIActivityTypePostToTencentWeibo,
                                         UIActivityTypeAirDrop];
    
    //if iPhone
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [self presentViewController:avc animated:YES completion:nil];
    }
    //if iPad
    else
    {
        // Change Rect to position Popover
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:avc];
        NSLog(@"%f",self.view.frame.size.width/2);
        [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, 0, 0)inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    
}

- (IBAction) onBackword:(UIButton *)button
{
    if (tempImageCount <= 0) {
        return;
    }
    
    UIGraphicsBeginImageContext(_photoView.frame.size);
    tempImageCount--;
    _photoView.image = tempImage[tempImageCount];
    
    UIGraphicsEndImageContext();
}

- (IBAction) onSaveCameraRoll:(UIButton *)button
{
//    UIGraphicsBeginImageContextWithOptions(_photoView.frame.size, NO, 0.0); //retina res
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    
    UIGraphicsBeginImageContext(_photoView.frame.size);
    [_photoView.image drawInRect:CGRectMake(0, 0, _photoView.frame.size.width, _photoView.frame.size.height)];
    CGRect rect = CGRectMake(_m_pCationLabel.frame.origin.x, _m_pCationLabel.frame.origin.y, _photoView.frame.size.width, _photoView.frame.size.height);
    [[UIColor whiteColor] set];
    NSString *text = [_m_pCationLabel text];
    
    [text drawInRect:CGRectIntegral(rect) withFont:[_m_pCationLabel font]];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil);
}

- (IBAction) onShareFacebook:(UIButton *)button
{
    
}

- (IBAction) onShareTwitter:(UIButton *)button
{
    
}

- (IBAction) onShareEmail:(UIButton *)button
{
    
}

- (IBAction) onShareText:(UIButton *)button
{
    
}


- (IBAction) onShareClose:(UIButton *)button
{
    [_m_pSharingView setHidden: YES];
    [_m_pSharingClose setHidden: YES];
}


#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return YES ;
}


@end













