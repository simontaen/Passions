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
@property (nonatomic, strong) NSLayoutConstraint *artistCn;
@property (nonatomic, strong) NSLayoutConstraint *albumCn;
@end

@implementation PASArtworkCVCell

#pragma mark - "Accessors"

- (void)showAlbum:(PASAlbum *)album
{
	if (album != _entity) {
		_entity = album;
		
		[self _loadThumbnailImageForEntity:album
							withFormatName:ImageFormatNameAlbumThumbnailMedium
							   placeholder:[PASResources albumThumbnailPlaceholder]];
		
		self.releaseDateLabel.text = [[SORelativeDateTransformer registeredTransformer] transformedValue:album.releaseDate];
		
		[self removeConstraint:self.artistCn];
		[self addConstraint:self.albumCn];
								  
		//self.releaseDateBackground.hidden = NO;
	}
}

- (NSLayoutConstraint *)albumCn
{
	if (!_albumCn) {
		_albumCn = [NSLayoutConstraint constraintWithItem:self.artworkImage
												attribute:NSLayoutAttributeBottom
												relatedBy:NSLayoutRelationEqual
												   toItem:self.releaseDateBackground
												attribute:NSLayoutAttributeBottom
											   multiplier:1
												 constant:0];
	}
	return _albumCn;
}

- (void)showArtist:(PASArtist *)artist
{
	if (artist != _entity) {
		_entity = artist;
		
		[self _loadThumbnailImageForEntity:artist
							withFormatName:ImageFormatNameArtistThumbnailLarge
							   placeholder:[PASResources artistThumbnailPlaceholder]];
		
		self.releaseDateLabel.text = [artist availableAlbums];
		
		[self removeConstraint:self.albumCn];
		[self addConstraint:self.artistCn];
		
		//self.releaseDateBackground.hidden = YES;
	}
}

- (NSLayoutConstraint *)artistCn
{
	if (!_artistCn) {
		_artistCn = [NSLayoutConstraint constraintWithItem:self.artworkImage
												 attribute:NSLayoutAttributeBottom
												 relatedBy:NSLayoutRelationEqual
													toItem:self.releaseDateBackground
												 attribute:NSLayoutAttributeTop
												multiplier:1
												  constant:0];
	}
	return _artistCn;
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
	return @"PASArtworkCVCell";
}

@end
