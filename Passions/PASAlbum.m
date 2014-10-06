//
//  PASAlbum.m
//  Passions
//
//  Created by Simon Tännler on 04/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASAlbum.h"
#import <Parse/PFObject+Subclass.h>

NSString *const ImageFormatFamilyAlbumThumbnails = @"ImageFormatFamilyAlbumThumbnails";
NSString *const ImageFormatNameAlbumThumbnailMedium = @"ImageFormatNameAlbumThumbnailMedium";
CGSize const ImageFormatImageSizeAlbumThumbnailMedium = {154, 154};

@implementation PASAlbum

@dynamic objectId;
@dynamic name;
@dynamic spotifyId;
@dynamic href;
@dynamic artistId; // PASArtist.objectId
@dynamic releaseDate;
@dynamic releaseDatePrecision;
@dynamic utc;
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

#pragma mark - Queries

+ (PFQuery *)albumsOfCurrentUsersFavoriteArtists
{
	PFQuery *query = [PASAlbum query];
	[query whereKey:@"artistId" containedIn:(NSArray *)[[PFUser currentUser] objectForKey:@"favArtists"]];
	[query orderByDescending:@"releaseDate"];
	return query;
}

@end
