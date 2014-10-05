//
//  PASAlbumCVCell.m
//  Passions
//
//  Created by Simon Tännler on 04/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASAlbumCVCell.h"
#import "FICImageCache.h"
#import "PASResources.h"

@implementation PASAlbumCVCell

#pragma mark - Accessors

-(void)setAlbum:(PASAlbum *)album
{
	if (album != _album) {
		_album = album;
		
		// clear the image to avoid seeing old images when scrolling
		self.albumImage.image = nil;
		
		[[FICImageCache sharedImageCache] retrieveImageForEntity:album
												  withFormatName:ImageFormatNameAlbumThumbnailMedium
												 completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
			// check if this cell hasn't been reused for a different album
			if (album == self.album) {
				if (image) {
					self.albumImage.image = image;
				} else {
					self.albumImage.image = [PASResources albumThumbnailPlaceholder];
				}
			}
		}];
		self.releaseDateLabel.text = album.releaseDate;
	}
}

#pragma mark - Static

+ (NSString *)reuseIdentifier {
	return @"AlbumCell";
}

@end
