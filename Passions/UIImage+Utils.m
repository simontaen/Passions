//
//  UIImage+Utils.m
//  Passions
//
//  Created by Simon Tännler on 04/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "UIImage+Utils.h"

/// inspired by http://stackoverflow.com/a/17676011
@implementation UIImage (Utils)

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
    CGFloat widthRatio = size.width/self.size.width;
    CGFloat heightRatio = size.height/self.size.height;
	
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
    CGFloat widthRatio = size.width/self.size.width;
    CGFloat heightRatio = size.height/self.size.height;
	
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

// https://github.com/path/FastImageCache/blob/9cf321046790194a14cf1ddda4fee56b5bf1e640/FastImageCacheDemo/Classes/FICDPhoto.m#L84
+ (UIImage *)FICDSquareImageFromImage:(UIImage *)image
{
	UIImage *squareImage = nil;
	CGSize imageSize = [image size];
	
	if (imageSize.width == imageSize.height) {
		squareImage = image;
	} else {
		// Compute square crop rect
		CGFloat smallerDimension = MIN(imageSize.width, imageSize.height);
		CGRect cropRect = CGRectMake(0, 0, smallerDimension, smallerDimension);
		
		// Center the crop rect either vertically or horizontally, depending on which dimension is smaller
		if (imageSize.width <= imageSize.height) {
			cropRect.origin = CGPointMake(0, rintf((float)((imageSize.height - smallerDimension) / 2.0f)));
		} else {
			cropRect.origin = CGPointMake(rintf((float)((imageSize.width - smallerDimension) / 2.0f)), 0);
		}
		
		CGImageRef croppedImageRef = CGImageCreateWithImageInRect([image CGImage], cropRect);
		squareImage = [UIImage imageWithCGImage:croppedImageRef];
		CGImageRelease(croppedImageRef);
	}
	
	return squareImage;
}

+ (FICEntityImageDrawingBlock)drawingBlockForImage:(UIImage *)image withFormatName:(NSString *)formatName
{
	FICEntityImageDrawingBlock drawingBlock = ^(CGContextRef context, CGSize contextSize) {
		CGRect contextBounds = CGRectZero;
		contextBounds.size = contextSize;
		CGContextClearRect(context, contextBounds);
		
		// Fill with white for image formats that are opaque
		CGContextSetFillColorWithColor(context, [[UIColor whiteColor] CGColor]);
		CGContextFillRect(context, contextBounds);
		
		// crop to a square image
		UIImage *squareImage = [UIImage FICDSquareImageFromImage:image];
		
		UIGraphicsPushContext(context);
		[squareImage drawInRect:contextBounds];
		UIGraphicsPopContext();
	};
	
	return drawingBlock;
}

@end
