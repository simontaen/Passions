//
//  PASParseObjectWithImages.m
//  Passions
//
//  Created by Simon Tännler on 05/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASParseObjectWithImages.h"

@interface PASParseObjectWithImages ()
{
	NSURL *_sourceImageURL;
	NSString *_UUID;
}
@property (nonatomic, strong) NSArray* images; // of NSString, ordered big to small

@end

@implementation PASParseObjectWithImages

@dynamic images; // of NSString

#pragma mark - Accessors

- (NSURL *)sourceImageURL
{
	if (!_sourceImageURL && self.images.count != 0) {
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
	return nil;
}

- (NSString *)sourceImageUUID
{
	return nil;
}

- (NSURL *)sourceImageURLWithFormatName:(NSString *)formatName
{
	return nil;
}

- (FICEntityImageDrawingBlock)drawingBlockForImage:(UIImage *)image withFormatName:(NSString *)formatName
{
	return nil;
}

@end
