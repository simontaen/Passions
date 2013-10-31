//
//  PASArtistsAlbumsCDTVC.m
//  Passions
//
//  Created by Simon Tännler on 03/08/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import "PASArtistsAlbumsCDTVC.h"
#import "LastFmFetchr.h"
#import	"Album+LastFmFetchr.h"
#import "NSDate+Helper.h"
#import "UIImageView+AFNetworking.h"
//#import "AFImageRequestOperation.h"
//#import "UIApplication+Utilities.h"

@implementation PASArtistsAlbumsCDTVC

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
		request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"releaseDate"
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
	self.clearsSelectionOnViewWillAppear = NO;
	[self.refreshControl addTarget:self
							action:@selector(refresh)
				  forControlEvents:UIControlEventValueChanged];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	// TODO: This is overkill
	//[self refresh];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	NSIndexPath *indexPath = nil;
	
	if ([sender isKindOfClass:[UITableViewCell class]]) {
		indexPath = [self.tableView indexPathForCell:sender];
	}
	
	if (indexPath) {
		if ([segue.identifier isEqualToString:kSegueName]) {
			Album *album = [self.fetchedResultsController objectAtIndexPath:indexPath];
			NSURL *url = [NSURL URLWithString:album.imageURL];
			
			SEL segueSel = NSSelectorFromString(kSegueName);
			
			if ([segue.destinationViewController respondsToSelector:segueSel]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
				[segue.destinationViewController performSelector:segueSel withObject:url];
#pragma clang diagnostic pop
			}
		}
	}
}

#pragma mark - UITableViewControllerDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellIdentifier = @"Album";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
	
	// TODO this might be out of sync because of background loading, and therefor constant reordering of the TableView!
	Album *album = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.textLabel.text = album.name;
	[self detailTextForAlbum:album atCell:cell];
	[self thumbnailForAlbum:album atCell:cell];
	
	return cell;
}

#pragma mark - UITableViewDataSource Helpers

- (void)detailTextForAlbum:(Album *)album atCell:(UITableViewCell *)cell
{
	if (!album.releaseDate && [album.isLoading isEqual:@NO]) {
		// album has no releaseDate, try to fetch full info about album
		//cell.detailTextLabel.text = @"Loading...";
		album.isLoading = @YES;
		//NSLog(@"loading %@", album.name);
		[[LastFmFetchr fetchr] getInfoForAlbum:album.name
									  byArtist:self.artist.name
										  mbid:nil
									completion:^(LFMAlbumInfo *data, NSError *error) {
										if (!error) {
											[album.managedObjectContext performBlock:^{
												// needs to happen on the contexts "native" queue!
												Album *updatedAlbum = [Album albumWithLFMAlbumInfo:data inManagedObjectContext:album.managedObjectContext];
												dispatch_async(dispatch_get_main_queue(), ^{
													updatedAlbum.isLoading = @NO;
													//NSLog(@"ended %@", updatedAlbum.name);
													cell.detailTextLabel.text = [self formattedDateStringForAlbum:updatedAlbum];;
												});
											}];
											
											
										} else {
											NSLog(@"Error: %@", [error localizedDescription]);
											dispatch_async(dispatch_get_main_queue(), ^{
												album.isLoading = @NO;
												cell.detailTextLabel.text = [error localizedDescription];
											});
										}
									}];
	}
	cell.detailTextLabel.text = [self formattedDateStringForAlbum:album];
}

- (NSString *)formattedDateStringForAlbum:(Album *)album
{
	if ([album.isLoading isEqual:@YES]) {
		return @"Loading...";
	}
	NSString *date = [album.releaseDate stringWithFormat:[NSDate dateFormatString]];
	if (date) {
		return date;
	}
	// did already load + no releaseDate
	// must be unknown
	return @"unknown";
}

- (void)thumbnailForAlbum:(Album *)album atCell:(UITableViewCell *)cell
{
	// This is cool but I wanted to cache the image in CoreData
	// Apparently this uses a custom NSCache subclass to cache the image..
	//[cell.imageView setImageWithURL:[NSURL URLWithString:album.thumbnailURL] placeholderImage:[UIImage imageNamed:@"image.png"]];
	
}

#pragma mark - Document and data management

- (IBAction)refresh
{
	for (Album *album in self.artist.albums) {
		album.isLoading = @YES;
		[[LastFmFetchr fetchr] getInfoForAlbum:album.name
									  byArtist:self.artist.name
										  mbid:nil
									completion:^(LFMAlbumInfo *data, NSError *error) {
										if (!error) {
											[album.managedObjectContext performBlock:^{
												// needs to happen on the contexts "native" queue!
												Album *updatedAlbum = [Album albumWithLFMAlbumInfo:data inManagedObjectContext:album.managedObjectContext];
												dispatch_async(dispatch_get_main_queue(), ^{
													updatedAlbum.isLoading = @NO;
												});
											}];
											
											
										} else {
											NSLog(@"Error: %@", [error localizedDescription]);
											dispatch_async(dispatch_get_main_queue(), ^{
												album.isLoading = @NO;
											});
										}
									}];
	}
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
