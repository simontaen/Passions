//
//  PASArtworkCVCell.m
//  Passions
//
//  Created by Simon Tännler on 04/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASArtworkCVCell.h"
#import "FICImageCache.h"
#import "SORelativeDateTransformer.h"

@interface PASArtworkCVCell()
@property (nonatomic, strong) id<FICEntity> entity;
@end

@implementation PASArtworkCVCell

#pragma mark - "Accessors"

- (void)showAlbum:(PASAlbum *)album
{
	if (album != _entity) {
		_entity = album;
		
		[self _loadThumbnailImageForEntity:album withFormatName:ImageFormatNameAlbumThumbnailMedium];
		
		self.releaseDateLabel.text = [[SORelativeDateTransformer registeredTransformer] transformedValue:album.releaseDate];
		self.releaseDateBackground.hidden = NO;
	}
}

- (void)showArtist:(PASArtist *)artist
{
	if (artist != _entity) {
		_entity = artist;
		
		[self _loadThumbnailImageForEntity:artist withFormatName:ImageFormatNameArtistThumbnailLarge];
		self.releaseDateBackground.hidden = YES;
	}
}

#pragma mark - Private Methods

- (void)_loadThumbnailImageForEntity:(id<FICEntity>)entity withFormatName:(NSString *)formatName
{
	// clear the image to avoid seeing old images when scrolling
	self.albumImage.image = nil;
	
	[[FICImageCache sharedImageCache] retrieveImageForEntity:entity
											  withFormatName:formatName
											 completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
												 if (entity == self.entity) {
													 self.albumImage.image = image ?: [PASResources albumThumbnailPlaceholder];
												 }
											 }];
}

#pragma mark - Static

+ (NSString *)reuseIdentifier
{
	return @"PASArtworkCVCell";
}

@end
