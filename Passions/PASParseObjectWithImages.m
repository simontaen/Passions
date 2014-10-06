//
//  PASParseObjectWithImages.m
//  Passions
//
//  Created by Simon Tännler on 05/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASParseObjectWithImages.h"
#import "FICUtilities.h"
#import "UIImage+Scale.h"

@interface PASParseObjectWithImages ()
@property (nonatomic, copy, readwrite) NSString *UUID;
@property (nonatomic, copy, readwrite) NSURL *sourceImageURL;
@property (nonatomic, strong) NSArray* images; // of NSString, ordered big to small
@end

@implementation PASParseObjectWithImages

@synthesize UUID = _UUID;
@synthesize sourceImageURL = _sourceImageURL;
@dynamic images;

#pragma mark - Accessors

- (NSURL *)sourceImageURL
{
	if (!_sourceImageURL && self.images.count != 0) {
		// TODO: what could be your biggest size? Choose based on that
		// you could switch based on interface idiom here
		// round down, this is only a thumbnail
		int middle = (int)(self.images.count / 2 - ((self.images.count % 2) / 2));
		_sourceImageURL = [NSURL URLWithString:self.images[middle]];
	}
	return _sourceImageURL;
}

#pragma mark - FICEntity

- (NSString *)UUID
{
	if (_UUID == nil) {
		// MD5 hashing is expensive enough that we only want to do it once
		NSString *imageName = [self.sourceImageURL lastPathComponent];
		CFUUIDBytes UUIDBytes = FICUUIDBytesFromMD5HashOfString(imageName);
		_UUID = FICStringWithUUIDBytes(UUIDBytes);
	}
	
	return _UUID;
}

- (NSString *)sourceImageUUID
{
	return self.UUID;
}

- (NSURL *)sourceImageURLWithFormatName:(NSString *)formatName
{
	return self.sourceImageURL;
}

- (FICEntityImageDrawingBlock)drawingBlockForImage:(UIImage *)image withFormatName:(NSString *)formatName
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
