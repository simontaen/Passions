//
//  PASPageControlView.m
//  Passions
//
//  Created by Simon Tännler on 11/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//
//  RoundedRect code created by Jeff LaMarche on 11/13/08.
//  http://iphonedevelopment.blogspot.ch/2008/11/creating-transparent-uiviews-rounded.html
//

#import "PASPageControlView.h"

@implementation PASPageControlView

#pragma mark - Init

- (void)awakeFromNib
{
	// Initialization code
	super.opaque = NO;
	self.strokeColor = kDefaultStrokeColor;
	super.backgroundColor = [UIColor clearColor];
	self.rectColor = kDefaultRectColor;
	self.strokeWidth = kDefaultStrokeWidth;
	self.cornerRadius = kDefaultCornerRadius;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    // Ignore any attempt to set background color - backgroundColor must stay set to clearColor
    // We could throw an exception here, but that would cause problems with IB, since backgroundColor
    // is a palletized property, IB will attempt to set backgroundColor for any view that is loaded
    // from a nib, so instead, we just quietly ignore this.
    //
    // Alternatively, we could put an NSLog statement here to tell the programmer to set rectColor...
}

- (void)setOpaque:(BOOL)opaque
{
    // Ignore attempt to set opaque to YES.
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, self.strokeWidth);
    CGContextSetStrokeColorWithColor(context, self.strokeColor.CGColor);
    CGContextSetFillColorWithColor(context, self.rectColor.CGColor);
    
    CGRect rrect = self.bounds;
    
    CGFloat radius = self.cornerRadius;
    CGFloat width = rrect.size.width;
    CGFloat height = rrect.size.height;
	
    // Make sure corner radius isn't larger than half the shorter side
    if (radius > width/2.0)
        radius = width/2.0;
    if (radius > height/2.0)
        radius = height/2.0;
    
    CGFloat minx = CGRectGetMinX(rrect);
    CGFloat midx = CGRectGetMidX(rrect);
    CGFloat maxx = CGRectGetMaxX(rrect);
    CGFloat miny = CGRectGetMinY(rrect);
    CGFloat midy = CGRectGetMidY(rrect);
    CGFloat maxy = CGRectGetMaxY(rrect);
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end
