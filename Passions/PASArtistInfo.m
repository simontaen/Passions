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
		[self _refreshUiWithArtist:artist];
	}
}

-(void)setAlbum:(PASAlbum *)album
{
	if (_album != album) {
		_album = album;
		self.title = album.name;
		[self _refreshUiWithAlbum:album];
	}
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.artist ? [self _refreshUiWithArtist:self.artist] : [self _refreshUiWithAlbum:self.album];

	UIBarButtonItem *rbbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																		  target:self
																		  action:@selector(doneButtonTapped:)];
	self.navigationItem.rightBarButtonItem = rbbi;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	// Configure navigationController
	self.navigationController.navigationBarHidden = NO;
}

#pragma mark - Navigation

- (void)_refreshUiWithArtist:(PASArtist *)artist
{
	[[FICImageCache sharedImageCache] retrieveImageForEntity:artist
											  withFormatName:ImageFormatNameArtistThumbnailLarge
											 completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
												 // check if this image view hasn't been reused for a different artist
												 if (artist == self.artist) {
													 self.image.image = image ?: [PASResources artistThumbnailPlaceholder];
												 }
											 }];
	self.name.text = [artist availableAlbums];
}

- (void)_refreshUiWithAlbum:(PASAlbum *)album
{
	[[FICImageCache sharedImageCache] retrieveImageForEntity:album
											  withFormatName:ImageFormatNameAlbumThumbnailLarge
											 completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
												 // check if this image view hasn't been reused for a different album
												 if (album == self.album) {
													 self.image.image = image ?: [PASResources albumThumbnailPlaceholder];
												 }
											 }];
	self.name.text = album.name;
}

- (IBAction)doneButtonTapped:(UIBarButtonItem *)sender
{
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
