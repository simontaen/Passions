//
//  PASParseObjectWithImages.m
//  Passions
//
//  Created by Simon Tännler on 05/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASParseObjectWithImages.h"
#import "FICUtilities.h"
#import "UIImage+Utils.h"

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
	if (!_sourceImageURL) {
		NSString *url;
		if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad || self.images.count < 4) {
			url = [self.images firstObject];
		} else {
			// we have 4 or more images, the second image should suffice for iPhone
			url = self.images[1];
		}
		_sourceImageURL = [NSURL URLWithString:url];
	}
	return _sourceImageURL;
}

#pragma mark - FICEntity

- (NSString *)UUID
{
	if (_UUID == nil) {
		// MD5 hashing is expensive enough that we only want to do it once
		NSString *imageName = [self.sourceImageURL lastPathComponent];
		if (imageName) {
			CFUUIDBytes UUIDBytes = FICUUIDBytesFromMD5HashOfString(imageName);
			_UUID = FICStringWithUUIDBytes(UUIDBytes);
		}
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
	return [UIImage drawingBlockForImage:image withFormatName:formatName];
}

@end
