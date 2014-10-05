//
//  PASTimelineCVC.m
//  Passions
//
//  Created by Simon Tännler on 07/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASTimelineCVC.h"
#import "PASAlbumCVC.h"
#import <Parse/Parse.h>
#import "PASArtist.h"
#import "PASAlbum.h"
#import "PASResources.h"

@interface PASTimelineCVC ()

@end

@implementation PASTimelineCVC

static NSString * const CellIdentifier = @"AlbumCell";

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Uncomment the following line to preserve selection between presentations
	// self.clearsSelectionOnViewWillAppear = NO;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	//[PASResources printViewLayoutStack:self];
	//[PASResources printViewControllerLayoutStack:self];
	//[PASResources printGestureRecognizerStack:self];
	
}

#pragma mark - CPFQueryCollectionViewController

- (PFQuery *)queryForCollection
{
	return [PASAlbum albumsOfCurrentUsersFavoriteArtists];
}


#pragma mark - CPFQueryCollectionViewController required

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
	PASAlbum *album = (PASAlbum *)object;
	PASAlbumCVC *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];

	// Configure the cell
	// TODO: request the image from the cache
	cell.imageView.image = [PASResources albumThumbnailPlaceholder];
	cell.releaseDateLabel.text = album.releaseDate;

	NSLog(@"%@ - %@", album.name, album.releaseDate);
	
	return cell;
}

@end
