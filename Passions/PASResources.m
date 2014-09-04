//
//  PASResources.m
//  Passions
//
//  Created by Simon Tännler on 04/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASResources.h"

@implementation PASResources

+ (UIImage *) artistThumbnailPlaceholder
{
	static UIImage *artistThumbnailPlaceholder;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		artistThumbnailPlaceholder = [UIImage imageNamed: @"image.png"];
	});
	return artistThumbnailPlaceholder;
}

+ (UIImage *) albumThumbnailPlaceholder
{
	return [self artistThumbnailPlaceholder];
}


@end
