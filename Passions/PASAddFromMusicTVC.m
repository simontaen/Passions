//
//  PASAddFromMusicTVC.m
//  Passions
//
//  Created by Simon Tännler on 07/12/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

@import MediaPlayer;
#import "PASAddFromMusicTVC.h"

@interface PASAddFromMusicTVC ()
@property (nonatomic, strong) NSArray* artists; // of MPMediaItem
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

- (NSArray *)artists
{
	if (!_artists) {
		NSArray *collections = [[MPMediaQuery artistsQuery] collections];
		NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:collections.count];
		for (MPMediaItemCollection *itemCollection in collections) {
			[items addObject:[itemCollection representativeItem]];
		}
		_artists = items;
	};
	return _artists;
}

#pragma mark - Subclassing

// will be implemented by subclass
- (NSArray *)artistsOrderedByName
{
	NSSortDescriptor *artistNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:MPMediaItemPropertyArtist
																			   ascending:YES
																				selector:@selector(localizedCaseInsensitiveCompare:)];
	return [self.artists sortedArrayUsingDescriptors:@[artistNameSortDescriptor]];
}

// will be implemented by subclass
- (NSArray *)artistsOrderedByPlaycout
{
	NSSortDescriptor *playCountSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:MPMediaItemPropertyPlayCount
																			  ascending:NO
																			   selector:@selector(caseInsensitiveCompare:)];
	return [self.artists sortedArrayUsingDescriptors:@[playCountSortDescriptor]];
}

- (NSString *)nameForArtist:(id)artist
{
	NSAssert([artist isKindOfClass:[MPMediaItem class]], @"%@ cannot get name for artists of class %@", NSStringFromClass([self class]), NSStringFromClass([artist class]));
	return [artist valueForProperty:MPMediaItemPropertyArtist];
}

- (NSUInteger)playcountForArtist:(id)artist
{
	NSAssert([artist isKindOfClass:[MPMediaItem class]], @"%@ cannot get playcount for artists of class %@", NSStringFromClass([self class]), NSStringFromClass([artist class]));
	NSNumber *playCount = (NSNumber *) [artist valueForProperty:MPMediaItemPropertyPlayCount];
	return [playCount unsignedIntegerValue];
}

@end
