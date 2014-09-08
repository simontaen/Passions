//
//  PASAddFromSamplesTVC.m
//  Passions
//
//  Created by Simon Tännler on 04/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASAddFromSamplesTVC.h"
#import "PFArtist.h"
#import "LastFmFetchr.h"
#import "PASResources.h"

@interface PASAddFromSamplesTVC ()
@property (nonatomic, strong) NSArray* artists; // of NSString
@property (nonatomic, strong) NSArray* artistNames; // of NSString

// http://stackoverflow.com/a/5511403 / http://stackoverflow.com/a/13705529
@property (nonatomic, strong) NSMutableArray* justFavArtistNames; // of NSString, LFM corrected!
@property (nonatomic, strong) dispatch_queue_t favoritesQ;

@property (nonatomic, strong) NSMutableDictionary* artistNameCorrections; // of NSString (display) -> NSString (internal on Favorite Artists TVC)
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

- (NSArray *)artistNames
{
	if (!_artistNames) {
		_artistNames = self.artists;
	}
	return _artistNames;
}

- (BOOL)didAddArtists
{
	return self.justFavArtistNames.count != 0;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setTitle:@"Samples"];
	
	// setup artists to choose from, for example
	// go to spotify, last.fm or prepare MediaQuery
	// maybe read cache when network is involved? or let AFNetworking handle it?
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
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
	[PASResources printViewControllerLayoutStack:self];
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
		
		[self.artistNameCorrections writeToURL:cacheFile atomically:@NO];
	});
}

#pragma mark - UITableViewDataSource required

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.artists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"ArtistCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	
	NSString *artistName = self.artistNames[indexPath.row];
	cell.textLabel.text = artistName;
	
	if ([self isFavoriteArtist:artistName]) {
		cell.detailTextLabel.text = @"Favorite!";
	} else {
		cell.detailTextLabel.text = nil;
	}
	
	[self setThumbnailImageForCell:cell atIndexPath:indexPath];
	
	return cell;
}

- (void)setThumbnailImageForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
	cell.imageView.image = nil;
	return;
}

- (BOOL)isFavoriteArtist:(NSString *)artistName
{
	// get corrected name
	// this might get a problem when artistNameCorrections is really big and loading from disk
	// takes a long time -> could result in artistNameCorrections being nil here!
	NSString *correctedName = [self.artistNameCorrections objectForKey:artistName];
	// this is mandatory as self.artistNameCorrections is initially empty
	NSString *resolvedName = correctedName ? correctedName : artistName;
	
	return [self.favArtistNames containsObject:resolvedName] || [self.justFavArtistNames containsObject:resolvedName];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *artistName = self.artistNames[indexPath.row];
	NSString *correctedName = [self.artistNameCorrections objectForKey:artistName];
	
	// TODO: grey out the row and put a spinner on it
	// disable user interaction
	
	if (correctedName) {
		[self favoriteArtist:correctedName atIndexPath:indexPath];
		
	} else {
		// artistName is straight from what this TVC displays, needs correction
		[[LastFmFetchr fetchr] getCorrectionForArtist:artistName completion:^(LFMArtist *data, NSError *error) {
			if (!error) {
				// now get the corrected name and cache it!
				NSString *resolvedName = data ? data.name : artistName;
				dispatch_barrier_async(self.correctionsQ, ^{
					[self.artistNameCorrections setObject:resolvedName forKey:artistName];
				});
				
				// favorite the artist with the corrected name
				// TODO: maybe this means I don't have to do the correction on the server!
				[self favoriteArtist:resolvedName atIndexPath:indexPath];
			}
		}];
	}
}

- (void)favoriteArtist:(NSString *)name atIndexPath:(NSIndexPath *)indexPath
{
	[PFArtist favoriteArtistByCurrentUser:name withBlock:^(PFArtist *artist, NSError *error) {
		if (artist && !error) {
			dispatch_barrier_async(self.favoritesQ, ^{
				[self.justFavArtistNames addObject:name];
				dispatch_async(dispatch_get_main_queue(), ^{
					[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
				});
			});
		}
	}];
}

@end
