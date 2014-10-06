//
//  NSString+SourceImage.m
//  Passions
//
//  Created by Simon Tännler on 06/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "NSString+SourceImage.h"
#import "FICUtilities.h"
#import "UIImage+Scale.h"
#import <objc/runtime.h>

static void *UUIDKey;

@implementation NSString (SourceImage)

#pragma mark - PASSourceImage

- (UIImage *)sourceImage
{
	return [PASResources artistThumbnailPlaceholder];
}

#pragma mark - FICEntity

@dynamic UUID;

- (NSString *)UUID
{
    // http://oleb.net/blog/2011/05/faking-ivars-in-objc-categories-with-associative-references/
	id obj = objc_getAssociatedObject(self, UUIDKey);
	if (!obj) {
		CFUUIDBytes UUIDBytes = FICUUIDBytesFromMD5HashOfString(self);
		NSString *uuid = FICStringWithUUIDBytes(UUIDBytes);
		objc_setAssociatedObject(self, UUIDKey, uuid, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		return uuid;
	}
	return obj;
}

- (NSString *)sourceImageUUID
{
	return self.UUID;
}

- (NSURL *)sourceImageURLWithFormatName:(NSString *)formatName
{
	// This does not HAVE to be a valid URL
	// FIC uses this to key the pending requests
	return [NSURL URLWithString:self.UUID];
}

- (FICEntityImageDrawingBlock)drawingBlockForImage:(UIImage *)image withFormatName:(NSString *)formatName
{
	// TODO: maybe this could can be factored out so I don't have to write it again?
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
