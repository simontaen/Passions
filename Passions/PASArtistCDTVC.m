//
//  PASArtistCDTVC.m
//  Passions
//
//  Created by Simon Tännler on 24/07/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import "PASArtistCDTVC.h"
#import "LastFmFetchr.h"
#import "PASCDStack.h"
#import "Artist+LastFmFetchr.h"
#import "Album+LastFmFetchr.h"
#import "UIImageView+AFNetworking.h"

@interface PASArtistCDTVC ()
@property (atomic, strong) NSMutableDictionary *runningTasks; // of NSURLSessionDataTask
@end

@implementation PASArtistCDTVC

#pragma mark - Accessors

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
	_managedObjectContext = managedObjectContext;
	[self setupFetchedResultsController];
}

- (void)setupFetchedResultsController
{
	if (self.managedObjectContext) {
		NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Artist"];
		request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name"
																  ascending:YES
																   selector:@selector(localizedCaseInsensitiveCompare:)]];
		request.predicate = nil; // usually you'll want all
		
		self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
																			managedObjectContext:self.managedObjectContext
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
	self.title = @"Artists";
	self.runningTasks = [NSMutableDictionary dictionary];
	[self.refreshControl addTarget:self
							action:@selector(refresh)
				  forControlEvents:UIControlEventValueChanged];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	if (!self.managedObjectContext) {
		// Create the context
		self.managedObjectContext = [[PASCDStack sharedInstance] mainThreadManagedObjectContext];
		// TODO
		// If we CREATED the document, we should do an automatic refresh
		// such that the user will see something
		//[self refresh];
		// if we OPENED the document, we already have data
		// and should just display it
	}
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	NSIndexPath *indexPath = nil;
	
	if ([sender isKindOfClass:[UITableViewCell class]]) {
		indexPath = [self.tableView indexPathForCell:sender];
	}
	
	if (indexPath) {
		if ([segue.identifier isEqualToString:@"setArtist:"]) {
			Artist *artist = [self.fetchedResultsController objectAtIndexPath:indexPath];
			
			if ([segue.destinationViewController respondsToSelector:@selector(setArtist:)]) {
				[segue.destinationViewController performSelector:@selector(setArtist:) withObject:artist];
			}
		}
	}
}

#pragma mark - Document and data management

- (NSArray *)sampleArtists
{
	static NSArray *sampleArtists;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		/*
		 sampleArtists = @[
		 @"The Beatles", @"Air", @"Pink Floyd", @"Rammstein", @"Bloodhound Gang",
		 @"Ancien Régime", @"Genius/GZA ", @"Belle & Sebastian", @"Björk",
		 @"Ugress", @"ADELE", @"The Asteroids Galaxy Tour", @"Bar 9",
		 @"Baskerville", @"Beastie Boys", @"Bee Gees", @"Bit Shifter",
		 @"Bomfunk MC's", @"C-Mon & Kypski", @"The Cardigans", @"Carly Commando",
		 @"Caro Emerald", @"Coldplay", @"Coolio", @"Cypress Hill",
		 @"David Bowie", @"Deadmau5", @"Dukes of Stratosphear", @"[dunkelbunt]",
		 @"Eminem", @"Enigma",
		 ];
		 */
		sampleArtists = @[@"The Beatles", @"AC/DC", @"Pink Floyd"];
		
	});
	return sampleArtists;
}

- (IBAction)refresh
{
	[self.refreshControl beginRefreshing];
	
	for (NSString *artistName in [self sampleArtists]) {
		
		[[LastFmFetchr fetchr] getAllAlbumsByArtist:artistName
											   mbid:nil
										 completion:^(LFMArtistsTopAlbums *data, NSError *error) {
											 if (!error) {
												 [self.managedObjectContext performBlock:^{
													 [Album albumsWithLFMArtistsTopAlbums:data inManagedObjectContext:self.managedObjectContext];
												 }];
												 
											 } else {
												 NSLog(@"Error: %@", [error localizedDescription]);
											 }
											 dispatch_async(dispatch_get_main_queue(), ^{
												 // TODO: stops with first returning call, not gut
												 [self.refreshControl endRefreshing];
											 });
										 }];
	} // for artist in sampleArtists
}

#pragma mark - UITableViewControllerDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"Artist";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
	
	// use id to make this method abstract
	Artist *artist = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.textLabel.text = artist.name;
	[self detailTextForArtist:artist atCell:cell];
	//[self thumbnailForArtist:artist atCell:cell];
	
	return cell;
}

#pragma mark - UITableViewDataSource Helpers

- (void)detailTextForArtist:(Artist *)artist atCell:(UITableViewCell *)cell
{
	// there are more efficient ways (countForFetchRequest:), but here it's good enough
	cell.detailTextLabel.text = [self stringForNumberOfAlbums:[artist.albums count]];
}

- (NSString *)stringForNumberOfAlbums:(NSUInteger)noOfAlbums
{
	if (noOfAlbums == 1) {
		return [NSString stringWithFormat:@"%d Album", noOfAlbums];
	} else {
		return [NSString stringWithFormat:@"%d Albums", noOfAlbums];
	}
}

- (void)thumbnailForArtist:(Artist *)artist atCell:(UITableViewCell *)cell
{
	// This is cool but I wanted to cache the image in CoreData
	// Apparently this uses a custome NSCache subclass to cache the image..
	[cell.imageView setImageWithURL:[NSURL URLWithString:artist.thumbnailURL]
				   placeholderImage:[UIImage imageNamed:@"image.png"]];
	
	/*
	 NSData __block *thumbnailData = artist.thumbnail;
	 
	 // TODO: set a "empty" image
	 dispatch_queue_t q = dispatch_queue_create("Thumbnail Fetcher", 0);
	 dispatch_async(q, ^{
	 if (!thumbnailData) {
	 // need to fetch it first
	 NSURL *thumbnailURL = [NSURL URLWithString:artist.thumbnailURL];
	 [[UIApplication sharedApplication] enableNetworkActivity];
	 thumbnailData = [NSData dataWithContentsOfURL:thumbnailURL];
	 [[UIApplication sharedApplication] disableNetworkActivity];
	 
	 //[artist.managedObjectContext performBlock:^{
	 // set on the DB
	 artist.thumbnail = thumbnailData;
	 //}];
	 }
	 
	 // data exists, set the image
	 UIImage *image = [UIImage imageWithData:thumbnailData];
	 artist.thumbnail = image;
	 dispatch_async(dispatch_get_main_queue(), ^{
	 cell.imageView.image = image;
	 });
	 });
	 */
}

@end
