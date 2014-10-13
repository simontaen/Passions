//
//  PASAddFromSamplesTVC.m
//  Passions
//
//  Created by Simon Tännler on 04/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASAddFromSamplesTVC.h"
#import "PASArtist.h"
#import "PASArtistTVCell.h"
#import "FICImageCache.h"
#import "PASSourceImage.h"

@interface PASAddFromSamplesTVC ()
@property (nonatomic, strong) NSArray *artists; // of NSString
@property (nonatomic, strong) NSArray *sectionIndex; // NSString
@property (nonatomic, strong) NSDictionary *sections; // NSString -> NSMutableArray ( "C" -> @["Artist1", "Artist2"] )

@property (nonatomic, strong, readonly) NSArray* originalFavArtists; // of PASArtist, passed by the segue, LFM Corrected!
@property (nonatomic, strong, readonly) NSMutableArray* favArtistNames; // of NSString, passed by the segue, LFM Corrected!

// http://stackoverflow.com/a/5511403 / http://stackoverflow.com/a/13705529
@property (nonatomic, strong) NSMutableArray* justFavArtistNames; // of NSString, LFM corrected!
@property (nonatomic, strong) NSMutableArray* justFavArtists; // of PASArtist
@property (nonatomic, strong) dispatch_queue_t favoritesQ;

@property (nonatomic, strong) NSMutableDictionary* artistNameCorrections; // of NSString (display) -> NSString (internal on Favorite Artists TVC, LFM corrected)
@property (nonatomic, strong) dispatch_queue_t correctionsQ;

@end

@implementation PASAddFromSamplesTVC

#pragma mark - Accessors

- (NSString *)title
{
	return @"Samples";
}

// returns the proper objects
- (NSArray *)artists
{
	if (!_artists) {
		//_artists = @[@"Beatles", @"AC/DC", @"Pink Floid", @"Guns 'n roses"];
		//_artists = @[@"Deadmouse"];
		_artists = [@[
					  @"Beatles", @"Air", @"Pink Floid", @"Rammstein", @"Bloodhound Gang",
					  @"Ancien Régime", @"Genius/GZA ", @"Belle & Sebastian", @"Björk",
					  @"Ugress", @"ADELE", @"The Asteroids Galaxy Tour", @"Bar 9",
					  @"Baskerville", @"Beastie Boys", @"Bee Gees", @"Bit Shifter",
					  @"Bomfunk MC's", @"C-Mon & Kypski", @"The Cardigans", @"Carly Commando",
					  @"Caro Emerald", @"Coldplay", @"Coolio", @"Cypress Hill",
					  @"David Bowie", @"Dukes of Stratosphear", @"[dunkelbunt]",
					  @"Eminem", @"Enigma", @"Deadmouse", @"ACDC", @"Quiet Riot"
					  ] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	};
	return _artists;
}

- (void)setFavArtists:(NSMutableArray *)favArtists
{
	_favArtists = favArtists;
	_originalFavArtists = [NSArray arrayWithArray:favArtists];
	_favArtistNames = [[NSMutableArray alloc] initWithCapacity:favArtists.count];
	
	for (PASArtist *artist in favArtists) {
		[_favArtistNames addObject:artist.name];
	}
}

- (NSString *)nameForArtist:(id)artist
{
	NSAssert([artist isKindOfClass:[NSString class]], @"%@ cannot handle artists of class %@", NSStringFromClass([self class]), NSStringFromClass([artist class]));
	return artist;
}

- (id)artistForIndexPath:(NSIndexPath *)indexPath
{
	return self.sections[self.sectionIndex[indexPath.section]][indexPath.row];
}

- (NSArray *)sectionIndex
{
	if (!_sectionIndex) {
		NSMutableArray *array = [[self.sections allKeys] mutableCopy];
		BOOL containsNonAlphabetic = [array containsObject:@"#"];
		if (containsNonAlphabetic) {
			[array removeObject:@"#"];
		}
		[array sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
		if (containsNonAlphabetic) {
			[array addObject:@"#"];
		}
		_sectionIndex = [NSArray arrayWithArray:array];
	}
	return _sectionIndex;
}

- (NSDictionary *)sections
{
	// TODO: rethink the A-Z scrubber, should it always show the complete alphabet?
	// TODO: the scrubber seems to blocks the pan gesture
	if (!_sections) {
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
		_sections = [NSDictionary dictionaryWithDictionary:mutableSections];
	}
	return _sections;
}

- (BOOL)didEditArtists
{
	return self.justFavArtistNames.count != 0 || self.favArtists.count != self.originalFavArtists.count;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.tableView registerNib:[UINib nibWithNibName:[PASArtistTVCell reuseIdentifier] bundle:nil]
		 forCellReuseIdentifier:[PASArtistTVCell reuseIdentifier]];
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
	
	id artist = [self artistForIndexPath:indexPath];
	NSString *artistName = [self nameForArtist:artist];
	
	[cell showArtist:artist withName:artistName isFavorite:[self _isFavoriteArtist:artistName]];
	
	return cell;
}

#pragma mark - UITableViewDataSource Index

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return self.sectionIndex.count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	return self.sectionIndex;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	return index;
}

#pragma mark - UITableViewDataSource Header

static CGFloat const kSectionHeaderHeight = 28;

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, kSectionHeaderHeight)];
	view.backgroundColor = [UIColor whiteColor];
 
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableView.frame.size.width, kSectionHeaderHeight)];
	label.text = self.sectionIndex[section];
	label.textColor = [UIColor darkTextColor];
	[view addSubview:label];
 
	return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return kSectionHeaderHeight;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	PASArtistTVCell *cell = (PASArtistTVCell *)[tableView cellForRowAtIndexPath:indexPath];
	cell.userInteractionEnabled = NO;
	[cell.activityIndicator startAnimating];
	
	NSString *artistName = [self nameForArtist:[self artistForIndexPath:indexPath]];
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
					[self handleError:error];
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
					[self handleError:error];
				});
			}
		}];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 50;
}

#pragma mark - Error Handling

- (void)handleError:(NSError *)error
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
