//
//  PASParseObjectWithImages.m
//  Passions
//
//  Created by Simon Tännler on 05/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASParseObjectWithImages.h"

@interface PASParseObjectWithImages ()
@property (nonatomic, copy, readwrite) NSString *UUID;
@property (nonatomic, copy, readwrite) NSString *sourceImageUUID;

@end

@implementation PASParseObjectWithImages

@synthesize UUID;
@synthesize sourceImageUUID;
@dynamic images; // of NSString

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
