//
//  PASFavArtistsTVC.m
//  Passions
//
//  Created by Simon Tännler on 03/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASFavArtistsTVC.h"
#import "PASArtistTVCell.h"
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
	// no paging, I don't expect >200 fav artists
	self.paginationEnabled = NO;
	return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.edgesForExtendedLayout = UIRectEdgeLeft|UIRectEdgeBottom|UIRectEdgeRight;
	[self.tableView registerNib:[UINib nibWithNibName:[PASArtistTVCell reuseIdentifier] bundle:nil]
		 forCellReuseIdentifier:[PASArtistTVCell reuseIdentifier]];
	self.refreshControl.backgroundColor= [[UIColor alloc] initWithWhite:0.9 alpha:1.0];
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
		[artist removeCurrentUserAsFavoriteWithCompletion:^(BOOL succeeded, NSError *error) {
			if (succeeded && !error) {
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
		[currentInstallation setObject:[UIDevice currentDevice].model forKey:@"deviceModel"];
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
	PASArtistTVCell *cell = [tableView dequeueReusableCellWithIdentifier:[PASArtistTVCell reuseIdentifier] forIndexPath:indexPath];
	
	[cell showArtist:artist];
	
	return cell;
}

#pragma mark - PASAddArtistsTVCDelegate

- (void)viewController:(PASAddFromSamplesTVC *)vc didEditArtists:(BOOL)didEditArtists
{
	if (didEditArtists) {
		[self _refreshUI];
	}
	// Go back to the previous view
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

- (void)_refreshUI
{
	[self loadObjects];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"setFavArtists:"]) {
		if ([segue.destinationViewController respondsToSelector:@selector(setFavArtists:)]) {
			[segue.destinationViewController performSelector:@selector(setFavArtists:) withObject:[self.objects mutableCopy]];
		}
		if ([segue.destinationViewController respondsToSelector:@selector(setMyDelegate:)]) {
			[segue.destinationViewController performSelector:@selector(setMyDelegate:) withObject:self];
		}
	}
}

@end
