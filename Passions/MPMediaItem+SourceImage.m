//
//  MPMediaItem+SourceImage.m
//  Passions
//
//  Created by Simon Tännler on 06/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "MPMediaItem+SourceImage.h"
#import "FICUtilities.h"
#import "UIImage+Utils.h"
#import <objc/runtime.h>
#import "PASArtist.h"

static void *UUIDKey;

@implementation MPMediaItem (SourceImage)

#pragma mark - PASSourceImage

- (UIImage *)sourceImageWithFormatName:(NSString *)formatName;
{
	NSAssert([formatName isEqualToString:ImageFormatNameArtistThumbnailSmall], @"Unsupported format Name: %@", formatName);
	return [[self valueForProperty:MPMediaItemPropertyArtwork] imageWithSize:ImageFormatImageSizeArtistThumbnailLarge];
}

#pragma mark - FICEntity

@dynamic UUID;

- (NSString *)UUID
{
	// http://oleb.net/blog/2011/05/faking-ivars-in-objc-categories-with-associative-references/
	id obj = objc_getAssociatedObject(self, UUIDKey);
	if (!obj) {
		NSNumber *persistentId = [self valueForProperty:MPMediaItemPropertyPersistentID];
		CFUUIDBytes UUIDBytes = FICUUIDBytesFromMD5HashOfString([persistentId stringValue]);
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
	return [UIImage drawingBlockForImage:image withFormatName:formatName];
}

@end
