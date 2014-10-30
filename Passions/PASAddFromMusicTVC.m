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
	// if selectedViewControllerIndex == 0 a contentInset of 64 already gets set (from the NavBar)
	// probably a fault of my PASPageViewController
	self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.contentInset.top - 64, 0, 0, 0);
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
	NSAssert([artist isKindOfClass:[MPMediaItemCollection class]], @"%@ cannot get name for artists of class %@", NSStringFromClass([self class]), NSStringFromClass([artist class]));
	return [artist PAS_artistName];
}

- (NSUInteger)playcountForArtist:(id)artist withName:(NSString *)name
{
	NSAssert([artist isKindOfClass:[MPMediaItemCollection class]], @"%@ cannot get playcount for artists of class %@", NSStringFromClass([self class]), NSStringFromClass([artist class]));
	return [MPMediaItemCollection PAS_playcountForArtistWithName:name];
}

@end
