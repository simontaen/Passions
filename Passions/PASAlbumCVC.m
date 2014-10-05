//
//  PASAlbumCVC.m
//  Passions
//
//  Created by Simon Tännler on 04/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASAlbumCVC.h"
#import "FICImageCache.h"
#import "PASResources.h"

@implementation PASAlbumCVC

#pragma mark - Accessors

-(void)setAlbum:(PASAlbum *)album
{
	if (album != _album) {
		_album = album;
		
		[[FICImageCache sharedImageCache] retrieveImageForEntity:album
												  withFormatName:ImageFormatNameAlbumThumbnailMedium
												 completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
			// check if this cell hasn't been reused for a different album
			if (album == self.album) {
				if (image) {
					self.imageView.image = image;
				} else {
					self.imageView.image = [PASResources albumThumbnailPlaceholder];
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
