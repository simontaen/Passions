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
@dynamic iTunesId;
@dynamic iTunesUrl;
@dynamic explicitness;
@dynamic trackCount;
@dynamic iTunesGenreName;
@dynamic artistId; // PASArtist.objectId
@dynamic artistName; // PASArtist.name
@dynamic releaseDate;
@dynamic spotifyId;
@dynamic spotifyLink;
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

#pragma mark - Compound properties

- (NSURL *)iTunesAttributedUrl
{
	return [NSURL URLWithString:[NSString stringWithFormat:@"%@&%@", self.iTunesUrl, kITunesAffiliation]];
}

@end
