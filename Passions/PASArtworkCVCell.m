//
//  PASArtworkCVCell.m
//  Passions
//
//  Created by Simon Tännler on 04/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASArtworkCVCell.h"
#import "FICImageCache.h"
#import "PASColorPickerCache.h"

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
		[self _handleEntityKindSwitchFrom:_entity to:album];
		_entity = album;
		
		// clear the image to avoid seeing old images when scrolling
		// Albums are shown HALF width in Timeline
		self.artworkImage.image = [PASResources albumPlaceholderHalf];
		
		[self _loadThumbnailImageForEntity:album
							withFormatName:ImageFormatNameAlbumThumbnailMedium];
		
		self.releaseDateLabel.text = album.releaseDateFormatted;
	}
}

- (NSLayoutConstraint *)albumCn
{
	if (!_albumCn) {
		_albumCn = [NSLayoutConstraint constraintWithItem:self.artworkImage
												attribute:NSLayoutAttributeBottom
												relatedBy:NSLayoutRelationEqual
												   toItem:self.releaseDateLabel
												attribute:NSLayoutAttributeBottom
											   multiplier:1
												 constant:0];
	}
	return _albumCn;
}

- (void)showArtist:(PASArtist *)artist
{
	if (artist != _entity) {
		[self _handleEntityKindSwitchFrom:_entity to:artist];
		_entity = artist;
		
		// clear the image to avoid seeing old images when scrolling
		// Artists are shown FULL width in AritstInfo (Timeline Subclass)
		self.artworkImage.image = [PASResources artistPlaceholder];
		
		[self _loadThumbnailImageForEntity:artist
							withFormatName:ImageFormatNameArtistThumbnailLarge];
		
		self.releaseDateLabel.text = [artist availableAlbums];
	}
}

- (NSLayoutConstraint *)artistCn
{
	if (!_artistCn) {
		_artistCn = [NSLayoutConstraint constraintWithItem:self.artworkImage
												 attribute:NSLayoutAttributeBottom
												 relatedBy:NSLayoutRelationEqual
													toItem:self.releaseDateLabel
												 attribute:NSLayoutAttributeTop
												multiplier:1
												  constant:0];
	}
	return _artistCn;
}

- (void)_handleEntityKindSwitchFrom:(id<FICEntity>)oldEntity to:(id<FICEntity>)newEntity
{
	if ([oldEntity isKindOfClass:[newEntity class]]) {
		// layouts stay the same
		return;
	} else {
		if ([newEntity isKindOfClass:[PASAlbum class]]) {
			[self removeConstraint:self.artistCn];
			[self addConstraint:self.albumCn];
			
		} else {
			[self removeConstraint:self.albumCn];
			[self addConstraint:self.artistCn];
			
		}
	}
}

#pragma mark - Private Methods

- (void)_loadThumbnailImageForEntity:(id<FICEntity>)entity withFormatName:(NSString *)formatName
{
	// Cache the cache
	FICImageCache *cache = [FICImageCache sharedImageCache];
	self.releaseDateLabel.hidden = YES;
	
	[self.activityIndicator startAnimating];
	[cache asynchronouslyRetrieveImageForEntity:entity
								 withFormatName:formatName
								completionBlock:^(id<FICEntity> innerEntity, NSString *innerFormatName, UIImage *image) {
									[self.activityIndicator stopAnimating];
									// check if this image view hasn't been reused for a different entity
									if (image && innerEntity == self.entity) {
										self.artworkImage.image = image;
										
										PASColorPickerCache *pc = [PASColorPickerCache sharedMngr];
										[pc pickColorsFromImage:image
														withKey:[innerEntity UUID]
													 completion:^(LEColorScheme *colorScheme) {
														 if (innerEntity == self.entity && self.artworkImage.image == image) {
															 dispatch_async(dispatch_get_main_queue(), ^{
																 self.releaseDateLabel.backgroundColor = colorScheme.backgroundColor;
																 self.releaseDateLabel.textColor = colorScheme.preferredColorOverBackground;
																 self.releaseDateLabel.hidden = NO;
															 });
														 }
													 }];
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
