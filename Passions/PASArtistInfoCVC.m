//
//  PASArtistInfoCVC.m
//  Passions
//
//  Created by Simon Tännler on 07/11/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASArtistInfoCVC.h"
#import "PASArtworkCVCell.h"
#import "PASPageViewController.h"

@implementation PASArtistInfoCVC

static NSInteger const kAddCells = 1;

#pragma mark - Init

- (void)commonInit
{
	// Configure Parse Query
	[super commonInit];
	self.loadingViewEnabled = NO;
	self.showSwipeHint = NO;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// register the custom cell
	[self.collectionView registerNib:[UINib nibWithNibName:[PASArtworkCVCell reuseIdentifier] bundle:nil] forCellWithReuseIdentifier:[PASArtworkCVCell reuseIdentifier]];
	
	// Configure navigationController
	self.title = self.artist.name;
	
	if ([self.artist iTunesUrl]) {
		UIBarButtonItem *rbbi = [[UIBarButtonItem alloc] initWithTitle:@"iTunes"
																 style:UIBarButtonItemStylePlain
																target:self
																action:@selector(iTunesButtonTapped:)];
		self.navigationItem.rightBarButtonItem = rbbi;
	}
}

- (void)helpViewWillAppear
{
	// Configure navigationController
	// Needs to be in viewWillAppear to make it work with other VC's
	self.navigationController.navigationBarHidden = NO;
	self.pageViewController.pageControlHidden = YES;
}

#pragma mark - CPFQueryCollectionViewController

- (PFQuery *)queryForCollection
{
	PFQuery *query = [super queryForCollection];
	[query whereKey:@"artistId" equalTo:self.artist.objectId];
	return query;
}

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 0) {
		return self.artist;
	} else {
		return [super objectAtIndexPath:[self _newIdxPath:indexPath]];
	}
}

#pragma mark - CPFQueryCollectionViewController required

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
	if (indexPath.row == 0) {
		PASArtist *artist = (PASArtist *)object;

		PASArtworkCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PASArtworkCVCell reuseIdentifier] forIndexPath:indexPath];
		
		[cell showArtist:artist];
		
		return cell;

	} else {
		return [super collectionView:collectionView cellForItemAtIndexPath:indexPath object:object];
	}
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return [super collectionView:collectionView numberOfItemsInSection:section] + kAddCells;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 0) {
		return CGSizeMake(self.collectionView.frame.size.width, self.collectionView.frame.size.width + 20);
	} else {
		return [super collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:[self _newIdxPath:indexPath]];
	}
}

#pragma mark - UICollectionViewDelegate (when the touch lifts)

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 0) {
		return NO;
	} else {
		return YES;
	}
}

#pragma mark - Redirecting to External Sites

- (IBAction)iTunesButtonTapped:(UIBarButtonItem *)sender
{
	NSURL *url = [self.artist iTunesAttributedUrl];
	[PFAnalytics trackEventInBackground:@"urlOpen"
							 dimensions:@{ @"provider" : @"iTunes",
										   @"url" : [url absoluteString] }
								  block:nil];
	[[UIApplication sharedApplication] openURL:url];
}

#pragma mark - Private Methods

- (NSIndexPath *)_newIdxPath:(NSIndexPath *)idxPath
{
	return [NSIndexPath indexPathForRow:idxPath.row - kAddCells inSection:idxPath.section];
}

@end
