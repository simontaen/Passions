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

#pragma mark - Init

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (!self) return nil;
	self.paginationEnabled = YES;
	self.objectsPerPage = 500;
	return self;
}

#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self loadObjects];
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
	PASAlbumCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PASAlbumCVCell reuseIdentifier] forIndexPath:indexPath];
	
	cell.album = album;

	return cell;
}

#pragma mark - UIViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
	// TODO: ideally the status bar should be hidden
	// but it "snaps" back on the FavAritstsTVC, which is ugly
	// will have to check again when using a TabBarController
	// also the PageViewController probably needs updates too
	// this should be ok in the meantime
	return UIStatusBarStyleDefault;
}

@end
