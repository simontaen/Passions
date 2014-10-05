//
//  PASTimelineCVC.m
//  Passions
//
//  Created by Simon Tännler on 07/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASTimelineCVC.h"
#import "PASAlbumCVCell.h"
#import "PASAlbum.h"

@interface PASTimelineCVC ()

@end

@implementation PASTimelineCVC

#pragma mark - CPFQueryCollectionViewController

- (PFQuery *)queryForCollection
{
	return [PASAlbum albumsOfCurrentUsersFavoriteArtists];
}

#pragma mark - CPFQueryCollectionViewController required

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
	PASAlbum *album = (PASAlbum *)object;
	PASAlbumCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PASAlbumCVCell reuseIdentifier] forIndexPath:indexPath];
	
	cell.album = album;

	NSLog(@"%@ - %@", album.name, album.releaseDate);
	
	return cell;
}

@end
