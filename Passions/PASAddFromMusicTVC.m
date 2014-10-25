//
//  PASAddFromMusicTVC.m
//  Passions
//
//  Created by Simon Tännler on 07/12/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

@import MediaPlayer;
#import "PASAddFromMusicTVC.h"
#import "MPMediaQuery+Passions.h"
#import "MPMediaItem+Passions.h"

@interface PASAddFromMusicTVC ()
@property (nonatomic, strong) NSArray* myArtists; // of MPMediaItem
@end

@implementation PASAddFromMusicTVC

#pragma mark - Accessors

- (NSString *)title
{
	return @"iPod Artists";
}

// order by a combination of
// MPMediaItemPropertyPlayCount
// MPMediaItemPropertyRating
// see MPMediaItem Class Reference

// don't call this artists as you would overwrite the superclass!
- (NSArray *)myArtists
{
	if (!_myArtists) {
		_myArtists = [MPMediaQuery PAS_artistsQuery];
	};
	return _myArtists;
}

#pragma mark - Subclassing

- (NSArray *)artistsOrderedByName
{
	return [MPMediaQuery PAS_orderedArtistsByName:self.myArtists];
}

- (NSArray *)artistsOrderedByPlaycout
{
	return [MPMediaQuery PAS_orderedArtistsByPlaycount:self.myArtists];
}

- (NSString *)nameForArtist:(id)artist
{
	NSAssert([artist isKindOfClass:[MPMediaItem class]], @"%@ cannot get name for artists of class %@", NSStringFromClass([self class]), NSStringFromClass([artist class]));
	return [artist PAS_artistName];
}

- (NSUInteger)playcountForArtist:(id)artist
{
	NSAssert([artist isKindOfClass:[MPMediaItem class]], @"%@ cannot get playcount for artists of class %@", NSStringFromClass([self class]), NSStringFromClass([artist class]));
	return [artist PAS_artistPlaycount];
}

@end
