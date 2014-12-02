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
#import "PASAlbum.h"

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

// returns nil or a url from parse
- (NSURL *)sourceImageURL
{
	if (!_sourceImageURL && [self.images firstObject]) {
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

// generate a UUID, if it succeeds store it and keep returning it, if it fails return a dummy
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

//	if (_UUID) {
//		return _UUID;
//	} else {
//		// this is pretty hacky, but like this
//		// FICImageCache will "fetch" and process the placeholder once
//		// for all PASParseObjectWithImages objects
//		if ([self isKindOfClass:[PASAlbum class]]) {
//			static NSString *dummyAlbumUUID;
//			static dispatch_once_t albumOnce;
//			dispatch_once(&albumOnce, ^{
//				CFUUIDBytes dummyAlbumUUIDBytes = FICUUIDBytesFromMD5HashOfString(@"album");
//				dummyAlbumUUID = FICStringWithUUIDBytes(dummyAlbumUUIDBytes);
//			});
//			return dummyAlbumUUID;
//			
//		} else {
//			static NSString *dummyOthersUUID;
//			static dispatch_once_t othersOnce;
//			dispatch_once(&othersOnce, ^{
//				CFUUIDBytes dummyOthersUUIDBytes = FICUUIDBytesFromMD5HashOfString(@"artist");
//				dummyOthersUUID = FICStringWithUUIDBytes(dummyOthersUUIDBytes);
//			});
//			return dummyOthersUUID;
//		}
//	};
}

- (NSString *)sourceImageUUID
{
	return self.UUID;
}

- (NSURL *)sourceImageURLWithFormatName:(NSString *)formatName
{
	return self.sourceImageURL;

//	if (self.sourceImageURL) {
//		return self.sourceImageURL;
//	} else {
//		// This does not HAVE to be a valid URL
//		// FIC uses this to key the pending requests
//		return [NSURL URLWithString:self.UUID];
//	}
}

- (FICEntityImageDrawingBlock)drawingBlockForImage:(UIImage *)image withFormatName:(NSString *)formatName
{
	return [UIImage drawingBlockForImage:image withFormatName:formatName];
}

@end
