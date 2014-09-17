//
//  PASAddFromMusicTVC.m
//  Passions
//
//  Created by Simon Tännler on 07/12/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

@import MediaPlayer;
#import "PASAddFromMusicTVC.h"
#import "UIImage+Scale.h"

@interface PASAddFromMusicTVC ()
@property (nonatomic, strong) NSArray* artists; // of MPMediaItem
@property (nonatomic, strong) NSArray* artistNames; // of NSString
@property (nonatomic, strong) dispatch_queue_t artworkQ;
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

- (NSArray *)artistNames
{
	if (!_artistNames) {
		NSMutableArray *names = [[NSMutableArray alloc] initWithCapacity:self.artists.count];
		for (MPMediaItem *item in self.artists) {
			[names addObject:[item valueForProperty: MPMediaItemPropertyArtist]];
		}
		_artistNames = names;
	}
	return _artistNames;
}

#pragma mark - View Lifecycle

- (NSString *)getTitle
{
	return @"iPod Artists";
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.artworkQ = dispatch_queue_create("artworkQ", DISPATCH_QUEUE_CONCURRENT);
}

#pragma mark - UITableViewDataSource required

- (void)setThumbnailImageForCell:(PASAddingArtistCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	MPMediaItem *item = self.artists[indexPath.row];
	__weak typeof(cell) weakCell = cell;
	dispatch_async(self.artworkQ, ^{
		
		MPMediaItemArtwork *artwork = [item valueForProperty: MPMediaItemPropertyArtwork];
		UIImage *artworkImage = [artwork imageWithSize:cell.artistImage.image.size];
		UIImage *newImage;
		
		if (artworkImage) {
			newImage = [artworkImage PASscaleToAspectFillSize:weakCell.artistImage.image.size];
		} else {
			newImage = [PASResources artistThumbnailPlaceholder];
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			weakCell.artistImage.image = newImage;
		});
	});
}

@end
