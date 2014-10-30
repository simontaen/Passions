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
#import "PASMyPVC.h"
#import "FICImageCache.h"
#import "PASArtistInfo.h"
#import "UIColor+Utils.h"

@interface PASFavArtistsTVC()

@end

@implementation PASFavArtistsTVC

#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (!self) return nil;
	self.parseClassName = [PASArtist parseClassName];
	self.title = @"My Favorite Artists";
	self.pullToRefreshEnabled = YES;
	// no paging, I don't expect >200 fav artists
	self.paginationEnabled = NO;
	return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];

	// layout and look
	self.edgesForExtendedLayout = UIRectEdgeLeft|UIRectEdgeBottom|UIRectEdgeRight;
	self.refreshControl.backgroundColor= [[UIColor alloc] initWithWhite:0.9 alpha:1.0];
	self.navigationController.navigationBar.barTintColor = [UIColor defaultNavBarTintColor];
	
	// TableView Properties
	self.tableView.separatorInset = UIEdgeInsetsMake(0, kPASSizeArtistThumbnailSmall + 4, 0, 0);

	// register the custom cell
	[self.tableView registerNib:[UINib nibWithNibName:[PASArtistTVCell reuseIdentifier] bundle:nil]
		 forCellReuseIdentifier:[PASArtistTVCell reuseIdentifier]];
	
	// register to get notified if fav artists have been edited
	[[NSNotificationCenter defaultCenter] addObserverForName:kPASDidEditFavArtists
													  object:nil queue:nil
												  usingBlock:^(NSNotification *note) {
													  // get didEditArtists from the notification
													  id obj = note.userInfo[kPASDidEditFavArtists];
													  NSAssert([obj isKindOfClass:[NSNumber class]], @"kPASDidEditFavArtists must carry a NSNumber");
													  BOOL didEditArtists = [((NSNumber *)obj) boolValue];
													  if (didEditArtists) {
														  [self _refreshUI];
													  }
												  }];
#ifdef DEBUG
	// Image Cache Reset
	UIBarButtonItem *lbbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
																		  target:self
																		  action:@selector(resetFastimageCache:)];
	self.navigationItem.leftBarButtonItem = lbbi;
#endif
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
				[[NSNotificationCenter defaultCenter] postNotificationName:kPASDidEditFavArtists
																	object:self
																  userInfo:@{ kPASDidEditFavArtists : [NSNumber numberWithBool:YES] }];
			}
		}];
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
	if ([PFUser currentUser].objectId) {
		PFQuery *query = [PASArtist favArtistsForCurrentUser];
		
		// If no objects are loaded in memory, we look to the cache first to fill the table
		// and then subsequently do a query against the network.
		if (self.objects.count == 0) {
			query.cachePolicy = kPFCachePolicyCacheThenNetwork;
		}
		return query;
	}
	NSLog(@"CurrentUser not ready for FavArtists");
	return nil; // shows loading spinner
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

#pragma mark - Navigation

- (void)_refreshUI
{
	[self loadObjects];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:kPASSetFavArtists]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:kPASSetFavArtists
															object:self
														  userInfo:@{ kPASSetFavArtists : self.objects }];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	PASArtist *artist = [self _artistAtIndexPath:indexPath];
	
	PASArtistInfo *vc = (PASArtistInfo *)[self.storyboard instantiateViewControllerWithIdentifier:@"PASArtistInfo"];
	vc.artist = artist;
	
	UINavigationController *navVc = [[UINavigationController alloc] initWithRootViewController:vc];
	[self presentViewController:navVc animated:YES completion:nil];
}

@end
