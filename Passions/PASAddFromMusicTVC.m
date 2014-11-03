//
//  PASAddFromMusicTVC.m
//  Passions
//
//  Created by Simon Tännler on 07/12/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

@import MediaPlayer;
#import "PASAddFromMusicTVC.h"
#import "MPMediaItemCollection+SourceImage.h"
#import "MPMediaItem+Passions.h"
#import "UIColor+Utils.h"

@interface PASAddFromMusicTVC ()
@end

@implementation PASAddFromMusicTVC

#pragma mark - Accessors

- (NSString *)title
{
	return @"My Music";
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Detail Text Formatting
	__weak typeof(self) weakSelf = self;
	self.detailTextBlock = ^NSString *(id<FICEntity> artist, NSString *name) {
		NSUInteger playcount = [weakSelf playcountForArtist:artist withName:name];
		if (playcount == 1) {
			return [NSString stringWithFormat:@"%lu Play", (unsigned long)playcount];
		} else {
			return [NSString stringWithFormat:@"%lu Plays", (unsigned long)playcount];
		}
	};
}

#pragma mark - Subclassing

- (UIColor *)chosenTintColor
{
	return [UIColor musicTintColor];
}

- (NSArray *)artistsOrderedByName
{
	return [MPMediaItemCollection PAS_artistsOrderedByName];
}

- (NSArray *)artistsOrderedByPlaycount
{
	return [MPMediaItemCollection PAS_artistsOrderedByPlaycount];
}

- (NSString *)nameForArtist:(id)artist
{
	NSAssert([artist isKindOfClass:[MPMediaItemCollection class]], @"%@ cannot get name for artists of class %@", NSStringFromClass([PASAddFromMusicTVC class]), NSStringFromClass([artist class]));
	return [artist PAS_artistName];
}

- (NSUInteger)playcountForArtist:(id)artist withName:(NSString *)name
{
	NSAssert([artist isKindOfClass:[MPMediaItemCollection class]], @"%@ cannot get playcount for artists of class %@", NSStringFromClass([PASAddFromMusicTVC class]), NSStringFromClass([artist class]));
	return [MPMediaItemCollection PAS_playcountForArtistWithName:name];
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
