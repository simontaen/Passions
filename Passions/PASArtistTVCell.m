//
//  PASArtistTVCell.m
//  Passions
//
//  Created by Simon Tännler on 09/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASArtistTVCell.h"
#import "FICImageCache.h"
#import "UIColor+Utils.h"
#import "PASManageArtists.h"
// technically the imports don't need to happen, as the runtime attaches them to each instance
// but I still like to do them for clarity
#import "NSString+SourceImage.h"
#import "MPMediaItemCollection+SourceImage.h"
#import "SPTArtist+FICEntity.h"

@interface PASArtistTVCell()
@property (nonatomic, strong) id<FICEntity> entity;
@end

@implementation PASArtistTVCell

#pragma mark - Accessors

- (void)showArtist:(id<FICEntity>)artist withName:(NSString *)name andDetailTextBlock:(NSString * (^)(id<FICEntity> artist, NSString *name))block
{
	NSAssert([artist conformsToProtocol:@protocol(FICEntity)], @"%@ cannot handle artists of class %@, must conform to %@", NSStringFromClass([self class]), NSStringFromClass([artist class]), NSStringFromProtocol(@protocol(FICEntity)));
	
	if (artist != self.entity) {
		// only update cell if entity has actually changed
		self.entity = artist;
		
		[self _loadThumbnailImageForArtist:artist];
		self.artistName.text = name;
		
		if ([artist isKindOfClass:[PASArtist class]]) {
			self.detailText.text = [(PASArtist *)artist availableAlbums];
			
		} else {
			self.starButton.hidden = NO;
			self.detailText.text = block ? block(artist, name) : @"";
		}
	}
	
	if (![artist isKindOfClass:[PASArtist class]]) {
		// Update the star button image as isFav could have changed externally
		BOOL isFav = [[PASManageArtists sharedMngr] isFavoriteArtist:name];
		UIImage *img = isFav ? [PASResources favoritedStar] : [PASResources outlinedStar];
		[self.starButton setImage:img forState:UIControlStateNormal];
		[self.starButton setImage:img forState:UIControlStateHighlighted];
		[self.starButton setImage:img forState:UIControlStateSelected];
		self.starButton.tintColor = [UIColor starTintColor];
	}
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

#pragma mark - Static

+ (NSString *)reuseIdentifier
{
	return @"PASArtistTVCell";
}

@end
