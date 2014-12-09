//
//  PASAlbum.m
//  Passions
//
//  Created by Simon Tännler on 04/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASAlbum.h"
#import <Parse/PFObject+Subclass.h>
#import "SORelativeDateTransformer.h"
#import "PASResources.h"

@implementation PASAlbum
{
	NSString *_releaseDateFormatted;
}

@dynamic objectId;
@dynamic name;
@dynamic iTunesId;
@dynamic iTunesUrlMap;
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
	NSArray *favArtists = (NSArray *)[[PFUser currentUser] objectForKey:@"favArtists"] ?: @[];
	[query whereKey:@"artistId" containedIn:favArtists];
	[query orderByDescending:@"releaseDate"];
	return query;
}

#pragma mark - Compound properties

- (NSURL *)iTunesAttributedUrl
{
	return [NSURL URLWithString:[NSString stringWithFormat:@"%@&%@", [self iTunesUrl], kITunesAffiliation]];
}

- (NSString *)iTunesUrl
{
	return self.iTunesUrlMap[[PASResources userCountry]] ?: self.iTunesUrlMap[@"US"];
}

- (NSString *)releaseDateFormatted
{
	if (!_releaseDateFormatted) {
		_releaseDateFormatted = [[SORelativeDateTransformer registeredTransformer] transformedValue:self.releaseDate];
	}
	return _releaseDateFormatted;
}

@end
