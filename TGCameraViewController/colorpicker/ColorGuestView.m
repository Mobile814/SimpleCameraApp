//
//  ColorGuestView.m
//  Scoreboard
//
//  Created by Lion on 5/15/14.
//
//

#import "ColorGuestView.h"

void drawRoundRect1(CGContextRef context, CGRect rect) {
    CGFloat radius = 7;
    CGContextBeginPath(context);
	CGContextMoveToPoint(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect));
    CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMinY(rect) + radius, radius, 3 * M_PI / 2, 0, 0);
    CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMaxY(rect) - radius, radius, 0, M_PI / 2, 0);
    CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMaxY(rect) - radius, radius, M_PI / 2, M_PI, 0);
    CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect) + radius, radius, M_PI, 3 * M_PI / 2, 0);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
}


@implementation ColorGuestView

@synthesize guestColor;

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}


- (void)drawRect:(CGRect)rect {
    // We only draw when we're drawing the whole swatch. Maybe there's a problem with this?
    if (rect.size.width==self.frame.size.width){
        
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        
        CGColorSpaceRef rgba = CGColorSpaceCreateDeviceRGB();
        
        CGColorRef borderColor = [[UIColor darkGrayColor] CGColor];
        
        CGFloat channelsFill[] = {1.0,1.0,1.0,1.0};
        
        CGColorRef backgroundFill;
        if (guestColor!=nil) {
            backgroundFill = [guestColor CGColor];
        } else {
            backgroundFill = CGColorCreate(rgba, channelsFill);
        }
        
        CGContextSetFillColorWithColor(currentContext, backgroundFill);
        CGContextSetLineWidth(currentContext, 1);
        CGContextSetStrokeColorWithColor(currentContext, borderColor);
        
        drawRoundRect1(currentContext, rect);
        
        //
        // Clean-up
        //
        CGColorSpaceRelease(rgba);
        
        if (guestColor==nil) {
            CGColorRelease(backgroundFill);
        }
        // I don't think we need to release the border color since we didn't really create it
        // Releasing causes a fault, so I think we don't really own this ColorRef.
        //CGColorRelease(borderColor);
    }
}


- (void)dealloc {
    self.guestColor = nil;
    [super dealloc];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
