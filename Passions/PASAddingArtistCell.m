//
//  PASAddingArtistCell.m
//  Passions
//
//  Created by Simon Tännler on 09/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASAddingArtistCell.h"
#import "FICImageCache.h"

@implementation PASAddingArtistCell

#pragma mark - Accessors

-(void)setArtist:(PASArtist *)artist
{
	if (artist != _artist) {
		_artist = artist;
		
		// clear the image to avoid seeing old images when scrolling
		self.artistImage.image = nil;
		
		[[FICImageCache sharedImageCache] retrieveImageForEntity:artist
												  withFormatName:ImageFormatNameArtistThumbnailSmall
												 completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
													 // check if this cell hasn't been reused for a different artist
													 if (artist == self.artist) {
														 if (image) {
															 self.artistImage.image = image;
														 } else {
															 self.artistImage.image = [PASResources artistThumbnailPlaceholder];
														 }
													 }
												 }];
		self.artistName.text = artist.name;
		self.detailText.text = [self _stringForNumberOfAlbums:artist.totalAlbums];
	}
}

- (NSString *)_stringForNumberOfAlbums:(NSNumber *)noOfAlbums
{
	if (!noOfAlbums) {
		return @"Processing...";
	} else if (noOfAlbums.longValue == 1) {
		return [NSString stringWithFormat:@"%lu Album", noOfAlbums.longValue];
	} else {
		return [NSString stringWithFormat:@"%lu Albums", noOfAlbums.longValue];
	}
}

#pragma mark - Static

+ (NSString *)reuseIdentifier {
	return @"PASAddingArtistCell";
}

@end
