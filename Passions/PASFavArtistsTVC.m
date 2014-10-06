//
//  PASFavArtistsTVC.m
//  Passions
//
//  Created by Simon Tännler on 03/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASFavArtistsTVC.h"
#import "PASAddingArtistCell.h"
#import "PASArtist.h"
#import "PASAddArtistsNC.h"
#import "FICImageCache.h"

@interface PASFavArtistsTVC() <PASAddArtistsTVCDelegate>

@end

@implementation PASFavArtistsTVC

#pragma mark - Init

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (!self) return nil;
	self.parseClassName = [PASArtist parseClassName];
	self.title = @"Favorite Artists";
	self.pullToRefreshEnabled = YES;
	self.paginationEnabled = YES;
	self.objectsPerPage = 20;
	return self;
}

#pragma mark - Accessors

// goes to add artists, needs to know about current favorites
- (NSArray *)artistNames
{
	NSMutableArray *artistNames = [[NSMutableArray alloc] initWithCapacity:self.objects.count];
	for (PASArtist *artist in self.objects) {
		[artistNames addObject:artist.name];
	}
	return artistNames;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.edgesForExtendedLayout = UIRectEdgeLeft|UIRectEdgeBottom|UIRectEdgeRight;
	[self.tableView registerNib:[UINib nibWithNibName:[PASAddingArtistCell reuseIdentifier] bundle:nil] forCellReuseIdentifier:[PASAddingArtistCell reuseIdentifier]];
	
	// DEBUG
	//self.view.backgroundColor = [UIColor greenColor];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	//[PASResources printViewControllerLayoutStack:self];
}

- (IBAction)resetFastimageCache:(UIBarButtonItem *)sender
{
	// TODO: DEBUG only
	[[FICImageCache sharedImageCache] reset];
	[self _refreshUI];
}

#pragma mark - UITableViewDataSource Editing

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	// I can't remove the Artist from self.objects manually, need to reload, but seems to slow for the animation.
	[tableView beginUpdates];
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		PASArtist *artist = [self _artistAtIndexPath:indexPath];
		
		// De-favorite the user from the artist and reload the table view
		[PASArtist removeCurrentUserFromArtist:artist withBlock:^(BOOL succeeded, NSError *error) {
			if (succeeded) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[self loadObjects];
				});
			}
		}];
		
	} else if (editingStyle == UITableViewCellEditingStyleInsert) {
		// Create a new instance of the appropriate class, and save it to Parse
	}
	[tableView endUpdates];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 50;
}

#pragma mark - PFQueryTableViewController

- (PASArtist *)_artistAtIndexPath:(NSIndexPath *)indexPath
{
	return (PASArtist *)[self objectAtIndexPath:indexPath];
}

// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.
- (PFQuery *)queryForTable
{
	//	PFUser *user = [PFUser currentUser];
	//	NSLog(@"isDataAvailable = %@", ([user isDataAvailable] ? @"YES" : @"NO"));
	//	NSLog(@"isDirty = %@", ([user isDirty] ? @"YES" : @"NO"));
	//	NSLog(@"isNew = %@", ([user isNew] ? @"YES" : @"NO"));
	//	NSLog(@"isDirtyForKey = %@", ([user isDirtyForKey:@"objectId"] ? @"YES" : @"NO"));
	
	if ([[PFUser currentUser] isDirty]) {
		// TODO: this is where we create the user, make sure you set an ACL
		// this must be a new user
		// create the assosiation for push notifications
		PFInstallation *currentInstallation = [PFInstallation currentInstallation];
		[currentInstallation save];
		[[PFUser currentUser] setObject:currentInstallation.objectId forKey:@"installation"];
		// save it or else the query will crash
		[[PFUser currentUser] save];
	}
	
	PFQuery *query = [PASArtist favArtistsForCurrentUser];
	
	// If no objects are loaded in memory, we look to the cache first to fill the table
	// and then subsequently do a query against the network.
	if (self.objects.count == 0) {
		query.cachePolicy = kPFCachePolicyCacheThenNetwork;
	}
	
	return query;
}

// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
	PASArtist *artist = (PASArtist *)object;
	PASAddingArtistCell *cell = [tableView dequeueReusableCellWithIdentifier:[PASAddingArtistCell reuseIdentifier] forIndexPath:indexPath];
	
	[cell showArtist:artist];
	
	return cell;
}

/*
 // Override to customize the look of the cell that allows the user to load the next page of objects.
 // The default implementation is a UITableViewCellStyleDefault cell with simple labels.
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
 static NSString *CellIdentifier = @"NextPage";
 
 // TODO: The cell should show a spinner and load more data automatically
 
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
 
 cell.selectionStyle = UITableViewCellSelectionStyleNone;
 cell.textLabel.text = @"Load more...";
 
 return cell;
 }
 */

#pragma mark - PASAddArtistsTVCDelegate

- (void)viewController:(PASAddFromSamplesTVC *)vc didAddArtists:(BOOL)didAddArtists
{
	if (didAddArtists) {
		[self _refreshUI];
	}
	// Go back to the previous view
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

- (void)_refreshUI
{
	// TODO: make it more clear to the user that he added objects
	[self loadObjects];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"setFavArtistNames:"]) {
		if ([segue.destinationViewController respondsToSelector:@selector(setFavArtistNames:)]) {
			[segue.destinationViewController performSelector:@selector(setFavArtistNames:) withObject:[self artistNames]];
		}
		if ([segue.destinationViewController respondsToSelector:@selector(setMyDelegate:)]) {
			[segue.destinationViewController performSelector:@selector(setMyDelegate:) withObject:self];
		}
	}
}

@end
