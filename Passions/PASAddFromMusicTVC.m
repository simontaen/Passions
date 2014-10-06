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
@property (nonatomic, strong) NSArray* artistNames; // of NSString
@end

@implementation PASAddFromMusicTVC

#pragma mark - Accessors

// returns the proper objects
- (NSArray *)artists
{
	if (!_artists) {
		// order by a combination of
		// MPMediaItemPropertyPlayCount
		// MPMediaItemPropertyRating
		// see MPMediaItem Class Reference
		NSArray *collections = [[MPMediaQuery artistsQuery] collections];
		NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:collections.count];
		for (MPMediaItemCollection *itemCollection in collections) {
			[items addObject:[itemCollection representativeItem]];
		}
		
		NSSortDescriptor *artistNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:MPMediaItemPropertyArtist ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
		
		_artists = [items sortedArrayUsingDescriptors:@[artistNameSortDescriptor]];
	};
	return _artists;
}

- (NSString *)nameForArtist:(id)artist
{
	NSAssert([artist isKindOfClass:[MPMediaItem class]], @"%@ cannot handle artists of class %@", NSStringFromClass([self class]), NSStringFromClass([artist class]));
	return [artist valueForProperty: MPMediaItemPropertyArtist];
}

#pragma mark - View Lifecycle

- (NSString *)getTitle
{
	return @"iPod Artists";
}

@end
