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
@property (nonatomic, strong) id observer; // the NSNotificationCenter observer token
@end

@implementation PASArtistTVCell

#pragma mark - Accessors

- (void)showArtist:(id<FICEntity>)artist withName:(NSString *)name andDetailTextBlock:(NSString * (^)(id<FICEntity> artist, NSString *name))block
{
	NSAssert([artist conformsToProtocol:@protocol(FICEntity)], @"%@ cannot handle artists of class %@, must conform to %@", NSStringFromClass([PASArtistTVCell class]), NSStringFromClass([artist class]), NSStringFromProtocol(@protocol(FICEntity)));
	
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
		[self _updateStarButton];
		
		if (!self.observer) {
			// Register for single Artist updates when faving
			self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:kPASDidEditArtistWithName
																			  object:nil queue:nil usingBlock:^(NSNotification *note) {
																				  id obj = note.userInfo[kPASDidEditArtistWithName];
																				  NSAssert([obj isKindOfClass:[NSString class]], @"kPASDidEditArtistWithName must carry a NSString");
																				  NSString *artistName = (NSString *)obj;
																				  
																				  dispatch_async(dispatch_get_main_queue(), ^{
																					  if ([artistName isEqualToString:self.artistName.text]) {
																						  [self _updateStarButton];
																					  }
																				  });
																			  }];
		}
	}
	
}

#pragma mark - IBActions

- (IBAction)starTapped:(id)sender
{
	ROUTE(sender);
}

#pragma mark - Private Methods

- (void)_updateStarButton
{
	BOOL isFav = [[PASManageArtists sharedMngr] isFavoriteArtist:self.artistName.text];
	UIImage *img = isFav ? [PASResources favoritedStar] : [PASResources outlinedStar];
	[self.starButton setImage:img forState:UIControlStateNormal];
	[self.starButton setImage:img forState:UIControlStateHighlighted];
	[self.starButton setImage:img forState:UIControlStateSelected];
	self.starButton.tintColor = [UIColor starTintColor];
}

- (void)_loadThumbnailImageForArtist:(id<FICEntity>)entity
{
	// clear the image to avoid seeing old images when scrolling
	self.artistImage.image = nil;
	
	// Cache the cache
	FICImageCache *cache = [FICImageCache sharedImageCache];
	
	BOOL cacheAvailable = [cache asynchronouslyRetrieveImageForEntity:entity
													   withFormatName:ImageFormatNameArtistThumbnailSmall
													  completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
														  // check if this image view hasn't been reused for a different entity
														  if (image && entity == self.entity) {
															  self.artistImage.image = image;
														  }
													  }];
	if (!cacheAvailable) {
		[cache asynchronouslyRetrieveImageForEntity:[PASArtist object]
									 withFormatName:ImageFormatNameArtistThumbnailSmall
									completionBlock:^(id<FICEntity> dummy, NSString *formatName, UIImage *image) {
										// check if this image view hasn't been reused for a different entity
										// and if the image is still unset
										if (image && entity == self.entity && self.artistImage.image == nil) {
											self.artistImage.image = image;
										}
									}];
	}
}

#pragma mark - Static

+ (NSString *)reuseIdentifier
{
	return @"PASArtistTVCell";
}

@end
