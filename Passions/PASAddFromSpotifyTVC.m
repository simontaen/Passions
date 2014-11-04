//
//  PASAddFromSpotifyTVC.m
//  Passions
//
//  Created by Simon Tännler on 01/11/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASAddFromSpotifyTVC.h"
#import "UIColor+Utils.h"
#import <Spotify/Spotify.h>
#import "UICKeyChainStore.h"

@interface PASAddFromSpotifyTVC ()
@property (nonatomic, weak) IBOutlet UIButton *spotifyLoginButton;
@property (nonatomic, strong) SPTSession *session;

@property (nonatomic, copy) void (^savedTracksForUserCallback)(NSError *error, id object);
@property (nonatomic, strong) NSMutableDictionary *artists; // of NSString (artistName) -> SPTPartialArtist
@property (nonatomic, strong) NSMutableDictionary *artistsTracks; // of NSString (artistName) -> NSMutableArray of SPTSavedTrack

// Helpers for the fetching process
@property (nonatomic, strong) dispatch_queue_t artistsQ;
@property (nonatomic, strong) NSMutableArray *artistsInProgress;
@property (nonatomic, assign) BOOL fetchedAllArtists;

// Main indicator if fetching is done
@property (nonatomic, assign) BOOL isFetching;
@end

@implementation PASAddFromSpotifyTVC

#pragma mark - Init

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (!self) return nil;
	
	// perpare for caching artists
	self.artistsQ = dispatch_queue_create("artistsQ", DISPATCH_QUEUE_CONCURRENT);
	self.artistsInProgress = [NSMutableArray array];
	
	// Try to get a stored Seesion
	NSData *sessionData = [UICKeyChainStore dataForKey:NSStringFromClass([self class])];
	if (sessionData) {
		self.session = [NSKeyedUnarchiver unarchiveObjectWithData:sessionData];
	}
	
	// Detail Text Formatting
	__weak typeof(self) weakSelf = self;
	self.detailTextBlock = ^NSString *(id<FICEntity> artist, NSString *name) {
		NSUInteger trackcount = [weakSelf _trackcountForArtist:artist withName:name];
		if (trackcount == 1) {
			return [NSString stringWithFormat:@"%lu Track", (unsigned long)trackcount];
		} else {
			return [NSString stringWithFormat:@"%lu Tracks", (unsigned long)trackcount];
		}
	};
	
	return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// TableView Setup
//	self.refreshControl = [[UIRefreshControl alloc] init];
//	[self.refreshControl addTarget:self action:@selector(_fetchSpotifyArtists) forControlEvents:UIControlEventValueChanged];
	
	[self _validateSessionWithCallback:^{
		if (![self _cachesAreReady] && !self.isFetching) {
			[self _fetchSpotifyArtists];
		} else if (!self.isFetching) {
			// everything seems to be ready
			[self.tableView reloadData];
		}
	}];
}

- (void)prepareCaches
{
	// Caches are updated when new data is received
	[self _validateSessionWithCallback:^{
		if (![self _cachesAreReady] && !self.isFetching) {
			[self _fetchSpotifyArtists];
		}
	}];
}

- (BOOL)_cachesAreReady
{
	return self.artists && self.artistsInProgress.count == 0 && self.fetchedAllArtists;
}

#pragma mark - Accessors

- (NSString *)title
{
	return @"Spotify";
}

#pragma mark - Subclassing

- (UIColor *)chosenTintColor
{
	return [UIColor spotifyTintColor];
}

- (NSArray *)artistsOrderedByName
{
	NSArray *nameSortedKeys = [[self.artists allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	NSMutableArray *sortedArtists = [NSMutableArray arrayWithCapacity:nameSortedKeys.count];
	
	for (NSString *key in nameSortedKeys) {
		[sortedArtists addObject:self.artists[key]];
	}
	
	return sortedArtists;
}

- (NSArray *)artistsOrderedByPlaycount
{
	NSArray *trackcountSortedKeys = [[self.artistsTracks allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		NSMutableArray *obj1Tracks = self.artistsTracks[obj1];
		NSMutableArray *obj2Tracks = self.artistsTracks[obj2];
		
		NSInteger result = obj1Tracks.count - obj2Tracks.count;
		
		if (result > 0) {
			return NSOrderedAscending;
		} else if (result < 0) {
			return NSOrderedDescending;
		}
		return NSOrderedSame;
	}];
	
	NSMutableArray *sortedArtists = [NSMutableArray arrayWithCapacity:trackcountSortedKeys.count];
	
	for (NSString *key in trackcountSortedKeys) {
		[sortedArtists addObject:self.artists[key]];
	}
	
	return sortedArtists;
}

- (NSString *)nameForArtist:(id)artist
{
	NSAssert([artist isKindOfClass:[SPTArtist class]], @"%@ cannot get name for artists of class %@", NSStringFromClass([PASAddFromSpotifyTVC class]), NSStringFromClass([artist class]));
	return ((SPTArtist *)artist).name;
}

- (NSString *)sortOrderDescription:(PASAddArtistsSortOrder)sortOrder
{
	switch (sortOrder) {
		case PASAddArtistsSortOrderByPlaycount:
			return @"by trackcount";
		default:
			return [super sortOrderDescription:sortOrder];
	}
}

#pragma mark - Spotify Data Fetching

- (void)_cacheTrack:(SPTSavedTrack *)track forArtists:(NSArray *)artists
{
	for (SPTPartialArtist *artist in artists) {
		NSString *artistName = artist.name;
		
		NSMutableArray *tracks = self.artistsTracks[artistName];
		
		if (!tracks) {
			self.artistsTracks[artistName] = [NSMutableArray array];
			tracks = self.artistsTracks[artistName];
		}
		
		[tracks addObject:track];
	}
}

- (void)_cacheArtistsFromArray:(NSArray *)artists
{
	for (SPTPartialArtist *artist in artists) {
		NSString *artistName = artist.name;
		
		BOOL __block inProgress = YES;
		dispatch_barrier_sync(self.artistsQ, ^{
			inProgress = [self.artistsInProgress containsObject:artistName];
		});
		
		BOOL __block cachedAlready = YES;
		if (!inProgress) {
			dispatch_barrier_sync(self.artistsQ, ^{
				cachedAlready = !!self.artists[artistName];
			});
		}
		
		if (!cachedAlready) {
			dispatch_barrier_async(self.artistsQ, ^{
				[self.artistsInProgress addObject:artistName];
			});
			
			// Need to promote to Full Artist
			[SPTRequest requestItemFromPartialObject:artist withSession:self.session callback:^(NSError *error, id object) {
				if (!error && object) {
					dispatch_barrier_async(self.artistsQ, ^{
						self.artists[artistName] = object;
					});
				}
				
				dispatch_barrier_sync(self.artistsQ, ^{
					[self.artistsInProgress removeObject:artistName];
					if (self.artistsInProgress.count == 0 && self.fetchedAllArtists) {
						dispatch_async(dispatch_get_main_queue(), ^{
							if ([self isViewLoaded]) {
								// TODO: this would be nice with a callback from _fetchSpotifyArtists
								// we could have been called when unloaded
								[self.tableView reloadData];
							}
							//[self.refreshControl endRefreshing]; // uncomment this and viewDidLoad will get calles!
							self.isFetching = NO;
						});
					}
				});
			}];
		}
	}
}

-(void)_fetchSpotifyArtists
{
	self.isFetching = YES;
	//[self.refreshControl beginRefreshing]; // uncomment this and viewDidLoad will get calles!
	self.artists = [NSMutableDictionary dictionary];
	self.artistsTracks = [NSMutableDictionary dictionary];
	__weak typeof(self) weakSelf = self;
	
	// the block to recursivly fetch all tracks
	self.savedTracksForUserCallback = ^void(NSError *error, id object) {
		if (!error && object) {
			SPTListPage *list = (SPTListPage *)object;
			
			if ([list hasNextPage]) {
				[list requestNextPageWithSession:weakSelf.session callback:weakSelf.savedTracksForUserCallback];
			} else {
				weakSelf.fetchedAllArtists = YES;
			}
			
			for (SPTSavedTrack *track in [list items]) {
				[weakSelf _cacheArtistsFromArray:track.artists];
				[weakSelf _cacheTrack:track forArtists:track.artists];
			}
			
		} else {
			NSLog(@"%@", error);
		}
	};

	self.fetchedAllArtists = NO;
	[SPTRequest savedTracksForUserInSession:self.session callback:self.savedTracksForUserCallback];
}

#pragma mark - Private Methods

- (NSUInteger)_trackcountForArtist:(id)artist withName:(NSString *)name
{
	NSAssert([artist isKindOfClass:[SPTArtist class]], @"%@ cannot get name for artists of class %@", NSStringFromClass([PASAddFromSpotifyTVC class]), NSStringFromClass([artist class]));
	return [self.artistsTracks[name] count];
}

#pragma mark - Spotify Auth

- (void)_showLoginWithSpotify
{
	UIImage *img = [PASResources spotifyLogin];
	CGFloat imgWidth = img.size.width;
	CGFloat imgHeight = img.size.height;
	
	CGRect myFrame = CGRectMake(self.view.frame.size.width / 2 - imgWidth / 2, self.view.frame.size.height / 2 - imgHeight / 2, imgWidth, imgHeight);
	UIButton *btn = [[UIButton alloc] initWithFrame:myFrame];
	self.spotifyLoginButton = btn;
	
	[btn setImage:img forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(_loginWithSpotify:) forControlEvents:UIControlEventTouchUpInside];
	
	[self.view addSubview:btn];
}

-(IBAction)_loginWithSpotify:(UIButton *)sender
{
	self.spotifyLoginButton.userInteractionEnabled = NO;
	NSURL *loginPageURL = [[SPTAuth defaultInstance] loginURLForClientId:kPASSpotifyClientId
													 declaredRedirectURL:[PASResources	spotifyCallbackUri]
																  scopes:@[SPTAuthUserLibraryRead]];
	[[UIApplication sharedApplication] openURL:loginPageURL];
}

- (void)_validateSessionWithCallback:(void (^)())completion
{
	// This is the callback that'll be triggered when auth is completed (or fails).
	SPTAuthCallback authCallback = ^(NSError *error, SPTSession *session) {
		if (error != nil) {
			NSLog(@"%@", error);
			// allow more attempts
			self.spotifyLoginButton.userInteractionEnabled = YES;
			self.spotifyLoginButton.hidden = NO;
			
		} else {
			// We are authenticated, cleanup
			[[NSNotificationCenter defaultCenter] removeObserver:nil
															name:kPASSpotifyClientId
														  object:self];
			// Persist the new session and fetch new data
			self.session = session;
			if (completion) {
				completion();
			}
			NSData *sessionData = [NSKeyedArchiver archivedDataWithRootObject:self.session];
			[UICKeyChainStore setData:sessionData forKey:NSStringFromClass([self class])];
		}
	};
	
	if (!self.session) {
		// No valid session found, first register for nofications when done
		[[NSNotificationCenter defaultCenter] addObserverForName:kPASSpotifyClientId
														  object:nil queue:nil
													  usingBlock:^(NSNotification *note) {
														  id obj = note.userInfo[kPASSpotifyClientId];
														  NSAssert([obj isKindOfClass:[NSURL class]], @"kPASSpotifyClientId must carry a NSURL");
														  self.spotifyLoginButton.hidden = YES;
														  // The user finished the authentication in Safari, handle it
														  [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:(NSURL *)obj
																							  tokenSwapServiceEndpointAtURL:[PASResources spotifyTokenSwap]
																												   callback:authCallback];
													  }];
		// show login button
		[self _showLoginWithSpotify];
		
	} else if (![self.session isValid]) {
		// Renew the session
		[[SPTAuth defaultInstance] renewSession:self.session withServiceEndpointAtURL:[PASResources spotifyTokenRefresh] callback:authCallback];
		
	} else if (completion) {
		completion();
	}
}

@end
