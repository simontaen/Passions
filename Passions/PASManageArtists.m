//
//  PASManageArtists.m
//  Passions
//
//  Created by Simon Tännler on 21/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASManageArtists.h"
#import "PASArtist.h"
#import "MPMediaQuery+Passions.h"
#import "MPMediaItem+Passions.h"

@interface PASManageArtists()

#pragma mark - Faving Artists
// worker Q http://stackoverflow.com/a/5511403 / http://stackoverflow.com/a/13705529
@property (nonatomic, strong) dispatch_queue_t favoritesQ;

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
	
	// load name corrections
	self.correctionsQ = dispatch_queue_create("correctionsQ", DISPATCH_QUEUE_CONCURRENT);
	NSURL *cacheFile = [[[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory
																inDomains:NSUserDomainMask] firstObject]
						URLByAppendingPathComponent:NSStringFromClass([self class])];
	self.artistNameCorrections = [NSMutableDictionary dictionaryWithContentsOfURL:cacheFile];
	
	if (!self.artistNameCorrections) {
		self.artistNameCorrections = [NSMutableDictionary dictionary];
	}

	return self;
}

#pragma mark - Communication

- (void)passFavArtists:(NSArray *)favArtists
{
	self.justFavArtists = [NSMutableArray array];
	self.justFavArtistNames = [NSMutableArray array];
	
	self.favArtists = favArtists ? [NSMutableArray arrayWithArray:favArtists] : [NSMutableArray array];
	_originalFavArtists = [NSArray arrayWithArray:favArtists];
	
	self.favArtistNames = [[NSMutableArray alloc] initWithCapacity:favArtists.count];
	for (PASArtist *artist in favArtists) {
		[self.favArtistNames addObject:artist.name];
	}
}

- (BOOL)didEditArtists
{
	return self.justFavArtistNames.count != 0 || self.favArtists.count != self.originalFavArtists.count;
}

#pragma mark - Faving an Artist

- (void)didSelectArtistWithName:(NSString *)artistName cleanup:(void (^)())cleanup reload:(void (^)())reload errorHandler:(void (^)(NSError *error))errorHandler
{
	NSString *resolvedName = [self _resolveArtistName:artistName];
	
	if ([self isFavoriteArtist:artistName]) {
		PASArtist *artist = [self _artistForResolvedName:resolvedName];
		// The artist is favorited, a correctedName MUST exists
		NSAssert([self _correctedArtistName:artistName], @"The current Artist \"%@\" (%@) is favorited but has no corrected Name.", artistName, artist.objectId);
		
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
					
					dispatch_async(dispatch_get_main_queue(), ^{
						if (cleanup) {
							cleanup();
						}
						if (reload) {
							reload();
						}
					});
				});
				
			} else {
				dispatch_async(dispatch_get_main_queue(), ^{
					if (cleanup) {
						cleanup();
					}
					if (errorHandler) {
						errorHandler(error);
					}
				});
			}
		}];
		
		
	} else {
		[PASArtist favoriteArtistByCurrentUser:resolvedName
							   needsCorrection:![self _correctedArtistName:artistName]
									completion:^(PASArtist *artist, NSError *error) {
										if (artist && !error) {
											// get the finalized name on parse
											NSString *parseArtistName = artist.name;
											
											dispatch_barrier_async(self.correctionsQ, ^{
												// cache the mapping userDisplayed -> corrected
												[self.artistNameCorrections setObject:parseArtistName forKey:artistName];
											});
											
											dispatch_barrier_async(self.favoritesQ, ^{
												[self.justFavArtistNames addObject:parseArtistName];
												[self.justFavArtists addObject:artist];
												
												dispatch_async(dispatch_get_main_queue(), ^{
													if (cleanup) {
														cleanup();
													}
													if (reload) {
														reload();
													}
												});
											});
											
										} else {
											dispatch_async(dispatch_get_main_queue(), ^{
												if (cleanup) {
													cleanup();
												}
												if (errorHandler) {
													errorHandler(error);
												}
											});
										}
									}];
	}
}

- (BOOL)isFavoriteArtist:(NSString *)artistName
{
	NSString *resolvedName = [self _resolveArtistName:artistName];
	
	return [self.favArtistNames containsObject:resolvedName] || [self.justFavArtistNames containsObject:resolvedName];
}

- (void)addInitialFavArtists
{
	NSArray *topArtists = [MPMediaQuery PAS_orderedArtistsByPlaycount:[MPMediaQuery PAS_artistsQuery]];
	
	// this is called from the app delegate, make sure you're properly set up
	if (!self.originalFavArtists) {
		[self passFavArtists:@[]];
	}
	
	if (topArtists.count < 5 && [[topArtists firstObject] PAS_artistPlaycount] < 7) {
		NSLog(@"The user doesn't seem to use the Music App");
	}
	
	if (topArtists.count > 2) {
		int __block doneCounter = 0;
		
		for (int i = 0; i < 3; i++) {
			[self didSelectArtistWithName:[topArtists[i] PAS_artistName] cleanup:nil reload:^{
				doneCounter++;
				if (doneCounter == 3) {
					[[NSNotificationCenter defaultCenter] postNotificationName:kPASDidFavoriteInitialArtists object:nil];
				}
				
			} errorHandler:nil];
		}
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
	return [self.artistNameCorrections objectForKey:name];
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
	// save name corrections
	dispatch_barrier_async(self.correctionsQ, ^{
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
				NSLog(@"Cannot create cache dir (%@)", [err localizedDescription]);
			}
		}
		
		[self.artistNameCorrections writeToURL:cacheFile atomically:NO];
	});
}



@end
