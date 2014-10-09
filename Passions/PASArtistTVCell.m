//
//  PASArtistTVCell.m
//  Passions
//
//  Created by Simon Tännler on 09/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASArtistTVCell.h"
#import "FICImageCache.h"
// technically the imports don't need to happen, as the runtime attaches them to each instance
// but I still like to do them for clarity
#import "NSString+SourceImage.h"
#import "MPMediaItem+SourceImage.h"

@interface PASArtistTVCell()
@property (nonatomic, strong) id<FICEntity> entity;
@end

@implementation PASArtistTVCell

#pragma mark - Accessors

- (void)showArtist:(PASArtist *)artist
{
	if (artist != self.entity) {
		self.entity = artist;
		
		[self _loadThumbnailImageForArtist:artist];
		self.artistName.text = artist.name;
		self.detailText.text = [self _stringForNumberOfAlbums:artist.totalAlbums];
	}
}

#pragma mark - Other setters

- (void)showArtist:(id<PASSourceImage>)artist withName:(NSString *)name isFavorite:(BOOL)isFav
{
	NSAssert([artist conformsToProtocol:@protocol(PASSourceImage)], @"%@ cannot handle artists of class %@, must conform to %@", NSStringFromClass([self class]), NSStringFromClass([artist class]), NSStringFromProtocol(@protocol(PASSourceImage)));
	
	if (artist != self.entity) {
		// only update cell if entity has actually changed
		self.entity = artist;
		
		[self _loadThumbnailImageForArtist:artist];
		self.artistName.text = name;
	}
	
	// the artist could have been unfavorited, updated this in every case
	self.detailText.text = isFav ? @"Favorite!" : @"";
}


#pragma mark - Private Methods

- (void)_loadThumbnailImageForArtist:(id<FICEntity>)artist
{
	// clear the image to avoid seeing old images when scrolling
	self.artistImage.image = nil;
	
	[[FICImageCache sharedImageCache] retrieveImageForEntity:artist
											  withFormatName:ImageFormatNameArtistThumbnailSmall
											 completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
												 // check if this cell hasn't been reused for a different artist
												 if (artist == self.entity) {
													 if (image) {
														 self.artistImage.image = image;
													 } else {
														 self.artistImage.image = [PASResources artistThumbnailPlaceholder];
													 }
												 }
											 }];
}

- (NSString *)_stringForNumberOfAlbums:(NSNumber *)noOfAlbums
{
	if (!noOfAlbums) {
		return @"Processing...";
	} else if (noOfAlbums.longValue == 1) {
		return [NSString stringWithFormat:@"%lu Album available", noOfAlbums.longValue];
	} else {
		return [NSString stringWithFormat:@"%lu Albums available", noOfAlbums.longValue];
	}
}

#pragma mark - Static

+ (NSString *)reuseIdentifier
{
	return @"PASArtistTVCell";
}

@end
