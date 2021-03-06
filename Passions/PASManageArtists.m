//
//  PASManageArtists.m
//  Passions
//
//  Created by Simon Tännler on 21/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASManageArtists.h"
#import "PASArtist.h"
#import "PASMediaQueryAccessor.h"
#import "MPMediaItemCollection+Passions.h"
#import "LastFmFetchr.h"

@interface PASManageArtists()

#pragma mark - Faving Artists
// worker Q http://stackoverflow.com/a/5511403 / http://stackoverflow.com/a/13705529
@property (nonatomic, strong) dispatch_queue_t favoritesQ;
@property (nonatomic, strong) dispatch_queue_t progressQ;
@property (nonatomic, strong) NSMutableArray* artistsInProgress; // NSString

// passed by the segue, LFM Corrected!
@property (nonatomic, strong, readonly) NSArray* originalFavArtists; // PASArtist, never changed
// these contain current changes
@property (nonatomic, strong) NSMutableArray* favArtists; // PASArtist
@property (nonatomic, strong) NSMutableArray* favArtistNames; // NSString, built based on favArtists

// for newly favorited artists
@property (nonatomic, strong) NSMutableArray* justFavArtists; // PASArtist
@property (nonatomic, strong) NSMutableArray* justFavArtistNames; // NSString, LFM corrected!

#pragma mark - Corrections
@property (nonatomic, strong) NSMutableDictionary* artistNameCorrections; // NSString (display) -> NSString (internal on Favorite Artists TVC, LFM corrected)
@property (nonatomic, strong) dispatch_queue_t correctionsQ;

@end

@implementation PASManageArtists

#pragma mark - Init

+ (instancetype) sharedMngr
{
	static PASManageArtists *_mngr = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_mngr = [PASManageArtists new];
	});
	return _mngr;
}

- (instancetype) init {
	self = [super init];
	if (!self) return nil;
	
	// perpare for user favoriting artists
	self.favoritesQ = dispatch_queue_create("favoritesQ", DISPATCH_QUEUE_CONCURRENT);
	self.progressQ = dispatch_queue_create("progressQ", DISPATCH_QUEUE_CONCURRENT);
	self.artistsInProgress = [NSMutableArray array];
	self.correctionsQ = dispatch_queue_create("correctionsQ", DISPATCH_QUEUE_CONCURRENT);
	
	// register for memory warnings
	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification
													  object:nil queue:nil
												  usingBlock:^(NSNotification *note) {
													  [self writeToDisk];
													  if (![self favingInProcess]) {
														  self.artistNameCorrections = nil;
													  }
												  }];
	return self;
}

#pragma mark - Accessors

- (NSMutableDictionary *)artistNameCorrections
{
	if (!_artistNameCorrections) {
		NSURL *cacheFile = [[[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory
																	inDomains:NSUserDomainMask] firstObject]
							URLByAppendingPathComponent:NSStringFromClass([self class])];
		_artistNameCorrections = [NSMutableDictionary dictionaryWithContentsOfURL:cacheFile];
		
		if (!_artistNameCorrections) {
			_artistNameCorrections = [NSMutableDictionary dictionary];
		}
	}
	return _artistNameCorrections;
}

#pragma mark - Communication

- (void)passFavArtists:(NSArray *)favArtists
{
	self.justFavArtists = [NSMutableArray array];
	self.justFavArtistNames = [NSMutableArray array];
	
	self.favArtists = favArtists ? [NSMutableArray arrayWithArray:favArtists] : [NSMutableArray array];
	_originalFavArtists = [NSArray arrayWithArray:favArtists];
	
	self.favArtistNames = [NSMutableArray arrayWithCapacity:favArtists.count];
	for (PASArtist *artist in favArtists) {
		[self.favArtistNames addObject:artist.name];
	}
}

- (BOOL)didEditArtists
{
	return self.justFavArtistNames.count != 0 || self.favArtists.count != self.originalFavArtists.count;
}

#pragma mark - Faving an Artist

- (void)didSelectArtistWithName:(NSString *)artistName
					 completion:(void (^)(NSError *error))completion;
{
	NSParameterAssert(artistName);
	NSAssert(self.favArtists != nil, @"It looks like passFavArtists has not been");
	
#ifdef DEBUG
	if ([artistName isEqualToString:@"Crash the App!"]) {
		DDLogError(@"DDLogError right before Crash");
		DDLogWarn(@"DDLogWarn right before Crash");
		DDLogInfo(@"DDLogInfo right before Crash");
		DDLogDebug(@"DDLogDebug right before Crash");
		DDLogVerbose(@"DDLogVerbose right before Crash");
		[[Crashlytics sharedInstance] crash];
	}
#endif
	
#ifdef DEBUG
	if ([artistName isEqualToString:@"Cause Assertion Error!"]) {
		DDLogError(@"DDLogError right before Assertion");
		DDLogWarn(@"DDLogWarn right before Assertion");
		DDLogInfo(@"DDLogInfo right before Assertion");
		DDLogDebug(@"DDLogDebug right before Assertion");
		DDLogVerbose(@"DDLogVerbose right before Assertion");
		
		NSAssert(NO, @"Assertion Error triggered");
	}
#endif
	
	NSString *resolvedName = [self _resolveArtistName:artistName];
	
	dispatch_barrier_async(self.progressQ, ^{
		[self.artistsInProgress addObject:resolvedName];
	});
	void (^myCompletion)(NSError *error) = ^void(NSError *error) {
		dispatch_barrier_async(self.progressQ, ^{
			[self.artistsInProgress removeObject:resolvedName];
		});
		if (completion) {
			completion(error);
		}
	};
	
	if ([self isFavoriteArtist:resolvedName isResolved:YES]) {
		PASArtist *artist = [self _artistForResolvedName:resolvedName];
		// The artist is favorited, a correctedName MUST exists. BUT a NSAssert might be too much.
		
		[artist removeCurrentUserAsFavoriteWithCompletion:^(BOOL succeeded, NSError *error) {
			if (succeeded && !error) {
				dispatch_barrier_async(self.favoritesQ, ^{
					if ([self.favArtistNames containsObject:resolvedName]) {
						[self.favArtists removeObjectAtIndex:[self.favArtistNames indexOfObject:resolvedName]];
						[self.favArtistNames removeObject:resolvedName];
					} else {
						[self.justFavArtists removeObjectAtIndex:[self.justFavArtistNames indexOfObject:resolvedName]];
						[self.justFavArtistNames removeObject:resolvedName];
					}
					
					NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
					[dc postNotificationName:kPASDidEditArtistWithName
									  object:self
									userInfo:@{kPASDidEditArtistWithName : resolvedName}];
					myCompletion(nil);
				});
				
			} else {
				myCompletion(error);
			}
		}];
		
		
	} else {
		[self _favoriteArtistByCurrentUser:resolvedName
								  saveUser:YES
						   needsCorrection:![self _correctedArtistName:artistName]
							  originalName:artistName
								completion:myCompletion];
	}
}

- (void)_favoriteArtistByCurrentUser:(NSString *)resolvedName
							saveUser:(BOOL)saveUser
					 needsCorrection:(BOOL)needsCorrection
						originalName:(NSString *)originalName
						  completion:(void (^)(NSError *error))completion
{
	[PASArtist favoriteArtistByCurrentUser:resolvedName
						   needsCorrection:needsCorrection
								  saveUser:saveUser
								completion:^(PASArtist *artist, NSError *error) {
									if (artist && !error) {
										// get the finalized name on parse
										NSString *parseArtistName = artist.name;
										
										dispatch_barrier_async(self.correctionsQ, ^{
											// cache the mapping userDisplayed -> corrected
											[self.artistNameCorrections setObject:parseArtistName forKey:originalName];
										});
										
										dispatch_barrier_async(self.favoritesQ, ^{
											[self.justFavArtistNames addObject:parseArtistName];
											[self.justFavArtists addObject:artist];
											
											NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
											[dc postNotificationName:kPASDidEditArtistWithName
															  object:self
															userInfo:@{kPASDidEditArtistWithName : parseArtistName}];
											completion(nil);
										});
										
									} else {
										completion(error);
									}
								}];
}

- (BOOL)isFavoriteArtist:(NSString *)artistName isResolved:(BOOL)isResolved
{
	NSString *resolvedName = isResolved ? artistName : [self _resolveArtistName:artistName];
	
	return [self.favArtistNames containsObject:resolvedName] || [self.justFavArtistNames containsObject:resolvedName];
}

- (BOOL)isArtistInProgress:(NSString *)artistName
{
	BOOL __block result;
	dispatch_barrier_sync(self.progressQ, ^{
		result = [self.artistsInProgress containsObject:artistName];
	});
	return result;
}

- (BOOL)favingInProcess
{
	BOOL __block result;
	dispatch_barrier_sync(self.progressQ, ^{
		result = self.artistsInProgress.count != 0;
	});
	return result;
}

- (void)addInitialFavArtistsWithCompletion:(void (^)())completion
{
	// this is called from the app delegate, make sure you're properly set up
	if (!self.originalFavArtists) {
		[self passFavArtists:@[]];
	}
	
	void (^favingBlock)(NSArray*, BOOL) = ^void(NSArray *artistNames, BOOL needCorrection) {
		NSUInteger __block doneCounter = 0;
		NSUInteger count = artistNames.count;
		
		if (count > 0) {
			for (NSString *artistName in artistNames) {
				DDLogInfo(@"Initial Add: favingBlock faving %@", artistName);
				[self _favoriteArtistByCurrentUser:artistName
										  saveUser:NO
								   needsCorrection:needCorrection
									  originalName:artistName
										completion:^(NSError *error) {
											doneCounter++;
											if (error) {
												DDLogError(@"Initial Add: favingBlock faving %@ %@", artistName, [error description]);
											} else {
												DDLogInfo(@"Initial Add: favingBlock faving complete %@", artistName);
											}
											
											if (doneCounter == count) {
												DDLogInfo(@"Initial Add: favingBlock all artists complete, save user");
												// Save User now that all are done
												[[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *userError) {
													if (userError) {
														DDLogError(@"Initial Add: favingBlock save user %@", [userError description]);
													} else {
														DDLogInfo(@"Initial Add: favingBlock user saved");
													}
													completion();
												}];
											}
										}];
			}
		} else {
			DDLogInfo(@"Initial Add: favingBlock No Artists to favorite");
			completion();
		}
	};
	
	if (![PASMediaQueryAccessor sharedMngr].usesMusicApp) {
		DDLogInfo(@"User \"%@\" doesn't seem to use the Music App", [PFUser currentUser].objectId);
		
		NSURLSessionTask *task = [[LastFmFetchr fetchr] getChartsTopArtists:nil
																  withLimit:3 completion:^(LFMChartTopArtists *data, NSError *error) {
																	  NSMutableArray *artistNames = [NSMutableArray arrayWithCapacity:3];
																	  if (data && !error) {
																		  for (LFMArtistChart *artist in [data artists]) {
																			  [artistNames addObject:[artist name]];
																		  }
																		  DDLogInfo(@"Initial Add: received Artists '%@'", artistNames);
																	  } else {
																		  DDLogError(@"Initial Add: charts %@", [error description]);
																	  }
																	  DDLogInfo(@"Initial Add: calling favingBlock");
																	  favingBlock(artistNames, NO);
																  }];
		
		// Setup a Timeout
		void (^timer)(void) = ^{
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (NSInteger)(kPASLastFmTimeoutInSec * 0.6 * NSEC_PER_SEC));
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				if ([task state] == NSURLSessionTaskStateRunning) {
					// Task is running too long, cancel it
					DDLogInfo(@"Cancelling getChartsTopArtists Request");
					[task cancel];
				}
			});
		};
		// Start the timer
		timer();
		
	} else {
		NSArray *topArtists = [PASMediaQueryAccessor sharedMngr].artistCollectionsOrderedByPlaycount;
		NSMutableArray *artistNames = [NSMutableArray arrayWithCapacity:3];
		int counter = 3;
		
		for (MPMediaItemCollection *artist in topArtists) {
			[artistNames addObject:[artist PAS_artistName]];
			counter--;
			if (counter == 0) {
				break;
			}
		}
		DDLogInfo(@"Initial Add: Music Artists '%@', calling favingBlock", artistNames);
		favingBlock(artistNames, YES);
	}
}

#pragma mark - Private Methods

- (NSString *)_resolveArtistName:(NSString *)name
{
	NSString *correctedName = [self _correctedArtistName:name];
	// this is mandatory as self.artistNameCorrections is initially empty
	return correctedName ? correctedName : name;
}

- (NSString *)_correctedArtistName:(NSString *)name
{
	// get corrected name
	// this might get a problem when artistNameCorrections is really big and loading from disk
	// takes a long time -> could result in artistNameCorrections being nil here!
	NSString __block *result = nil;
	dispatch_barrier_sync(self.favoritesQ, ^{
		result = [self.artistNameCorrections objectForKey:name];
	});
	return result;
}

- (PASArtist *)_artistForResolvedName:(NSString *)resolvedName
{
	if ([self.favArtistNames containsObject:resolvedName]) {
		return [self.favArtists objectAtIndex:[self.favArtistNames indexOfObject:resolvedName]];
	} else {
		return [self.justFavArtists objectAtIndex:[self.justFavArtistNames indexOfObject:resolvedName]];
	}
}

#pragma mark - Housholding

- (void)writeToDisk
{
	if (_artistNameCorrections) { // access directly to avoid initializing cache
		// save name corrections
		dispatch_barrier_sync(self.correctionsQ, ^{
			NSFileManager *mng = [NSFileManager defaultManager];
			NSURL *cacheDir = [[mng URLsForDirectory:NSApplicationSupportDirectory
										   inDomains:NSUserDomainMask] firstObject];
			NSURL *cacheFile = [cacheDir URLByAppendingPathComponent:NSStringFromClass([self class])];
			
			// make sure the cacheDir exists
			if (![mng fileExistsAtPath:[cacheDir path]
						   isDirectory:nil]) {
				NSError *err = nil;
				BOOL success = [mng createDirectoryAtURL:cacheDir
							 withIntermediateDirectories:YES
											  attributes:nil
												   error:&err];
				if (!success) {
					DDLogError(@"Cannot create cache dir (%@)", [err localizedDescription]);
				}
			}
			
			[self.artistNameCorrections writeToURL:cacheFile atomically:NO];
		});
	}
}

#pragma mark - dealloc

- (void)dealloc
{
	// Remove all observers
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIApplicationDidReceiveMemoryWarningNotification
												  object:nil];
	// Save cache
	[self writeToDisk];
}

@end
