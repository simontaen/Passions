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
#import "PASManageArtists.h"

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

@end

@implementation PASAddFromSamplesTVC

static NSString * const kPASPlaycountSectionIndex = @"playcount";
static CGFloat const kPASSectionHeaderHeight = 28;

#pragma mark - Init

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (!self) return nil;
	
	// register to receive already favorited artists
	[[NSNotificationCenter defaultCenter] addObserverForName:kPASSetFavArtists
													  object:nil queue:nil
												  usingBlock:^(NSNotification *note) {
													  // get fav artists from the notification
													  id obj = note.userInfo[kPASSetFavArtists];
													  NSAssert([obj isKindOfClass:[NSArray class]], @"kPASSetFavArtists must carry a NSArray");
													  [self _receiveFavArtists:(NSArray *)obj];
												  }];
	// Prepare the Manager
	[PASManageArtists sharedMngr];
	
	return self;
}

#pragma mark - Accessors

- (NSString *)title
{
	return @"Samples";
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
			return NSOrderedAscending;
		} else if (result < 0) {
			// The left operand is smaller than the right operand.
			return NSOrderedDescending;
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
	return [[PASManageArtists sharedMngr] didEditArtists];
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
}

- (void)_receiveFavArtists:(NSArray *)favArtists
{
	[[PASManageArtists sharedMngr] passFavArtists:favArtists];
	// refresh table view
	[self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[[PASManageArtists sharedMngr] writeToDisk];
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
		  isFavorite:[[PASManageArtists sharedMngr] isFavoriteArtist:artistName]
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
	
	// TODO: this is just plain ugly
	[[PASManageArtists sharedMngr] didSelectArtistWithName:[self nameForArtist:[self _artistForIndexPath:indexPath]]
												   cleanup:^{
													   [cell.activityIndicator stopAnimating];
													   cell.userInteractionEnabled = YES;
												   } reload:^{
													   [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
												   }
											  errorHandler:^(NSError *error) {
												  [self _handleError:error];
											  }];
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
			msg = @"The operation timed out.";
			break;
		default:
			msg = @"Something went wrong.";
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

@end
