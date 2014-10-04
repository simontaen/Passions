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
	
	// Register cell classes
	[self.collectionView registerClass:[PASAlbumCVC class] forCellWithReuseIdentifier:CellIdentifier];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	//[PASResources printViewLayoutStack:self];
	//[PASResources printViewControllerLayoutStack:self];
	//[PASResources printGestureRecognizerStack:self];
	
	// TODO: PFUser subclass
	NSArray *favoriteArtistIds = (NSArray *)[[PFUser currentUser] objectForKey:@"favArtists"];
	
	// TODO: Album subclass
	PFQuery *albumQuery = [PFQuery queryWithClassName:@"Album"];
	[albumQuery whereKey:@"artistId" containedIn:favoriteArtistIds];
	
	[albumQuery findObjectsInBackgroundWithBlock:^(NSArray *albums, NSError *error) {
		
		NSLog(@"Found %lu albums", (unsigned long)albums.count);
		
		for (PFObject *album in albums) {
			NSLog(@"Name %@", [album objectForKey:@"name"]);
			NSLog(@"ReleaseDate %@", [album objectForKey:@"release_date"]);
		}
	}];	
}

#pragma mark - UICollectionViewDataSource required

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	// Return the number of items in the section
	return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	PASAlbumCVC *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
	
	// Configure the cell
	
	return cell;
}

@end
