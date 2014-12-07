//
//  SPTArtist+SourceImage.m
//  Passions
//
//  Created by Simon Tännler on 02/11/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "SPTArtist+FICEntity.h"
#import "FICUtilities.h"
#import "UIImage+Utils.h"
#import <objc/runtime.h>

@implementation SPTArtist (FICEntity)

#pragma mark - FICEntity

@dynamic UUID;

- (NSString *)UUID
{
	id obj = objc_getAssociatedObject(self, @selector(UUID));
	if (!obj) {
		NSString *imageName = [[self _imageURL] lastPathComponent];
		if (imageName) {
			CFUUIDBytes UUIDBytes = FICUUIDBytesFromMD5HashOfString(imageName);
			NSString *uuid = FICStringWithUUIDBytes(UUIDBytes);
			objc_setAssociatedObject(self, @selector(UUID), uuid, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
			return uuid;
		}
	}
	return obj;
}

- (NSString *)sourceImageUUID
{
	return self.UUID;
}

- (NSURL *)sourceImageURLWithFormatName:(NSString *)formatName
{
	return [self _imageURL];
}

- (FICEntityImageDrawingBlock)drawingBlockForImage:(UIImage *)image withFormatName:(NSString *)formatName
{
	return [UIImage drawingBlockForImage:image withFormatName:formatName];
}

#pragma mark - Private Methods

- (NSURL *)_imageURL
{
	id obj = objc_getAssociatedObject(self, @selector(_imageURL));
	if (!obj) {
		NSURL *url = [PASResources optimalImageUrlForSpotifyObjects:self.images];
		objc_setAssociatedObject(self, @selector(_imageURL), url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		return url;
	}
	return obj;
}

@end
