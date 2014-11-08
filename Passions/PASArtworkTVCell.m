//
//  PASArtworkTVCell.m
//  Passions
//
//  Created by Simon Tännler on 08/11/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASArtworkTVCell.h"
#import "FICImageCache.h"

@interface PASArtworkTVCell()
@property (nonatomic, strong) id<FICEntity> entity;
@end

@implementation PASArtworkTVCell

#pragma mark - "Accessors"

- (void)showAlbum:(PASAlbum *)album
{
	if (album != _entity) {
		_entity = album;
		
		[self _loadThumbnailImageForEntity:album withFormatName:ImageFormatNameAlbumThumbnailLarge placeholder:[PASResources albumThumbnailPlaceholder]];
	}
}

#pragma mark - Private Methods

- (void)_loadThumbnailImageForEntity:(id<FICEntity>)entity withFormatName:(NSString *)formatName placeholder:(UIImage *)placeholder
{
	// clear the image to avoid seeing old images when scrolling
	self.artworkImage.image = nil;
	
	[[FICImageCache sharedImageCache] retrieveImageForEntity:entity
											  withFormatName:formatName
											 completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
												 // check if this image view hasn't been reused for a different entity
												 if (entity == self.entity) {
													 self.artworkImage.image = image ?: placeholder;
												 }
											 }];
}

#pragma mark - Static

+ (NSString *)reuseIdentifier
{
	return @"PASArtworkTVCell";
}

@end
