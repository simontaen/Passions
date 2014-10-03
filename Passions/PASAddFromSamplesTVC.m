//
//  PASAddFromSamplesTVC.m
//  Passions
//
//  Created by Simon Tännler on 04/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASAddFromSamplesTVC.h"
#import "PASArtist.h"
#import "PASAddingArtistCell.h"

static NSString *kCellIdentifier = @"PASAddingArtistCell";

@interface PASAddFromSamplesTVC ()
@property (nonatomic, strong) NSArray *artists; // of NSString
@property (nonatomic, strong) NSArray *sectionIndex; // NSString
@property (nonatomic, strong) NSDictionary *sections; // NSString -> NSMutableArray ( "C" -> @["Artist1", "Artist2"] )


// http://stackoverflow.com/a/5511403 / http://stackoverflow.com/a/13705529
@property (nonatomic, strong) NSMutableArray* justFavArtistNames; // of NSString, LFM corrected!
@property (nonatomic, strong) dispatch_queue_t favoritesQ;

@property (nonatomic, strong) NSMutableDictionary* artistNameCorrections; // of NSString (display) -> NSString (internal on Favorite Artists TVC, LFM corrected)
@property (nonatomic, strong) dispatch_queue_t correctionsQ;

@end

@implementation PASAddFromSamplesTVC

#pragma mark - Accessors

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

- (NSString *)nameForArtist:(id)artist
{
	NSAssert([artist isKindOfClass:[NSString class]], @"%@ cannot handle artists of class %@", NSStringFromClass([self class]), NSStringFromClass([artist class]));
	;
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

- (BOOL)didAddArtists
{
	return self.justFavArtistNames.count != 0;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self.tableView registerNib:[UINib nibWithNibName:kCellIdentifier bundle:nil] forCellReuseIdentifier:kCellIdentifier];
	
	// setup artists to choose from, for example
	// go to spotify, last.fm or prepare MediaQuery
	// maybe read cache when network is involved? or let AFNetworking handle it?
}

- (NSString *)getTitle
{
	return @"Samples";
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.parentViewController setTitle:[self getTitle]];
	
	// perpare for user favoriting artists
	self.favoritesQ = dispatch_queue_create("favoritesQ", DISPATCH_QUEUE_CONCURRENT);
	self.justFavArtistNames = [[NSMutableArray alloc] initWithCapacity:(int)(self.artists.count / 4)];
	
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

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	//[PASResources printViewControllerLayoutStack:self];
	//[PASResources printViewLayoutStack:self];
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
	PASAddingArtistCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
	
	NSString *artistName = [self nameForArtist:[self artistForIndexPath:indexPath]];
	cell.artistName.text = artistName;
	
	if ([self _isFavoriteArtist:artistName]) {
		cell.detailText.text = @"Favorite!";
	} else {
		cell.detailText.text = @"";
	}
	
	[self setThumbnailImageForCell:cell atIndexPath:indexPath];
	
	return cell;
}

- (void)setThumbnailImageForCell:(PASAddingArtistCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	cell.artistImage.image = [PASResources artistThumbnailPlaceholder];
	return;
}

- (BOOL)_isFavoriteArtist:(NSString *)artistName
{
	// get corrected name
	// this might get a problem when artistNameCorrections is really big and loading from disk
	// takes a long time -> could result in artistNameCorrections being nil here!
	NSString *correctedName = [self.artistNameCorrections objectForKey:artistName];
	// this is mandatory as self.artistNameCorrections is initially empty
	NSString *resolvedName = correctedName ? correctedName : artistName;
	
	return [self.favArtistNames containsObject:resolvedName] || [self.justFavArtistNames containsObject:resolvedName];
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

#pragma mark - UITableViewDataSource Header/Footer Titles

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return self.sectionIndex[section];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	PASAddingArtistCell *cell = (PASAddingArtistCell *)[tableView cellForRowAtIndexPath:indexPath];
	cell.userInteractionEnabled = NO;
	[cell.activityIndicator startAnimating];
	
	NSString *artistName = [self nameForArtist:[self artistForIndexPath:indexPath]];
	NSString *correctedName = [self.artistNameCorrections objectForKey:artistName];
	NSString *resolvedName = correctedName ?: artistName;
	
	// check if adding possible
	// -> current Installation must exist
	
	[PASArtist favoriteArtistByCurrentUser:resolvedName withBlock:^(PASArtist *artist, NSError *error) {
		if (artist && !error) {
			// get the finalized name on parse
			NSString *parseArtistName = artist.name;
			
			dispatch_barrier_async(self.correctionsQ, ^{
				// cache the mapping userDisplayed -> corrected
				[self.artistNameCorrections setObject:parseArtistName forKey:artistName];
			});
			
			dispatch_barrier_async(self.favoritesQ, ^{
				[self.justFavArtistNames addObject:parseArtistName];
				
				dispatch_async(dispatch_get_main_queue(), ^{
					[cell.activityIndicator stopAnimating];
					cell.userInteractionEnabled = YES;
					[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
				});
			});
		}
	}];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 50;
}

@end
