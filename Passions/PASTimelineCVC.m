//
//  PASTimelineCVC.m
//  Passions
//
//  Created by Simon Tännler on 07/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASTimelineCVC.h"
#import "PASArtworkCVCell.h"
#import "PASAlbumInfoTVC.h"
#import "PASAlbum.h"

@interface PASTimelineCVC ()
@property (strong, nonatomic) UIVisualEffectView *effectView;
@property (nonatomic, weak) IBOutlet UIButton *swipeLeftHint;
@end

@implementation PASTimelineCVC

#pragma mark - Init

- (instancetype)init
{
	self = [super initWithCollectionViewLayout:[UICollectionViewFlowLayout new]];
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
	// register to get notified if fav artists have been edited
	[[NSNotificationCenter defaultCenter] addObserverForName:kPASDidEditFavArtists
													  object:nil queue:nil
												  usingBlock:^(NSNotification *note) {
													  // get didEditArtists from the notification
													  id obj = note.userInfo[kPASDidEditFavArtists];
													  NSAssert([obj isKindOfClass:[NSNumber class]], @"kPASDidEditFavArtists must carry a NSNumber");
													  BOOL didEditArtists = [((NSNumber *)obj) boolValue];
													  if (didEditArtists && !self.isLoading) {
														  [self _refreshUI];
													  }
												  }];
	return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
	
	// register the custom cell
	[self.collectionView registerNib:[UINib nibWithNibName:[PASArtworkCVCell reuseIdentifier] bundle:nil]
		  forCellWithReuseIdentifier:[PASArtworkCVCell reuseIdentifier]];
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	
	// Configure contentInset and Effect View
	self.collectionView.contentInset = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, 0, 0);
	self.effectView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.topLayoutGuide.length);
	[self.view addSubview:self.effectView];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// Configure navigationController
	// Needs to be in viewWillAppear since the Info VC's unhide the navigationBarHidden
	self.navigationController.navigationBarHidden = YES;
}

#pragma mark - CPFQueryCollectionViewController

- (PASAlbum *)_albumAtIndexPath:(NSIndexPath *)indexPath
{
	return (PASAlbum *)[self objectAtIndexPath:indexPath];
}

- (PFQuery *)queryForCollection
{
	if ([PFUser currentUser].objectId) {
		return [PASAlbum albumsOfCurrentUsersFavoriteArtists];
	}
	NSLog(@"CurrentUser not ready for Timeline");
	return nil; // shows loading spinner
}

- (void)objectsDidLoad:(NSError *)error
{
	[super objectsDidLoad:error];
	if (self.objects.count == 0 && !self.swipeLeftHint) {
		UIImage *img = [PASResources swipeLeft];
		CGFloat imgWidth = img.size.width;
		CGFloat imgHeight = img.size.height;
		
		CGRect myFrame = CGRectMake(self.view.frame.size.width / 2 - imgWidth / 1.75, self.view.frame.size.height / 2 - imgHeight / 2, imgWidth, imgHeight);
		UIButton *btn = [[UIButton alloc] initWithFrame:myFrame];
		self.swipeLeftHint = btn;

		[btn setImage:img forState:UIControlStateNormal];
		btn.tintColor = [UIColor whiteColor];
		btn.userInteractionEnabled = NO;
		
		[self.view addSubview:btn];
		
	} else if (self.objects.count > 0 && self.swipeLeftHint) {
		[self.swipeLeftHint removeFromSuperview];
		self.swipeLeftHint = nil;
	}
}

#pragma mark - CPFQueryCollectionViewController required

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
	PASAlbum *album = (PASAlbum *)object;
	PASArtworkCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[PASArtworkCVCell reuseIdentifier] forIndexPath:indexPath];
	
	[cell showAlbum:album];

	return cell;
}

#pragma mark - UIViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleDefault;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
	return CGSizeMake(self.collectionView.frame.size.width / 2, self.collectionView.frame.size.width / 2);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
	return UIEdgeInsetsZero;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
	return 0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
	return 0;
}

#pragma mark - UICollectionViewDelegate / Navigation

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[self _showAlbum:[self _albumAtIndexPath:indexPath] animated:YES];
}

- (void)_showAlbum:(PASAlbum *)album animated:(BOOL)animated
{
	PASAlbumInfoTVC *vc = [PASAlbumInfoTVC new];
	vc.album = album;
	
	// TODO: Hide the pageControl
	[self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Private Methods

- (void)_refreshUI
{
	self.isRefreshing = YES;
	[self loadObjects];
}

@end
