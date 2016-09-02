//
//  ColorPickerView.h
//  ColorPicker
//
//  Created by Gilly Dekel on 23/3/09.
//  Extended by Fabián Cañas August 2010.
//  Copyright 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorHomeView.h"
#import "ColorGuestView.h"

@class GradientView;
@interface ColorPickerView : UIView {
	GradientView *gradientView;
	IBOutlet ColorHomeView *showColor;
    IBOutlet ColorGuestView *showColor1;
    
	IBOutlet UIImageView *crossHairs;
	IBOutlet UIImageView *brightnessBar;
	
	//Private vars
	CGRect colorMatrixFrame;
    CGRect colorGuestFrame;
	
	CGFloat currentBrightness;
	CGFloat currentHue;
	CGFloat currentSaturation;
    
    CGFloat currentBrightness1;
	CGFloat currentHue1;
	CGFloat currentSaturation1;
	
	UIColor *currentColor;
    
    float scoreboardWidthRate;
    float scoreboardHeightRate;
}

@property (readwrite) CGFloat currentBrightness;
@property (readwrite) CGFloat currentHue;
@property (readwrite) CGFloat currentSaturation;

@property (readwrite) CGFloat currentBrightness1;
@property (readwrite) CGFloat currentHue1;
@property (readwrite) CGFloat currentSaturation1;

- (UIColor *) getColorShown;
- (void) setColor:(UIColor *)color;
- (void) setColor1:(UIColor *)color;
- (void) animateView:(UIImageView *)theView toPosition:(CGPoint) thePosition;

@end
