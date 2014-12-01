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
		
		[self _loadThumbnailImageForEntity:album
							withFormatName:ImageFormatNameAlbumThumbnailLarge];
	}
}

#pragma mark - Private Methods

- (void)_loadThumbnailImageForEntity:(id<FICEntity>)entity withFormatName:(NSString *)formatName
{
	// clear the image to avoid seeing old images when scrolling
	// This is the AlbumInfo TVC use FULL width
	self.artworkImage.image = [PASResources albumPlaceholder];
	
	// Cache the cache
	FICImageCache *cache = [FICImageCache sharedImageCache];
	
	[cache asynchronouslyRetrieveImageForEntity:entity
								 withFormatName:formatName
								completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
									// check if this image view hasn't been reused for a different entity
									if (image && entity == self.entity) {
										self.artworkImage.image = image;
									}
								}];
//	if (!cacheAvailable) {
//		[cache asynchronouslyRetrieveImageForEntity:[PASAlbum object]
//									 withFormatName:formatName
//									completionBlock:^(id<FICEntity> dummy, NSString *formatName, UIImage *image) {
//										// check if this image view hasn't been reused for a different entity
//										// and if the image is still unset
//										if (image && entity == self.entity && self.artworkImage.image == nil) {
//											self.artworkImage.image = image;
//										}
//									}];
//	}
}

#pragma mark - Static

+ (NSString *)reuseIdentifier
{
	return @"PASArtworkTVCell";
}

@end
