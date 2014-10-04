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
	// TODO: PFUser subclass
	NSArray *favoriteArtistIds = (NSArray *)[[PFUser currentUser] objectForKey:@"favArtists"];
	
	// TODO: Album subclass
	PFQuery *albumQuery = [PFQuery queryWithClassName:@"Album"];
	[albumQuery whereKey:@"artistId" containedIn:favoriteArtistIds];
	
//	[albumQuery findObjectsInBackgroundWithBlock:^(NSArray *albums, NSError *error) {
//		
//		NSLog(@"Found %lu albums", (unsigned long)albums.count);
//		
//		for (PFObject *album in albums) {
//			NSLog(@"Name %@", [album objectForKey:@"name"]);
//			NSLog(@"ReleaseDate %@", [album objectForKey:@"release_date"]);
//		}
//	}];
	return albumQuery;
}


#pragma mark - CPFQueryCollectionViewController required

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
	PASAlbumCVC *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
	cell.imageView.image = [PASResources artistThumbnailPlaceholder];
	cell.releaseDateLabel.text = [object objectForKey:@"release_date"];
	NSLog(@"%@ - %@", [object objectForKey:@"name"], [object objectForKey:@"release_date"]);
	
	// Configure the cell
	
	return cell;
}

@end
