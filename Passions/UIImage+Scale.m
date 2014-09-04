//
//  UIImage+Scale.m
//  Passions
//
//  Created by Simon Tännler on 04/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "UIImage+Scale.h"

/// inspired by http://stackoverflow.com/a/17676011
@implementation UIImage (Scale)

- (UIImage*)PASscaleToFillSize:(CGSize)size
{
	UIGraphicsBeginImageContext(size);
	CGRect imageRect = CGRectMake(0.0, 0.0, size.width, size.height);
	
	[self drawInRect:imageRect];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}

- (UIImage*)PASscaleToAspectFitSize:(CGSize)size
{
    float widthRatio = size.width/self.size.width;
    float heightRatio = size.height/self.size.height;
	
	UIGraphicsBeginImageContext(size);
	CGRect imageRect;
	
	// Aspect Fit: > and no origin transition (0.0, 0.0)
    if(widthRatio > heightRatio) {
		// width is smaller than height
        imageRect = CGRectMake(0.0, 0.0, self.size.width*heightRatio, self.size.height*heightRatio);
    } else {
		// height is smaller than width
        imageRect = CGRectMake(0.0, 0.0, self.size.width*widthRatio, self.size.height*widthRatio);
    }
	
    [self drawInRect:imageRect];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return newImage;
}

- (UIImage*)PASscaleToAspectFillSize:(CGSize)size
{
    float widthRatio = size.width/self.size.width;
    float heightRatio = size.height/self.size.height;
	
    UIGraphicsBeginImageContext(size);
	CGRect imageRect;
	
	// Aspect Fill: < and origin transition
    if(widthRatio < heightRatio) {
		// width is bigger than height
		CGFloat newImageWidth = self.size.width*heightRatio;
		CGFloat newImageHeight = self.size.height*heightRatio;
		// need to move on x (width) axis to the left (minus)
		CGFloat xAxisMove = (size.width - newImageWidth) / 2;
		
        imageRect = CGRectMake(xAxisMove, 0.0, newImageWidth, newImageHeight);
    } else {
		// height is bigger than width
		CGFloat newImageWidth = self.size.width*widthRatio;
		CGFloat newImageHeight = self.size.height*widthRatio;
		// need to move on y (height) axis upwards (plus, 0.0 is top left)
		CGFloat yAxisMove = (newImageWidth - size.height) / 2;
		
        imageRect = CGRectMake(0.0, yAxisMove, newImageWidth, newImageHeight);
    }
    
	[self drawInRect:imageRect];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return newImage;
}

@end
