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
#import "PASPageViewController.h"
#import "PASExtendedNavContainer.h"
#import "MBProgressHUD.h"

@interface PASAddFromSpotifyTVC ()
@property (nonatomic, strong) SPTSession *session;
@property (nonatomic, strong) id observer; // the NSNotificationCenter observer token
@property (nonatomic, strong) UIBarButtonItem *spotifyButton;

@property (nonatomic, copy) void (^savedTracksForUserCallback)(NSError *error, id object);
@property (nonatomic, strong) NSMutableDictionary *artists; // of NSString (artistName) -> SPTPartialArtist
@property (nonatomic, strong) NSMutableDictionary *artistsTracks; // of NSString (artistName) -> NSMutableArray of SPTSavedTrack

// Helpers for the fetching process
@property (nonatomic, strong) dispatch_queue_t artistsQ;
// YES when the all simplified artists are available
@property (nonatomic, assign) BOOL fetchedAllPartialArtists;
// 0 when all artists are upgraded to full objects
@property (nonatomic, assign) int artistsInPromotion;

// Main indicator if fetching is done
@property (nonatomic, assign) BOOL isFetching;

@end

@implementation PASAddFromSpotifyTVC

#pragma mark - Init

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (!self) return nil;
	
	// we are not ready on init
	self.artistsInPromotion = -1;
	
	// perpare for caching artists
	self.artistsQ = dispatch_queue_create("spotifyArtistsQ", DISPATCH_QUEUE_CONCURRENT);
	
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

#pragma mark - Accessors

- (UIBarButtonItem *)spotifyButton
{
	if (!_spotifyButton) {
		_spotifyButton = [[UIBarButtonItem alloc] initWithTitle:@""
														  style:UIBarButtonItemStylePlain
														 target:self action:@selector(spotifyButtonTapped:)];
	}
	return _spotifyButton;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// TableView Setup
//	self.refreshControl = [[UIRefreshControl alloc] init];
//	[self.refreshControl addTarget:self action:@selector(_fetchSpotifyArtists) forControlEvents:UIControlEventValueChanged];
	
	[self _validateSessionWithCallback:^{
		[self _fetchSpotifyArtistsWithCompletion:^(NSError *error) {
			if (!error) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[self.tableView reloadData];
				});
			} else {
				[self _handleError:error];
			}
		}];
	}];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.pageViewController.navigationItem.leftBarButtonItem = self.spotifyButton;
	[self _configureSpotifyButton];

	if (self.artists && self.artists.count == 0) {
		// artists have been fetched but non exists
		[self _validateSessionWithCallback:^{
			[self _fetchSpotifyArtistsWithCompletion:^(NSError *error) {
				if (!error) {
					dispatch_async(dispatch_get_main_queue(), ^{
						[self.tableView reloadData];
					});
				} else {
					[self _handleError:error];
				}
			}];
		}];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	self.pageViewController.navigationItem.leftBarButtonItem = nil;
}

- (void)prepareCaches
{
	// Caches are updated when new data is received
	[self _validateSessionWithCallback:^{
		[self _fetchSpotifyArtistsWithCompletion:^(NSError *error) {
			if (!error && [self isViewLoaded]) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[self.tableView reloadData];
				});
			} else {
				[self _handleError:error];
			}
		}];
	}];
}

- (BOOL)_cachesAreReady
{
	return self.fetchedAllPartialArtists && self.artistsInPromotion == 0;
}

- (void)clearCaches
{
	[super clearCaches];
	if (!self.isFetching) {
		self.artists = nil;
		self.artistsTracks = nil;
		self.fetchedAllPartialArtists = NO;
		self.artistsInPromotion = -1;
	}
}

#pragma mark - Accessors

- (NSString *)title
{
	return @"Spotify";
}

- (void)setIsFetching:(BOOL)isFetching
{
	if (_isFetching != isFetching) {
		_isFetching = isFetching;
		isFetching ? [self _showProgressHud] : [self _hideProgressHud];
	}
}

#pragma mark - Subclassing

- (UIColor *)chosenTintColor
{
	return [UIColor spotifyTintColor];
}

- (NSArray *)artistsOrderedByName
{
	if ([self _cachesAreReady]) {
		NSArray *nameSortedKeys = [[self.artists allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
		NSMutableArray *sortedArtists = [NSMutableArray arrayWithCapacity:nameSortedKeys.count];
		
		for (NSString *key in nameSortedKeys) {
			[sortedArtists addObject:self.artists[key]];
		}
		return sortedArtists;
		
	} else {
		return [NSArray array];
	}
}

- (NSArray *)artistsOrderedByPlaycount
{
	if ([self _cachesAreReady]) {
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
		
	} else {
		return [NSArray array];
	}
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
	if (self.isFetching) {
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
}

- (void)_cacheArtistsFromArray:(NSArray *)artists completion:(void (^)(NSError *error))completion
{
	if (self.isFetching) {
		// an artists comes here several times and we are called multiple times
		for (SPTPartialArtist *artist in artists) {
			NSString *artistName = artist.name;
			
			BOOL __block cachedAlready;
			dispatch_barrier_sync(self.artistsQ, ^{
				cachedAlready = !!self.artists[artistName];
			});
			
			if (!cachedAlready) {
				dispatch_barrier_async(self.artistsQ, ^{
					// this is for signaling that we are working on the artist
					self.artists[artistName] = artist;
				});
				self.artistsInPromotion++;
				__weak typeof(self) weakSelf = self;
				
				// Need to promote to full Artist for the images
				// https://developer.spotify.com/web-api/object-model/#artist-object-full
				[SPTRequest requestItemFromPartialObject:artist withSession:self.session callback:^(NSError *error, id object) {
					self.artistsInPromotion--;
					if (!error && object) {
						dispatch_barrier_async(self.artistsQ, ^{
							self.artists[artistName] = object;
						});
						if ([weakSelf _cachesAreReady] && completion) {
							// fire the completion when all artists have been processed
							completion(nil);
						}
						
					} else {
						dispatch_barrier_async(self.artistsQ, ^{
							// must remove the partial artist
							[self.artists removeObjectForKey:artistName];
						});
						if (completion) {
							completion(error);
						}
					}
				}];
			}
		}
	}
}

// if fetching is already running the completion will not get called
- (void)_fetchSpotifyArtistsWithCompletion:(void (^)(NSError *error))completion
{
	if (!self.isFetching) {
		if (![self _cachesAreReady]) {
			self.isFetching = YES;
			self.artists = [NSMutableDictionary dictionary];
			self.artistsTracks = [NSMutableDictionary dictionary];
			self.fetchedAllPartialArtists = NO;
			self.artistsInPromotion = 0;
			__weak typeof(self) weakSelf = self;
			
			// the block to recursivly fetch all tracks
			self.savedTracksForUserCallback = ^void(NSError *error, id object) {
				if (!error && object) {
					SPTListPage *list = (SPTListPage *)object;
					
					if ([list hasNextPage]) {
						[list requestNextPageWithSession:weakSelf.session callback:weakSelf.savedTracksForUserCallback];
					} else {
						weakSelf.fetchedAllPartialArtists = YES;
					}
					
					for (SPTSavedTrack *track in [list items]) {
						[weakSelf _cacheArtistsFromArray:track.artists completion:^(NSError *innerError) {
							// this only gets called when all (overall!) artists have been processed
							if (!innerError) {
								weakSelf.isFetching = NO;
								if (completion) {
									completion(nil);
								}
								
							} else if (completion) {
								completion(innerError);
							}
							
						}];
						[weakSelf _cacheTrack:track forArtists:track.artists];
					}
					
				} else {
					if (completion) {
						completion(error);
					}
				}
			};
			
			[SPTRequest savedTracksForUserInSession:self.session callback:self.savedTracksForUserCallback];
			
		} else {
			// caches are ready
			completion(nil);
		}
	}
}

#pragma mark - MBProgressHUD

- (void)_showProgressHud
{
	dispatch_async(dispatch_get_main_queue(), ^{
		MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.pageViewController.view animated:YES];
		hud.labelText = @"Loading Spotify Artists...";
		self.extendedNavController.segmentedControl.enabled = NO;
		self.pageViewController.navigationItem.leftBarButtonItem.enabled = NO;
	});
}

- (void)_hideProgressHud
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[MBProgressHUD hideHUDForView:self.pageViewController.view animated:YES];
		self.extendedNavController.segmentedControl.enabled = YES;
		self.pageViewController.navigationItem.leftBarButtonItem.enabled = YES;
	});
}

#pragma mark - Private Methods

- (NSUInteger)_trackcountForArtist:(id)artist withName:(NSString *)name
{
	NSAssert([artist isKindOfClass:[SPTArtist class]], @"%@ cannot get name for artists of class %@", NSStringFromClass([PASAddFromSpotifyTVC class]), NSStringFromClass([artist class]));
	return [self.artistsTracks[name] count];
}

#pragma mark - Error Handling

- (void)_handleError:(NSError *)error
{
	// abort everything and display a message,
	// show available artists
	NSLog(@"%@", [error description]);
	NSString *codeString = [NSString stringWithFormat:@"%d", (int)[error code]];
	[PFAnalytics trackEvent:@"error" dimensions:@{ @"code": codeString,  @"desc" : [error description] }];
	
	NSString *msg;
	switch (error.code) {
		case -1001:
			msg = @"The operation timed out.";
			break;
		default:
			msg = @"Something went wrong.";
			break;
	}
	
	// use force to the stop loading
	self.isFetching = NO;
	
	UIAlertAction *retry = [UIAlertAction actionWithTitle:@"Retry"
															style:UIAlertActionStyleDefault
														  handler:^(UIAlertAction * action) {
															  [self clearCaches];
															  [self prepareCaches];
														  }];

	[self showAlertWithTitle:@"Try Again" message:msg actions:@[retry] defaultButton:@"OK"];
}

#pragma mark - Spotify Auth

- (void)spotifyButtonTapped:(UIBarButtonItem *)sender
{
	if (self.session) {
		[UICKeyChainStore removeItemForKey:NSStringFromClass([self class])];
		self.session = nil;
		[self clearCaches];
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.tableView reloadData];
			[self _configureSpotifyButton];
		});
		
	} else {
		NSURL *loginPageURL = [[SPTAuth defaultInstance] loginURLForClientId:kPASSpotifyClientId
														 declaredRedirectURL:[PASResources	spotifyCallbackUri]
																	  scopes:@[SPTAuthUserLibraryRead]];
		[[UIApplication sharedApplication] openURL:loginPageURL];
	}
}

- (void)_configureSpotifyButton
{
	if (self.pageViewController.navigationItem.leftBarButtonItem) {
		if (self.session) {
			// logged in
			self.pageViewController.navigationItem.leftBarButtonItem.title = @"Logout";
		} else {
			// logged out
			self.pageViewController.navigationItem.leftBarButtonItem.title = @"Login";
		}
	}
}

- (void)_validateSessionWithCallback:(void (^)())completion
{
	// This is the callback that'll be triggered when auth is completed (or fails).
	SPTAuthCallback authCallback = ^(NSError *error, SPTSession *session) {
		if (error != nil) {
			NSLog(@"%@", error);
			
		} else {
			// We are authenticated, cleanup
			[[NSNotificationCenter defaultCenter] removeObserver:nil
															name:kPASSpotifyClientId
														  object:self];
			// Persist the new session and fetch new data
			self.session = session;
			if (completion) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[self _configureSpotifyButton];
					completion();
				});
			}
			NSData *sessionData = [NSKeyedArchiver archivedDataWithRootObject:self.session];
			[UICKeyChainStore setData:sessionData forKey:NSStringFromClass([self class])];
		}
		
	};
	
	if (!self.session) {
		if (!self.observer) {
			// No valid session found, first register for nofications when done
			self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:kPASSpotifyClientId
																			  object:nil queue:nil
																		  usingBlock:^(NSNotification *note) {
																			  id obj = note.userInfo[kPASSpotifyClientId];
																			  NSAssert([obj isKindOfClass:[NSURL class]], @"kPASSpotifyClientId must carry a NSURL");
																			  // The user finished the authentication in Safari, handle it
																			  [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:(NSURL *)obj
																												  tokenSwapServiceEndpointAtURL:[PASResources spotifyTokenSwap]
																																	   callback:authCallback];
																		  }];
		}
		
	} else if (![self.session isValid]) {
		// Renew the session
		[[SPTAuth defaultInstance] renewSession:self.session withServiceEndpointAtURL:[PASResources spotifyTokenRefresh] callback:authCallback];
		
	} else if (completion) {
		// update button status
		[self _configureSpotifyButton];
		completion();
	}
}

@end
