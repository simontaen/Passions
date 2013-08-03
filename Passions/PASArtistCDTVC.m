//
//  PASArtistCDTVC.m
//  Passions
//
//  Created by Simon Tännler on 24/07/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import "PASArtistCDTVC.h"
#import "LastFmFetchr.h"
#import "Artist+LastFmFetchr.h"
#import "Album+LastFmFetchr.h"
#import "UIImageView+AFNetworking.h"

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
		[self useDocument];
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
		sampleArtists = @[@"The Beatles", @"Air", @"Pink Floyd"];
		
	});
	return sampleArtists;
}

- (IBAction)refresh
{
	[self.refreshControl beginRefreshing];
	
	dispatch_queue_t q = dispatch_queue_create("Last.fm artist load", 0);
	
	for (NSString *artist in [self sampleArtists]) {
		
		dispatch_async(q, ^{
			
			[[LastFmFetchr sharedManager] getInfoForArtist:artist mbid:nil success:^(LFMArtistGetInfo *data) {
				// put the artists in CoreData
				[self.managedObjectContext performBlock:^{
					// needs to happen on the contexts "native" queue!
					[Artist artistWithLFMArtistGetInfo:data inManagedObjectContext:self.managedObjectContext];
					dispatch_async(dispatch_get_main_queue(), ^{
						[self.refreshControl endRefreshing];
					});
				}];
				
			} failure:^(NSOperation *operation, NSError *error) {
				NSLog(@"Error: %@", [[LastFmFetchr sharedManager] messageForError:error withOperation:operation]);
				dispatch_async(dispatch_get_main_queue(), ^{
					[self.refreshControl endRefreshing];
				});
				
			}];
			
		});
	}
}

- (void)useDocument
{
	// This context is created by UIManagedDocument, MUST be on the main thread.
	
	NSURL *url = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Passions"];
	UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
	
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
		// create it
		[document saveToURL:url
		   forSaveOperation:UIDocumentSaveForCreating
		  completionHandler:^(BOOL success) {
			  if (success) {
				  self.managedObjectContext = document.managedObjectContext;
				  [self refresh];
				  // MOC created, inform all interested
			  }
		  }];
		
	} else if (document.documentState == UIDocumentStateClosed) {
		// open it
		[document openWithCompletionHandler:^(BOOL success) {
			if (success) {
				self.managedObjectContext = document.managedObjectContext;
				// MOC created, inform all interested
			};
		}];
		
	} else {
		NSLog(@"Document State %i", document.documentState);
		// try to use it (there migth be other more problematic states which are ignored here
		self.managedObjectContext = document.managedObjectContext;
	}
	NSLog(@"Using Document at %@", [url path]);
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - UITableViewControllerDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"Artist";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
	
	// use id to make this method abstract
	Artist *artist = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.textLabel.text = [self titleForArtist:artist];
	[self detailTextForArtist:artist atCell:(UITableViewCell *)cell];
	// This is cool but I wanted to cache the image data
	//[cell.imageView setImageWithURL:[NSURL URLWithString:artist.thumbnailURL]];
	
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
			[[LastFmFetchr sharedManager] getAllAlbumsByArtist:artist.name mbid:nil success:^(LFMArtistGetTopAlbums *data) {
				// put the artists in CoreData
				[self.managedObjectContext performBlock:^{
					// needs to happen on the contexts "native" queue!
					[Album albumsWithLFMArtistGetTopAlbums:data inManagedObjectContext:self.managedObjectContext];
					dispatch_async(dispatch_get_main_queue(), ^{
						cell.detailTextLabel.text = [self stringForNumberOfAlbums:noOfAlbums];
						[self.refreshControl endRefreshing];
					});
				}];
				
			} failure:^(NSOperation *operation, NSError *error) {
				NSLog(@"Error: %@", [[LastFmFetchr sharedManager] messageForError:error withOperation:operation]);
				dispatch_async(dispatch_get_main_queue(), ^{
					cell.detailTextLabel.text = @"Error while loading.";
					[self.refreshControl endRefreshing];
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

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
