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
													  self.artistNameCorrections = nil;
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
	
	if ([self isFavoriteArtist:artistName]) {
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
					
					[[NSNotificationCenter defaultCenter] postNotificationName:kPASDidEditArtistWithName
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
						   needsCorrection:![self _correctedArtistName:artistName]
							  originalName:artistName
								completion:myCompletion];
	}
}

- (void)_favoriteArtistByCurrentUser:(NSString *)resolvedName
					 needsCorrection:(BOOL)needsCorrection
						originalName:(NSString *)originalName
						  completion:(void (^)(NSError *error))completion
{
	[PASArtist favoriteArtistByCurrentUser:resolvedName
						   needsCorrection:needsCorrection
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
											
											[[NSNotificationCenter defaultCenter] postNotificationName:kPASDidEditArtistWithName
																								object:self
																							  userInfo:@{kPASDidEditArtistWithName : parseArtistName}];
											completion(nil);
										});
										
									} else {
										completion(error);
									}
								}];
}

- (BOOL)isFavoriteArtist:(NSString *)artistName
{
	NSString *resolvedName = [self _resolveArtistName:artistName];
	
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

- (void)addInitialFavArtists
{
	
	// this is called from the app delegate, make sure you're properly set up
	if (!self.originalFavArtists) {
		[self passFavArtists:@[]];
	}
	
	void (^favingBlock)(NSArray*) = ^void(NSArray *artistNames) {
		int __block doneCounter = 0;
		NSUInteger count = artistNames.count;
		
		for (NSString *artistName in artistNames) {
			[self didSelectArtistWithName:artistName completion:^(NSError *error) {
				doneCounter++;
				if (doneCounter == count) {
					[[NSNotificationCenter defaultCenter] postNotificationName:kPASDidFavoriteInitialArtists
																		object:nil];
				}
				if (error) {
					DDLogError(@"%@", [error description]);
				}
			}];
		}
	};
	
	if (![PASMediaQueryAccessor sharedMngr].usesMusicApp) {
		DDLogInfo(@"User \"%@\" doesn't seem to use the Music App", [PFUser currentUser].objectId);
		
		[[LastFmFetchr fetchr] getChartsTopArtists:nil
										 withLimit:3 completion:^(LFMChartTopArtists *data, NSError *error) {
											 NSMutableArray *artistNames = [NSMutableArray arrayWithCapacity:3];
											 if (data && !error) {
												 for (LFMArtistChart *artist in [data artists]) {
													 [artistNames addObject:[artist name]];
												 }
											 } else {
												 DDLogError(@"%@", [error description]);
											 }
											 favingBlock(artistNames);
										 }];
		
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
		favingBlock(artistNames);
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
	NSString __block *result;
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
