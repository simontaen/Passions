//
//  PASAddFromSamplesTVC.m
//  Passions
//
//  Created by Simon Tännler on 04/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASAddFromSamplesTVC.h"
#import "PASFavArtistsTVC.h"
#import "PASArtist.h"
#import "PASArtistTVCell.h"
#import "FICImageCache.h"
#import "PASSourceImage.h"

typedef NS_ENUM(NSUInteger, PASAddArtistsSortOrder) {
	PASAddArtistsSortOrderAlphabetical,
	PASAddArtistsSortOrderByPlaycount
};

@interface PASAddFromSamplesTVC ()

#pragma mark - Sections
@property (nonatomic, assign) PASAddArtistsSortOrder selectedSortOrder;

// Accessors that know which sort order is used and cache the results
@property (nonatomic, strong, readonly) NSArray *artists; // of the appropriate object
@property (nonatomic, strong, readonly) NSArray *sectionIndex; // NSString
@property (nonatomic, strong, readonly) NSDictionary *sections; // NSString -> NSMutableArray ( "C" -> @["Artist1", "Artist2"] )

@property (nonatomic, strong) NSArray *cachedArtistsOrderedByName;
@property (nonatomic, strong) NSArray *cachedAlphabeticalSectionIndex;
@property (nonatomic, strong) NSDictionary *cachedAlphabeticalSections;

@property (nonatomic, strong) NSArray *cachedArtistsOrderedByPlaycout;
@property (nonatomic, strong) NSArray *cachedPlaycountSectionIndex;
@property (nonatomic, strong) NSDictionary *cachedPlaycountSections;

// cache of artists, unordered (The Model of this class)
@property (nonatomic, strong) NSArray *sampleArtists; // NSString

#pragma mark - Faving Artists
// worker Q http://stackoverflow.com/a/5511403 / http://stackoverflow.com/a/13705529
@property (nonatomic, strong) dispatch_queue_t favoritesQ;

// passed by the segue, LFM Corrected!
@property (nonatomic, strong, readonly) NSArray* originalFavArtists; // PASArtist, never changed
// these contain current changes
@property (nonatomic, strong) NSMutableArray* favArtists; // PASArtist
@property (nonatomic, strong, readonly) NSMutableArray* favArtistNames; // NSString, built based on favArtists

// for newly favorited artists
@property (nonatomic, strong) NSMutableArray* justFavArtists; // PASArtist
@property (nonatomic, strong) NSMutableArray* justFavArtistNames; // NSString, LFM corrected!

#pragma mark - Corrections
@property (nonatomic, strong) NSMutableDictionary* artistNameCorrections; // NSString (display) -> NSString (internal on Favorite Artists TVC, LFM corrected)
@property (nonatomic, strong) dispatch_queue_t correctionsQ;

@end

@implementation PASAddFromSamplesTVC

static NSString * const kPASPlaycountSectionIndex = @"playcount";
static CGFloat const kPASSectionHeaderHeight = 28;

#pragma mark - Accessors

- (NSString *)title
{
	return @"Samples";
}

- (void)setFavArtists:(NSMutableArray *)favArtists
{
	_favArtists = favArtists ? favArtists : [NSMutableArray array];
	_originalFavArtists = [NSArray arrayWithArray:favArtists];
	_favArtistNames = [[NSMutableArray alloc] initWithCapacity:favArtists.count];
	
	for (PASArtist *artist in favArtists) {
		[_favArtistNames addObject:artist.name];
	}
}

- (NSArray *)sampleArtists
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sampleArtists = @[
						   @"Beatles", @"Air", @"Pink Floid", @"Rammstein", @"Bloodhound Gang",
						   @"Ancien Régime", @"Genius/GZA ", @"Belle & Sebastian", @"Björk",
						   @"Ugress", @"ADELE", @"The Asteroids Galaxy Tour", @"Bar 9",
						   @"Baskerville", @"Beastie Boys", @"Bee Gees", @"Bit Shifter",
						   @"Bomfunk MC's", @"C-Mon & Kypski", @"The Cardigans", @"Carly Commando",
						   @"Caro Emerald", @"Coldplay", @"Coolio", @"Cypress Hill",
						   @"David Bowie", @"Dukes of Stratosphear", @"[dunkelbunt]",
						   @"Eminem", @"Enigma", @"Deadmouse", @"ACDC", @"Quiet Riot"
						   ];
	});
	return _sampleArtists;
}

- (NSArray *)artists
{
	switch (self.selectedSortOrder) {
		case PASAddArtistsSortOrderAlphabetical:
			if (!self.cachedArtistsOrderedByName) {
				self.cachedArtistsOrderedByName = [self artistsOrderedByName];
			}
			return self.cachedArtistsOrderedByName;
		default:
			if (!self.cachedArtistsOrderedByPlaycout) {
				self.cachedArtistsOrderedByPlaycout = [self artistsOrderedByPlaycout];
			}
			return self.cachedArtistsOrderedByPlaycout;
	}
}

// will be implemented by subclass
- (NSArray *)artistsOrderedByName
{
	return [self.sampleArtists sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

// will be implemented by subclass
- (NSArray *)artistsOrderedByPlaycout
{
	return [self.sampleArtists sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		NSInteger result = [self playcountForArtist:obj1] - [self playcountForArtist:obj2];
		
		if (result > 0) {
			// The left operand is greater than the right operand.
			return NSOrderedDescending;
		} else if (result < 0) {
			// The left operand is smaller than the right operand.
			return NSOrderedAscending;
		}
		return NSOrderedSame;
	}];
}

- (NSArray *)sectionIndex
{
	switch (self.selectedSortOrder) {
		case PASAddArtistsSortOrderAlphabetical:
			if (!self.cachedAlphabeticalSectionIndex) {
				self.cachedAlphabeticalSectionIndex = [self _alphabeticalSectionIndex];
			}
			return self.cachedAlphabeticalSectionIndex;
		default:
			if (!self.cachedPlaycountSectionIndex) {
				self.cachedPlaycountSectionIndex = [self _playcountSectionIndex];
			}
			return self.cachedPlaycountSectionIndex;
	}
}

- (NSArray *)_alphabeticalSectionIndex
{
	NSMutableArray *array = [[self.sections allKeys] mutableCopy];
	BOOL containsNonAlphabetic = [array containsObject:@"#"];
	if (containsNonAlphabetic) {
		[array removeObject:@"#"];
	}
	[array sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	if (containsNonAlphabetic) {
		[array addObject:@"#"];
	}
	return [NSArray arrayWithArray:array];
}

- (NSArray *)_playcountSectionIndex
{
	return @[kPASPlaycountSectionIndex];
}

- (NSDictionary *)sections
{
	// TODO: rethink the A-Z scrubber, should it always show the complete alphabet?
	// TODO: the scrubber seems to blocks the pan gesture
	switch (self.selectedSortOrder) {
		case PASAddArtistsSortOrderAlphabetical:
			if (!self.cachedAlphabeticalSections) {
				self.cachedAlphabeticalSections = [self _alphabeticalSections];
			}
			return self.cachedAlphabeticalSections;
		default:
			if (!self.cachedPlaycountSections) {
				self.cachedPlaycountSections = [self _playcountSections];
			}
			return self.cachedPlaycountSections;
	}
}

- (NSDictionary *)_alphabeticalSections
{
	NSArray *index = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M",
					   @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"#"];
	NSMutableDictionary *mutableSections = [[NSMutableDictionary alloc] initWithCapacity:index.count];
	
	for (id artist in self.artists) {
		NSString *name = [self nameForArtist:artist];
		NSString *firstChar = [[name substringToIndex:1] uppercaseString];
		
		if (![index containsObject:firstChar]) {
			// add it to the last element of the index
			firstChar = [index lastObject];
		}
		
		NSMutableArray *array = mutableSections[firstChar];
		if (!array) {
			array = [NSMutableArray array];
			mutableSections[firstChar] = array;
		}
		
		[array addObject:artist];
	}
	return [NSDictionary dictionaryWithDictionary:mutableSections];
}

- (NSDictionary *)_playcountSections
{
	NSAssert(self.artists, @"Can't have nil artists");
	return @{ kPASPlaycountSectionIndex : self.artists };
}

#pragma mark - Subclassing

- (BOOL)didEditArtists
{
	return self.justFavArtistNames.count != 0 || self.favArtists.count != self.originalFavArtists.count;
}

- (NSString *)nameForArtist:(id)artist
{
	NSAssert([artist isKindOfClass:[NSString class]], @"%@ cannot get name for artists of class %@", NSStringFromClass([self class]), NSStringFromClass([artist class]));
	return artist;
}

- (NSUInteger)playcountForArtist:(id)artist
{
	NSAssert([artist isKindOfClass:[NSString class]], @"%@ cannot get playcount for artists of class %@", NSStringFromClass([self class]), NSStringFromClass([artist class]));
	return ((NSString *)artist).length;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// register the custom cell
	[self.tableView registerNib:[UINib nibWithNibName:[PASArtistTVCell reuseIdentifier] bundle:nil]
		 forCellReuseIdentifier:[PASArtistTVCell reuseIdentifier]];
	
	// default is alphabetical
	self.selectedSortOrder = PASAddArtistsSortOrderAlphabetical;
	
	// register to receive already favorited artists
	[[NSNotificationCenter defaultCenter] addObserverForName:kPASSetFavArtists
													  object:nil queue:nil
												  usingBlock:^(NSNotification *note) {
													  // get fav artists from the notification
													  id obj = note.userInfo[kPASSetFavArtists];
													  NSAssert([obj isKindOfClass:[NSMutableArray class]], @"kPASSetFavArtists must carry a NSMutableArray");
													  self.favArtists = (NSMutableArray *)obj;
												  }];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// perpare for user favoriting artists
	self.favoritesQ = dispatch_queue_create("favoritesQ", DISPATCH_QUEUE_CONCURRENT);
	self.justFavArtistNames = [[NSMutableArray alloc] initWithCapacity:(int)(self.artists.count / 4)];
	self.justFavArtists = [[NSMutableArray alloc] initWithCapacity:(int)(self.artists.count / 4)];
	
	// load name corrections
	self.correctionsQ = dispatch_queue_create("correctionsQ", DISPATCH_QUEUE_CONCURRENT);
	dispatch_async(self.correctionsQ, ^{
		NSURL *cacheFile = [[[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory
																	inDomains:NSUserDomainMask] firstObject]
							URLByAppendingPathComponent:NSStringFromClass([self class])];
		self.artistNameCorrections = [NSMutableDictionary dictionaryWithContentsOfURL:cacheFile];
		
		if (!self.artistNameCorrections) {
			self.artistNameCorrections = [[NSMutableDictionary alloc] initWithCapacity:self.artists.count];
		}
	});
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
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

#pragma mark - UITableViewDataSource required

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sections[self.sectionIndex[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	PASArtistTVCell *cell = [tableView dequeueReusableCellWithIdentifier:[PASArtistTVCell reuseIdentifier] forIndexPath:indexPath];
	
	id artist = [self _artistForIndexPath:indexPath];
	NSString *artistName = [self nameForArtist:artist];
	
	[cell showArtist:artist withName:artistName
		  isFavorite:[self _isFavoriteArtist:artistName]
		   playcount:[self playcountForArtist:artist]];
	
	return cell;
}

#pragma mark - UITableViewDataSource Index

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return self.sectionIndex.count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	switch (self.selectedSortOrder) {
		case PASAddArtistsSortOrderAlphabetical:
			return self.sectionIndex;
		default:
			return nil;
	}
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	return index;
}

#pragma mark - UITableViewDataSource Header

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	switch (self.selectedSortOrder) {
		case PASAddArtistsSortOrderAlphabetical:
			return [self tableView:tableView _viewForHeaderInAlphabeticalSection:section];
		default:
			return nil;
	}
}

- (UIView *)tableView:(UITableView *)tableView _viewForHeaderInAlphabeticalSection:(NSInteger)section
{
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, kPASSectionHeaderHeight)];
	view.backgroundColor = [UIColor whiteColor];
 
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width, kPASSectionHeaderHeight)];
	label.text = self.sectionIndex[section];
	label.textColor = [UIColor darkTextColor];
	[view addSubview:label];
 
	return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	switch (self.selectedSortOrder) {
		case PASAddArtistsSortOrderAlphabetical:
			return kPASSectionHeaderHeight;
		default:
			return 0;
	}
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	PASArtistTVCell *cell = (PASArtistTVCell *)[tableView cellForRowAtIndexPath:indexPath];
	cell.userInteractionEnabled = NO;
	[cell.activityIndicator startAnimating];
	
	NSString *artistName = [self nameForArtist:[self _artistForIndexPath:indexPath]];
	NSString *resolvedName = [self _resolveArtistName:artistName];
	
	void (^cleanup)() = ^{
		[cell.activityIndicator stopAnimating];
		cell.userInteractionEnabled = YES;
	};
	
	if ([self _isFavoriteArtist:artistName]) {
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
						cleanup();
						[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
					});
				});
				
			} else {
				dispatch_async(dispatch_get_main_queue(), ^{
					cleanup();
					[self _handleError:error];
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
						cleanup();
						[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
					});
				});
				
			} else {
				dispatch_async(dispatch_get_main_queue(), ^{
					cleanup();
					[self _handleError:error];
				});
			}
		}];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 50;
}

#pragma mark - Ordering, UISegmentedControl Action

- (IBAction)segmentChanged:(UISegmentedControl *)sender
{
	switch ([sender selectedSegmentIndex]) {
		case 0:
			self.selectedSortOrder = PASAddArtistsSortOrderAlphabetical;
			break;
		default:
			self.selectedSortOrder = PASAddArtistsSortOrderByPlaycount;
			break;
	}
	
	[self _refreshUI];
}

#pragma mark - Error Handling

- (void)_handleError:(NSError *)error
{
	NSLog(@"%@", [error localizedDescription]);

	NSString *msg;
	switch (error.code) {
		case 141:
			msg = @"The operation timed out";
			break;
		default:
			msg = [error localizedDescription];
			break;
	}
	
	UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Try Again"
																   message:msg
															preferredStyle:UIAlertControllerStyleAlert];
	
	UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
															style:UIAlertActionStyleDefault
														  handler:^(UIAlertAction * action) {
															  [alert dismissViewControllerAnimated:YES completion:nil];
														  }];
	[alert addAction:defaultAction];
	
	[self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Private Methods

- (id)_artistForIndexPath:(NSIndexPath *)indexPath
{
	return self.sections[self.sectionIndex[indexPath.section]][indexPath.row];
}

- (void)_refreshUI
{
	[self.tableView reloadData];
}

- (BOOL)_isFavoriteArtist:(NSString *)artistName
{
	NSString *resolvedName = [self _resolveArtistName:artistName];
	
	return [self.favArtistNames containsObject:resolvedName] || [self.justFavArtistNames containsObject:resolvedName];
}

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

@end
