//
//  PASTimelineCVC.m
//  Passions
//
//  Created by Simon Tännler on 07/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASTimelineCVC.h"
#import "PASAlbumCVCell.h"
#import "PASArtistInfo.h"
#import "PASAlbum.h"

@interface PASTimelineCVC ()

@end

@implementation PASTimelineCVC

#pragma mark - Init

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (!self) return nil;
	
	// Configure Parse Query
	self.paginationEnabled = YES;
	self.objectsPerPage = 500;
	self.loadingViewEnabled = NO;
	
	// register to get notified when an album should be shown
	[[NSNotificationCenter defaultCenter] addObserverForName:kPASShowAlbumDetails
													  object:nil queue:nil
												  usingBlock:^(NSNotification *note) {
													  id obj = note.userInfo[kPASShowAlbumDetails];
													  NSAssert([obj isKindOfClass:[PASAlbum class]], @"kPASShowAlbumDetails must carry a PASAlbum");
													  [self _showAlbum:obj animated:NO];
												  }];
	return self;
}

#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// Configure navigationController
	self.navigationController.navigationBarHidden = YES;

	if (!self.isLoading) {
		self.isRefreshing = YES;
		[self loadObjects];
	}
}

#pragma mark - CPFQueryCollectionViewController

- (PASAlbum *)_albumAtIndexPath:(NSIndexPath *)indexPath
{
	return (PASAlbum *)[self objectAtIndexPath:indexPath];
}

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

#pragma mark - Navigation

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[self _showAlbum:[self _albumAtIndexPath:indexPath] animated:YES];
}

- (void)_showAlbum:(PASAlbum *)album animated:(BOOL)animated
{
	PASArtistInfo *vc = (PASArtistInfo *)[self.storyboard instantiateViewControllerWithIdentifier:@"PASArtistInfo"];
	vc.album = album;
	
	[self.navigationController pushViewController:vc animated:animated];
}

@end
