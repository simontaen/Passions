//
//  PASAlbumsCDCollectionVC.m
//  Passions
//
//  Created by Simon Tännler on 10/11/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import "PASAlbumsCDCollectionVC.h"
#import "Album+LastFmFetchr.h"
#import "AFCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "LastFmFetchr.h"

@implementation PASAlbumsCDCollectionVC

#pragma mark - Accessors

- (void)setArtist:(Artist *)artist
{
	_artist = artist;
	self.title = artist.name;
	[self setupFetchedResultsController];
}

- (void)setupFetchedResultsController
{
	if (self.artist.managedObjectContext) {
		NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Album"];
		request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name"
																  ascending:YES
																   selector:@selector(compare:)]];
		request.predicate = [NSPredicate predicateWithFormat:@"artists contains %@", self.artist];
		
		self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
																			managedObjectContext:self.artist.managedObjectContext
																			  sectionNameKeyPath:nil
																					   cacheName:nil];
	} else {
		self.fetchedResultsController = nil;
	}
}

#pragma mark - View Lifecycle

-(void)viewDidLoad
{
    [super viewDidLoad];
	self.debug = YES;
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"AFCollectionViewCell";

    AFCollectionViewCell *cell = (AFCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
	// TODO this might be out of sync because of background loading, and therefor constant reordering of the TableView!
	Album *album = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	if (!album.thumbnail) {
		[[LastFmFetchr fetchr] getInfoForAlbum:album.name
									  byArtist:self.artist.name
										  mbid:nil
									completion:^(LFMAlbumInfo *data, NSError *error) {
										if (!error) {
											[album.managedObjectContext performBlock:^{
												// needs to happen on the contexts "native" queue!
												Album *updatedAlbum = [Album albumWithLFMAlbumInfo:data inManagedObjectContext:album.managedObjectContext];
												dispatch_async(dispatch_get_main_queue(), ^{
													[cell setImage:[UIImage imageWithData:updatedAlbum.thumbnail]];
												});
												
											}];
											
											
										} else {
											NSLog(@"Error: %@", [error localizedDescription]);
										}
									}];
	} else {
		[cell setImage:[UIImage imageWithData:album.thumbnail]];
	}
	
    
    return cell;
}

@end
