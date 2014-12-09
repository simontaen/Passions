//
//  PASAddFromMusicTVC.m
//  Passions
//
//  Created by Simon Tännler on 07/12/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

@import MediaPlayer;
#import "PASAddFromMusicTVC.h"
#import "MPMediaItem+Passions.h"
#import "MPMediaItemCollection+Passions.h"
#import "PASMediaQueryAccessor.h"
#import "UIColor+Utils.h"

@interface PASAddFromMusicTVC ()
@end

@implementation PASAddFromMusicTVC

#pragma mark - Init

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (!self) return nil;
	
	// Detail Text Formatting
	__weak typeof(self) weakSelf = self;
	self.detailTextBlock = ^NSString *(id<FICEntity> artist, NSString *name) {
		NSUInteger playcount = [weakSelf playcountForArtist:artist withName:name];
		if (playcount == 1) {
			return [NSString stringWithFormat:@"%lu play", (unsigned long)playcount];
		} else {
			return [NSString stringWithFormat:@"%lu plays", (unsigned long)playcount];
		}
	};

	return self;
}

#pragma mark - Accessors

- (NSString *)title
{
	return @"My Music";
}

#pragma mark - Subclassing

- (UIColor *)chosenTintColor
{
	return [UIColor musicTintColor];
}

- (NSArray *)artistsOrderedByName
{
	return [PASMediaQueryAccessor sharedMngr].artistCollectionsOrderedByName;
}

- (NSArray *)artistsOrderedByPlaycount
{
	return [PASMediaQueryAccessor sharedMngr].artistCollectionsOrderedByPlaycount;
}

- (NSString *)nameForArtist:(id)artist
{
	NSAssert([artist isKindOfClass:[MPMediaItemCollection class]], @"%@ cannot get name for artists of class %@", NSStringFromClass([PASAddFromMusicTVC class]), NSStringFromClass([artist class]));
	return [artist PAS_artistName];
}

- (NSUInteger)playcountForArtist:(id)artist withName:(NSString *)name
{
	NSAssert([artist isKindOfClass:[MPMediaItemCollection class]], @"%@ cannot get playcount for artists of class %@", NSStringFromClass([PASAddFromMusicTVC class]), NSStringFromClass([artist class]));
	return [[PASMediaQueryAccessor sharedMngr] playcountForArtistWithName:name];
}

- (NSString *)sortOrderDescription:(PASAddArtistsSortOrder)sortOrder
{
	switch (sortOrder) {
		case PASAddArtistsSortOrderByPlaycount:
			return @"by playcount";
		default:
			return [super sortOrderDescription:sortOrder];
	}
}

@end
