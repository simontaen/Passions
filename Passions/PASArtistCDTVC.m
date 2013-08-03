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
#import "UIApplication+Utilities.h"

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
	self.clearsSelectionOnViewWillAppear = NO;
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
		// If we CREATED the document, we should do an automatic refresh
		// such that the user will see something
		//[self refresh];
		// if we OPENED the document, we already have data
		// and should jus display it
	}
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	NSIndexPath *indexPath = nil;
	
	if ([sender isKindOfClass:[UITableViewCell class]]) {
		indexPath = [self.tableView indexPathForCell:sender];
	}
	
	if (indexPath) {
		if ([segue.identifier isEqualToString:kSegueName]) {
			id obj = [self.fetchedResultsController objectAtIndexPath:indexPath];
			SEL segueSel = NSSelectorFromString(kSegueName);
			
			if ([segue.destinationViewController respondsToSelector:segueSel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
				[segue.destinationViewController performSelector:segueSel withObject:obj];
#pragma clang diagnostic pop
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
	
	dispatch_queue_t q = dispatch_queue_create("Last.fm artist load", 0);
	
	for (NSString *artist in [self sampleArtists]) {
		dispatch_async(q, ^{
			[[LastFmFetchr sharedManager] getInfoForArtist:artist
													  mbid:nil
												   success:^(LFMArtistGetInfo *data) {
													   // put the artists in CoreData
													   [self.managedObjectContext performBlock:^{
														   // needs to happen on the contexts "native" queue!
														   [Artist artistWithLFMArtistGetInfo:data inManagedObjectContext:self.managedObjectContext];
														   dispatch_async(dispatch_get_main_queue(), ^{
															   [self.refreshControl endRefreshing];
														   });
													   }];
												   }
												   failure:^(NSOperation *operation, NSError *error) {
													   NSLog(@"Error: %@", [[LastFmFetchr sharedManager] messageForError:error withOperation:operation]);
													   dispatch_async(dispatch_get_main_queue(), ^{
														   [self.refreshControl endRefreshing];
													   });
												   }];
		});
	} // for artist in sampleArtists
}

#pragma mark - UITableViewControllerDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"Artist";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
	
	// use id to make this method abstract
	Artist *artist = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.textLabel.text = [self titleForArtist:artist];
	[self detailTextForArtist:artist atCell:cell];
	[self imageForArtist:artist atCell:cell];
	
	return cell;
}

#pragma mark - UITableViewDataSource Helpers

- (NSString *)titleForArtist:(Artist *)artist
{
	return artist.name;
}

- (void)detailTextForArtist:(Artist *)artist atCell:(UITableViewCell *)cell
{
	// there are more efficient ways (countForFetchRequest:), but here it's good enough
	NSUInteger noOfAlbums = [artist.albums count];
	
	if (noOfAlbums) {
		cell.detailTextLabel.text = [self stringForNumberOfAlbums:noOfAlbums];
		
	} else {
		// no albums yet, need to fetch them
		cell.detailTextLabel.text = @"Loading...";
		
		dispatch_queue_t q = dispatch_queue_create("Last.fm album load", 0);
		dispatch_async(q, ^{
			[[LastFmFetchr sharedManager] getAllAlbumsByArtist:artist.name
														  mbid:nil
													   success:^(LFMArtistGetTopAlbums *data) {
														   // put the artists in CoreData
														   [self.managedObjectContext performBlock:^{
															   // needs to happen on the contexts "native" queue!
															   NSArray *albums = [Album albumsWithLFMArtistGetTopAlbums:data inManagedObjectContext:self.managedObjectContext];
															   dispatch_async(dispatch_get_main_queue(), ^{
																   cell.detailTextLabel.text = [self stringForNumberOfAlbums:[albums count]];
																   //[self.refreshControl endRefreshing];
															   });
														   }];
													   }
													   failure:^(NSOperation *operation, NSError *error) {
														   NSLog(@"Error: %@", [[LastFmFetchr sharedManager] messageForError:error withOperation:operation]);
														   dispatch_async(dispatch_get_main_queue(), ^{
															   cell.detailTextLabel.text = @"Error while loading.";
															   //[self.refreshControl endRefreshing];
														   });
													   }];
		});
	}
}

- (NSString *)stringForNumberOfAlbums:(NSUInteger)noOfAlbums
{
	if (noOfAlbums == 1) {
		return [NSString stringWithFormat:@"%d Album", noOfAlbums];
	} else {
		return [NSString stringWithFormat:@"%d Albums", noOfAlbums];
	}
}

- (void)imageForArtist:(Artist *)artist atCell:(UITableViewCell *)cell
{
	// This is cool but I need to cache the image data
	// [cell.imageView setImageWithURL:[NSURL URLWithString:artist.thumbnailURL]];
	
    NSData __block *thumbnailData = artist.thumbnail;
	
	if (!thumbnailData) {
		// set a default background image
		// TODO
		// need to fetch it first, do it on background
		dispatch_queue_t q = dispatch_queue_create("Thumbnail Fetcher", 0);
		dispatch_async(q, ^{
			NSURL *thumbnailURL = [NSURL URLWithString:artist.thumbnailURL];
			[[UIApplication sharedApplication] enableNetworkActivity];
			thumbnailData = [NSData dataWithContentsOfURL:thumbnailURL];
			[[UIApplication sharedApplication] disableNetworkActivity];
			
			//[artist.managedObjectContext performBlock:^{
            // set on the DB
            artist.thumbnail = thumbnailData;
			//}];
			
			// set on the tableview
			UIImage *image = [UIImage imageWithData:thumbnailData];
			dispatch_async(dispatch_get_main_queue(), ^{
				cell.imageView.image = image;
			});
		});
	} else {
		// data exists, set the image
		cell.imageView.image = [UIImage imageWithData:thumbnailData];
	}
}


#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
