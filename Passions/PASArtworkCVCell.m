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
		
		// clear the image to avoid seeing old images when scrolling
		// Albums are shown HALF width in Timeline
		self.artworkImage.image = [PASResources albumPlaceholderHalf];

		[self _loadThumbnailImageForEntity:album
							withFormatName:ImageFormatNameAlbumThumbnailMedium];
		
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
		
		// clear the image to avoid seeing old images when scrolling
		// Artists are shown FULL width in AritstInfo (Timeline Subclass)
		self.artworkImage.image = [PASResources artistPlaceholder];
		
		[self _loadThumbnailImageForEntity:artist
							withFormatName:ImageFormatNameArtistThumbnailLarge];
		
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

- (void)_loadThumbnailImageForEntity:(id<FICEntity>)entity withFormatName:(NSString *)formatName
{
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
//		PASParseObjectWithImages *myDummy;
//		if ([entity isKindOfClass:[PASAlbum class]]) {
//			myDummy = [PASAlbum object];
//		} else {
//			myDummy = [PASArtist object];
//		}
//		
//		[cache asynchronouslyRetrieveImageForEntity:myDummy
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
	return @"PASArtworkCVCell";
}

@end
