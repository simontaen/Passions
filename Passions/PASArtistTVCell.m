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
#import "MPMediaItemCollection+SourceImage.h"

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
		self.detailText.text = [artist availableAlbums];
	}
}

#pragma mark - Other setters

- (void)showArtist:(id<PASSourceImage>)artist withName:(NSString *)name isFavorite:(BOOL)isFav playcount:(NSUInteger)playcount
{
	NSAssert([artist conformsToProtocol:@protocol(PASSourceImage)], @"%@ cannot handle artists of class %@, must conform to %@", NSStringFromClass([self class]), NSStringFromClass([artist class]), NSStringFromProtocol(@protocol(PASSourceImage)));
	
	if (artist != self.entity) {
		// only update cell if entity has actually changed
		self.entity = artist;
		
		[self _loadThumbnailImageForArtist:artist];
		self.starButton.hidden = NO;
		self.artistName.text = name;
		self.detailText.text = [self _stringForPlaycount:playcount];
	}
	
	// Update the button image
	UIImage *img = isFav ? [PASResources favoritedStar] : [PASResources outlinedStar];
	[self.starButton setImage:img forState:UIControlStateNormal];
	[self.starButton setImage:img forState:UIControlStateHighlighted];
	[self.starButton setImage:img forState:UIControlStateSelected];
	self.starButton.tintColor = [UIColor yellowColor];
}

#pragma mark - IBActions

- (IBAction)starTapped:(id)sender
{
	ROUTE(sender);
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
													 self.artistImage.image = image ?: [PASResources artistThumbnailPlaceholder];
												 }
											 }];
}

- (NSString *)_stringForPlaycount:(NSUInteger)playcount
{
	if (playcount == 1) {
		return [NSString stringWithFormat:@"%lu Play", (unsigned long)playcount];
	} else {
		return [NSString stringWithFormat:@"%lu Plays", (unsigned long)playcount];
	}
}

#pragma mark - Static

+ (NSString *)reuseIdentifier
{
	return @"PASArtistTVCell";
}

@end
