//
//  PASAlbum.m
//  Passions
//
//  Created by Simon Tännler on 04/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASAlbum.h"
#import <Parse/PFObject+Subclass.h>

@implementation PASAlbum

@dynamic objectId;
@dynamic name;
@dynamic spotifyId;
@dynamic href;
@dynamic artistId; // PASArtist.objectId
@dynamic releaseDate;
@dynamic releaseDatePrecision;
@dynamic utc;
@dynamic images; // of NSString
@dynamic createdAt;
@dynamic updatedAt;

#pragma mark - Parse

+ (void)load
{
	[self registerSubclass];
}

+ (NSString *)parseClassName
{
	return @"Album";
}

@end
