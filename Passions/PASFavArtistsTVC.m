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
#import "PASPageViewController.h"
#import "FICImageCache.h"
#import "UIColor+Utils.h"
#import "PASArtistInfoCVC.h"
#import "PASManageArtists.h"

@interface PASFavArtistsTVC ()
@property (nonatomic, assign) BOOL preferNetwok;
@property (nonatomic, assign) BOOL isWaitingForServer;
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
	self.edgesForExtendedLayout = UIRectEdgeLeft|UIRectEdgeBottom|UIRectEdgeRight;
	self.clearsSelectionOnViewWillAppear = YES;

	// Setup navigationBar
	UIBarButtonItem *rbbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																		  target:self
																		  action:@selector(addButtonTapped:)];
	self.navigationItem.rightBarButtonItem = rbbi;
#if DEBUG
	// Image Cache Reset
	UIBarButtonItem *lbbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
																		  target:self
																		  action:@selector(resetFastimageCache:)];
	self.navigationItem.leftBarButtonItem = lbbi;
#endif
	
	// register to get notified if fav artists have been edited
	[[NSNotificationCenter defaultCenter] addObserverForName:kPASDidEditFavArtists
													  object:nil queue:nil
												  usingBlock:^(NSNotification *note) {
													  // get didEditArtists from the notification
													  id obj = note.userInfo[kPASDidEditFavArtists];
													  NSAssert([obj isKindOfClass:[NSNumber class]], @"kPASDidEditFavArtists must carry a NSNumber");
													  BOOL didEditArtists = [((NSNumber *)obj) boolValue];
													  if (didEditArtists) {
														  [self refreshUI:YES];
													  }
												  }];
	return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	// must execute before viewDidLoad such that
	// queryForCollection can react correctly
	self.preferNetwok = YES;
	
	[super viewDidLoad];
	
	// layout and look
	self.refreshControl.backgroundColor= [[UIColor alloc] initWithWhite:0.9 alpha:1.0];
	self.navigationController.navigationBar.barTintColor = [UIColor defaultNavBarTintColor];
	
	// TableView Properties
	self.tableView.separatorInset = UIEdgeInsetsMake(0, kPASSizeArtistThumbnailSmall + 4, 0, 0);
	self.tableView.separatorColor = [UIColor tableViewSeparatorColor];

	// register the custom cell
	[self.tableView registerNib:[UINib nibWithNibName:[PASArtistTVCell reuseIdentifier] bundle:nil]
		 forCellReuseIdentifier:[PASArtistTVCell reuseIdentifier]];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// Configure navigationController
	// Needs to be in viewWillAppear to make it work with other VC's
	self.navigationController.navigationBarHidden = NO;
	self.pageViewController.pageControlHidden = NO;
}

#if DEBUG
- (IBAction)resetFastimageCache:(UIBarButtonItem *)sender
{
	[[FICImageCache sharedImageCache] reset];
	[self refreshUI:YES];
}
#endif

#pragma mark - UITableViewDataSource Editing

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	// I can't remove the Artist from self.objects manually, need to reload, but seems to slow for the animation.
	PASArtistTVCell *cell = (PASArtistTVCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	
	[tableView beginUpdates];
	[cell.activityIndicator startAnimating];
	cell.activityIndicator.hidden = NO;

	if (editingStyle == UITableViewCellEditingStyleDelete) {
		PASArtist *artist = [self _artistAtIndexPath:indexPath];
		
		[[PASManageArtists sharedMngr] didSelectArtistWithName:artist.name completion:^(NSError *error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				cell.activityIndicator.hidden = YES;
				[cell.activityIndicator stopAnimating];
				[tableView endUpdates];
			});
			
			if (!error) {
				[[NSNotificationCenter defaultCenter] postNotificationName:kPASDidEditFavArtists
																	object:self
																  userInfo:@{ kPASDidEditFavArtists : [NSNumber numberWithBool:YES] }];
			} else {
				DDLogError(@"%@", [error description]);
			}
		}];
	}
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
		
		if (self.preferNetwok || self.isWaitingForServer) {
			query.cachePolicy = kPFCachePolicyNetworkOnly;
		} else {
			query.cachePolicy = kPFCachePolicyCacheElseNetwork;
		}
		
		return query;
	}
	DDLogDebug(@"CurrentUser not ready for FavArtists");
	return nil; // shows loading spinner
}

- (void)objectsDidLoad:(NSError *)error
{
	[super objectsDidLoad:error];
	self.isWaitingForServer = NO;
	self.preferNetwok = NO;
}

// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
	PASArtist *artist = (PASArtist *)object;
	PASArtistTVCell *cell = [tableView dequeueReusableCellWithIdentifier:[PASArtistTVCell reuseIdentifier] forIndexPath:indexPath];
	
	if ([artist isProcessingOnServer]) {
		self.isWaitingForServer = YES;
	}
	
	[cell showArtist:artist withName:artist.name andDetailTextBlock:nil];
	
	return cell;
}

#pragma mark - Navigation

- (void)refreshUI:(BOOL)network
{
	self.preferNetwok = network;
	[self loadObjects];
}

- (IBAction)addButtonTapped:(UIBarButtonItem *)sender
{
	[[PASManageArtists sharedMngr] passFavArtists:self.objects];
	[self presentViewController:self.addVcContainer animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	PASArtist *artist = [self _artistAtIndexPath:indexPath];
	
	if (![artist isProcessingOnServer]) {
		// only allow selecting when not in processing on server
		PASArtistInfoCVC *vc = [PASArtistInfoCVC new];
		vc.artist = artist;
		
		[self.navigationController pushViewController:vc animated:YES];
	}
}

@end
