//
//  ColorPickerView.m
//  ColorPicker
//
//  Created by Gilly Dekel on 23/3/09.
//  Extended by Fabián Cañas August 2010.
//  Copyright 2010. All rights reserved.
//

#import "ColorPickerView.h"
#import "GradientView.h"
#import "Constants.h"
#import "UIColor-HSVAdditions.h"
//#import "global.h"

@implementation ColorPickerView

@synthesize currentHue;
@synthesize currentSaturation;
@synthesize currentBrightness;

@synthesize currentHue1;
@synthesize currentSaturation1;
@synthesize currentBrightness1;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder  {
	if (self = [super initWithCoder:coder]) {
        
        UIDevice  *thisDevice = [UIDevice currentDevice];
        if(thisDevice.userInterfaceIdiom == UIUserInterfaceIdiomPad)
        {
            scoreboardWidthRate = 1024.0f / 480.0f;
            scoreboardHeightRate = 768.0f / 320.0f;
        } else {
            
            CGRect screenBound = [[UIScreen mainScreen] bounds];
            CGSize screenSize = screenBound.size;
            CGFloat screenHeight = screenSize.height;
            // iPhone
            if (screenHeight == 480.0f) {
                scoreboardWidthRate = 1.0f;
                scoreboardHeightRate = 1.0f;
            } else {
                scoreboardWidthRate = 568.0f / 480.0f;
                scoreboardHeightRate = 1.0f;
            }
        }
        
		gradientView = [[GradientView alloc] initWithFrame:kBrightnessGradientPlacent];
		//[gradientView setTheColor:[UIColor yellowColor]];
		[self addSubview:gradientView];
        [gradientView setHidden:YES];
		[self sendSubviewToBack:gradientView];
		[self setMultipleTouchEnabled:YES];
		colorMatrixFrame = CGRectMake(20 * scoreboardWidthRate, 56 * scoreboardHeightRate, 189 * scoreboardWidthRate, 76 * scoreboardHeightRate);
		UIImageView *hueSatImage = [[UIImageView alloc] initWithFrame:colorMatrixFrame];
		[hueSatImage setImage:[UIImage imageNamed:kHueSatImage]];
		[self addSubview:hueSatImage];
		[self sendSubviewToBack:hueSatImage];
		[hueSatImage release];
        
        colorGuestFrame = CGRectMake(20 * scoreboardWidthRate, 182 * scoreboardHeightRate, 189 * scoreboardWidthRate, 76 * scoreboardHeightRate);
        UIImageView *hueGuestImage = [[UIImageView alloc] initWithFrame:colorGuestFrame];
		[hueGuestImage setImage:[UIImage imageNamed:kHueSatImage]];
		[self addSubview:hueGuestImage];
		[self sendSubviewToBack:hueGuestImage];
		[hueGuestImage release];
        
		currentBrightness = kInitialBrightness;
		
		currentColor = [[UIColor alloc]init];
        
	}
	return self;
}

- (void) setColor:(UIColor *)color {
    currentColor = color;
    currentHue = color.hue;
    currentSaturation = color.saturation;
    currentBrightness = color.brightness;
    CGPoint hueSatPosition;
    CGPoint brightnessPosition;
    
    hueSatPosition.x = (currentHue * kMatrixWidth) + kXAxisOffset;
    hueSatPosition.y = (1.0-currentSaturation)*kMatrixHeight + kYAxisOffset;
    
    brightnessPosition.x = (1.0 + kBrightnessEpsilon - currentBrightness) * gradientView.frame.size.width;
    brightnessPosition.y = kBrightBarYCenter;
    
    [gradientView setTheColor:color];
    
    showColor.homeColor = currentColor;
    
    crossHairs.center = hueSatPosition;
}

- (void) setColor1:(UIColor *)color {
    currentColor = color;
    currentHue1 = color.hue;
    currentSaturation1 = color.saturation;
    currentBrightness1 = color.brightness;
    CGPoint hueSatPosition;
    CGPoint brightnessPosition;
    hueSatPosition.x = (currentHue1*kMatrixWidth)+kXAxisOffset;
    hueSatPosition.y = (1.0-currentSaturation1)*kMatrixHeight+kYAxisOffset1;
    brightnessPosition.x = (1.0+kBrightnessEpsilon-currentBrightness1)*gradientView.frame.size.width;
    
    // Original input brightness code (from down below)
    // currentBrightness = 1.0-(position.x/gradientView.frame.size.width) + kBrightnessEpsilon;
    
    brightnessPosition.y = kBrightBarYCenter;
    [gradientView setTheColor:color];
    //[showColor setBackgroundColor:currentColor];
    showColor1.guestColor = currentColor;
    
//    crossHairs.center = hueSatPosition;
    brightnessBar.center = hueSatPosition;
}


- (void) updateHueSatWithMovement : (CGPoint) position {

	currentHue = (position.x / scoreboardWidthRate - kXAxisOffset) / kMatrixWidth;
	currentSaturation = 1.0 -  (position.y / scoreboardHeightRate - kYAxisOffset) / kMatrixHeight;
	
	UIColor *forGradient = [UIColor colorWithHue:currentHue 
									saturation:currentSaturation 
									brightness: kInitialBrightness 
									alpha:1.0];
	
	[gradientView setTheColor:forGradient];
	[gradientView setupGradient];
	[gradientView setNeedsDisplay];

	currentColor  = [UIColor colorWithHue:currentHue 
									   saturation:currentSaturation 
									   brightness:currentBrightness
									   alpha:1.0];
	
	//[showColor setBackgroundColor:currentColor];
    showColor.homeColor = currentColor;
    [showColor setNeedsDisplay];
}


- (void) updateBrightnessWithMovement : (CGPoint) position {
    
    currentHue1 = (position.x / scoreboardWidthRate - kXAxisOffset) / kMatrixWidth;
	currentSaturation1 = 1.0 -  (position.y / scoreboardHeightRate - kYAxisOffset1) / kMatrixHeight;
	
	UIColor *forGradient = [UIColor colorWithHue:currentHue1
                                      saturation:currentSaturation1
                                      brightness: kInitialBrightness
                                           alpha:1.0];
	
	[gradientView setTheColor:forGradient];
	[gradientView setupGradient];
	[gradientView setNeedsDisplay];
    
	currentColor  = [UIColor colorWithHue:currentHue1
                               saturation:currentSaturation1
                               brightness:currentBrightness1
                                    alpha:1.0];
	
	//[showColor setBackgroundColor:currentColor];
    showColor1.guestColor = currentColor;
    [showColor1 setNeedsDisplay];
	
}

//Touch parts : 

// Scales down the view and moves it to the new position. 
- (void)animateView:(UIImageView *)theView toPosition:(CGPoint) thePosition
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:kAnimationDuration];
	// Set the center to the final postion
	theView.center = thePosition;
	// Set the transform back to the identity, thus undoing the previous scaling effect.
	theView.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];	
}

-(void) dispatchTouchEvent:(CGPoint)position
{
    /*
	if (CGRectContainsPoint(colorMatrixFrame,position))
	{
		[self animateView:crossHairs toPosition: position];
		[self updateHueSatWithMovement:position];
		isHomeSelect = YES;
	}
	
    if (CGRectContainsPoint(colorGuestFrame, position))
	{
		[self animateView:brightnessBar toPosition: position];
		[self updateBrightnessWithMovement:position];
        isGuestSelect = YES;
	}
     */
}


// Handles the start of a touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	
	for (UITouch *touch in touches) {
		[self dispatchTouchEvent:[touch locationInView:self]];
		}	
}

// Handles the continuation of a touch.
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{  

	for (UITouch *touch in touches){
		[self dispatchTouchEvent:[touch locationInView:self]];
	}
	
}

- (void)drawRect:(CGRect)rect {
    
	CGFloat x = currentHue * kMatrixWidth;
	//CGFloat y = currentSaturation * kMatrixHeight;
	
	//crossHairs.center = CGPointMake(x,y);
	
	//x = currentBrightness * gradientView.frame.size.width;
	
	//brightnessBar.center = CGPointMake(x,kBrightBarYCenter);
	
	[gradientView setupGradient];
	[gradientView setNeedsDisplay];
	[self sendSubviewToBack:showColor];
    [self sendSubviewToBack:showColor1];

}

- (UIColor *) getColorShown {
	return [UIColor colorWithHue:currentHue saturation:currentSaturation brightness:currentBrightness alpha:1.0];
}

- (UIColor *) getColorShown1 {
	return [UIColor colorWithHue:currentHue1 saturation:currentSaturation1 brightness:currentBrightness1 alpha:1.0];
}

- (void)dealloc {
    [super dealloc];
	
}

@end
