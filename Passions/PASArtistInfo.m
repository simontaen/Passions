//
//  PASArtistInfo.m
//  Passions
//
//  Created by Simon Tännler on 18/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASArtistInfo.h"
#import "FICImageCache.h"

@interface PASArtistInfo ()

@end

@implementation PASArtistInfo

#pragma mark - Accessors

-(void)setArtist:(PASArtist *)artist
{
	if (_artist != artist) {
		_artist = artist;
		self.title = artist.name;
		[self _refreshUI:artist];
	}
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self _refreshUI:self.artist];
}

#pragma mark - Navigation

- (void)_refreshUI:(PASArtist *)artist
{
	[[FICImageCache sharedImageCache] retrieveImageForEntity:artist
											  withFormatName:ImageFormatNameArtistThumbnailLarge
											 completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
												 // check if this image view hasn't been reused for a different artist
												 if (artist == self.artist) {
													 self.artistImage.image = image ?: [PASResources artistThumbnailPlaceholder];
												 }
											 }];

	self.name.text = [artist availableAlbums];
}


@end
