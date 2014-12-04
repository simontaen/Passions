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
#import "PASSourceImage.h"
#import "PASManageArtists.h"
#import "UIColor+Utils.h"
#import "PASPageViewController.h"
#import "PASExtendedNavContainer.h"
#import "MBProgressHUD.h"

@interface PASAddFromSamplesTVC ()

#pragma mark - Sections
// Current Sort order
@property (nonatomic, assign) PASAddArtistsSortOrder selectedSortOrder;

// Accessors that know which sort order is used and cache the results
@property (nonatomic, strong, readonly) NSArray *_artistsShorthand; // of the appropriate object
@property (nonatomic, strong, readonly) NSArray *_sectionIndexShorthand; // NSString
@property (nonatomic, strong, readonly) NSDictionary *_sectionsShorthand; // NSString -> NSMutableArray ( "C" -> @["Artist1", "Artist2"] )

@property (nonatomic, strong) NSArray *cachedArtistsOrderedByName;
@property (nonatomic, strong) NSArray *cachedAlphabeticalSectionIndex;
@property (nonatomic, strong) NSDictionary *cachedAlphabeticalSections;

@property (nonatomic, strong) NSArray *cachedArtistsOrderedByPlaycount;
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
	
	// Prepare the Manager
	[PASManageArtists sharedMngr];
	
	// Detail Text Formatting
	__weak typeof(self) weakSelf = self;
	self.detailTextBlock = ^NSString *(id<FICEntity> artist, NSString *name) {
		NSUInteger charcount = [weakSelf playcountForArtist:artist withName:name];
		if (charcount == 1) {
			return [NSString stringWithFormat:@"%lu Character", (unsigned long)charcount];
		} else {
			return [NSString stringWithFormat:@"%lu Characters", (unsigned long)charcount];
		}
	};
	
	return self;
}

#pragma mark - Accessors

- (NSString *)title
{
	return @"Suggestions";
}

- (NSArray *)sampleArtists
{
	if (!_sampleArtists) {
		_sampleArtists = @[
						   @"Beatles", @"Air", @"Pink Floid", @"Rammstein", @"Bloodhound Gang",
						   @"Ancien Régime", @"Genius/GZA ", @"Belle & Sebastian", @"Björk", @"Quiet Riot",
						   @"Ugress", @"ADELE", @"The Asteroids Galaxy Tour", @"Bar 9", @"Jennifer Rostock",
						   @"Baskerville", @"Beastie Boys", @"Bee Gees", @"Bit Shifter", @"Garth Brooks",
						   @"Bomfunk MC's", @"C-Mon & Kypski", @"The Cardigans", @"Carly Commando",
						   @"Caro Emerald", @"Coldplay", @"Coolio", @"Cypress Hill", @"AC/DC", @"Metallica",
						   @"David Bowie", @"Dukes of Stratosphear", @"[dunkelbunt]", @"Cause Assertion Error!",
						   @"Eminem", @"Enigma", @"Deadmouse", @"ACDC", @"Crash the App!"
						   ];
	}
	return _sampleArtists;
}

- (NSArray *)_artistsShorthand
{
	switch (self.selectedSortOrder) {
		case PASAddArtistsSortOrderAlphabetical:
			if (!self.cachedArtistsOrderedByName || self.cachedArtistsOrderedByName.count == 0) {
				self.cachedArtistsOrderedByName = [self artistsOrderedByName];
			}
			return self.cachedArtistsOrderedByName;
		default:
			if (!self.cachedArtistsOrderedByPlaycount || self.cachedArtistsOrderedByPlaycount.count == 0) {
				self.cachedArtistsOrderedByPlaycount = [self artistsOrderedByPlaycount];
			}
			return self.cachedArtistsOrderedByPlaycount;
	}
}

// will be implemented by subclass
- (NSArray *)artistsOrderedByName
{
	return [self.sampleArtists sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

// will be implemented by subclass
- (NSArray *)artistsOrderedByPlaycount
{
	return [self.sampleArtists sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		NSInteger result = [self playcountForArtist:obj1 withName:obj1] - [self playcountForArtist:obj2 withName:obj2];
		
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

- (NSArray *)_sectionIndexShorthand
{
	switch (self.selectedSortOrder) {
		case PASAddArtistsSortOrderAlphabetical:
			if (!self.cachedAlphabeticalSectionIndex || self.cachedAlphabeticalSectionIndex.count == 0) {
				self.cachedAlphabeticalSectionIndex = [self _alphabeticalSectionIndex];
			}
			return self.cachedAlphabeticalSectionIndex;
		default:
			if (!self.cachedPlaycountSectionIndex || self.cachedPlaycountSectionIndex.count == 0) {
				self.cachedPlaycountSectionIndex = [self _playcountSectionIndex];
			}
			return self.cachedPlaycountSectionIndex;
	}
}

- (NSArray *)_alphabeticalSectionIndex
{
	NSMutableArray *array = [[self._sectionsShorthand allKeys] mutableCopy];
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

- (NSDictionary *)_sectionsShorthand
{
	switch (self.selectedSortOrder) {
		case PASAddArtistsSortOrderAlphabetical:
			if (!self.cachedAlphabeticalSections || self.cachedAlphabeticalSections.count == 0) {
				self.cachedAlphabeticalSections = [self _alphabeticalSections];
			}
			return self.cachedAlphabeticalSections;
		default:
			if (!self.cachedPlaycountSections || self.cachedPlaycountSections.count == 0) {
				self.cachedPlaycountSections = [self _playcountSections];
			}
			return self.cachedPlaycountSections;
	}
}

- (NSDictionary *)_alphabeticalSections
{
	NSArray *index = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M",
					   @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @"#"];
	NSMutableDictionary *mutableSections = [NSMutableDictionary dictionaryWithCapacity:index.count];
	
	for (id artist in self._artistsShorthand) {
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
	NSAssert(self._artistsShorthand, @"Can't have nil artists");
	return @{ kPASPlaycountSectionIndex : self._artistsShorthand };
}

#pragma mark - Subclassing

- (NSString *)nameForArtist:(id)artist
{
	NSAssert([artist isKindOfClass:[NSString class]], @"%@ cannot get name for artists of class %@", NSStringFromClass([PASAddFromSamplesTVC class]), NSStringFromClass([artist class]));
	return artist;
}

- (NSUInteger)playcountForArtist:(id)artist withName:(NSString *)name
{
	NSAssert([artist isKindOfClass:[NSString class]], @"%@ cannot get playcount for artists of class %@", NSStringFromClass([PASAddFromSamplesTVC class]), NSStringFromClass([artist class]));
	return name.length;
}

- (UIColor *)chosenTintColor
{
	return [UIColor defaultTintColor];
}

- (NSString *)sortOrderDescription:(PASAddArtistsSortOrder)sortOrder
{
	switch (sortOrder) {
		case PASAddArtistsSortOrderAlphabetical:
			return @"alphabetical";
		default:
			return @"by name length ;)";
	}
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// register the custom cell
	[self.tableView registerNib:[UINib nibWithNibName:[PASArtistTVCell reuseIdentifier] bundle:nil]
		 forCellReuseIdentifier:[PASArtistTVCell reuseIdentifier]];
	
	// TableView Properties
	self.tableView.allowsSelection = NO;
	self.tableView.separatorInset = UIEdgeInsetsMake(0, kPASSizeArtistThumbnailSmall + 4, 0, 0);
	self.tableView.separatorColor = [UIColor tableViewSeparatorColor];
	
	// default is alphabetical
	self.selectedSortOrder = PASAddArtistsSortOrderAlphabetical;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if (self.hudMsg) {
		[self _showHudMessage:self.hudMsg];
		self.hudMsg = nil;
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (self.alertController) {
		[self presentViewController:self.alertController animated:YES completion:^{
			self.alertController = nil;
		}];
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	[self clearCaches];
}

#pragma mark - Caching

- (void)prepareCaches
{
	// Accessing both section indizes will setup everything
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
		PASAddArtistsSortOrder origSortOrder = self.selectedSortOrder;
		
		for (int i = 0; i < PASAddArtistsSortOrderSize; i++) {
			self.selectedSortOrder = [self sortOrderForIndex:i];
			[self _sectionsShorthand];
			[self _sectionIndexShorthand];
		}
		self.selectedSortOrder = origSortOrder;
		
		if ([self isViewLoaded]) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.tableView reloadData];
			});
		}
	});
}

- (BOOL)cachesAreReady
{
	return self.cachedArtistsOrderedByName && self.cachedArtistsOrderedByName.count != 0
		   && self.cachedArtistsOrderedByPlaycount && self.cachedArtistsOrderedByPlaycount.count != 0;
}

- (void)clearCaches
{
	_cachedArtistsOrderedByName = nil;
	_cachedAlphabeticalSectionIndex = nil;
	_cachedAlphabeticalSections = nil;
	
	_cachedArtistsOrderedByPlaycount = nil;
	_cachedPlaycountSectionIndex = nil;
	_cachedPlaycountSections = nil;
	
	_sampleArtists = nil;
}

#pragma mark - UITableViewDataSource required

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self._sectionsShorthand[self._sectionIndexShorthand[section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	PASArtistTVCell *cell = [PASArtistTVCell cellForTableView:tableView target:self];
	
	id artist = [self _artistForIndexPath:indexPath];
	NSString *artistName = [self nameForArtist:artist];

	[cell showArtist:artist withName:artistName andDetailTextBlock:self.detailTextBlock];
	return cell;
}

#pragma mark - UITableViewDataSource Index

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return self._sectionIndexShorthand.count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	switch (self.selectedSortOrder) {
		case PASAddArtistsSortOrderAlphabetical:
			return self._sectionIndexShorthand;
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
	label.text = self._sectionIndexShorthand[section];
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

#pragma mark - Star Button

- (void)starTapped:(UIButton *)sender atIndexPath:(NSIndexPath *)indexPath
{
	PASArtistTVCell *cell = (PASArtistTVCell *)[self.tableView cellForRowAtIndexPath:indexPath];
	[cell showFaving:YES];
	self.pageViewController.navigationItem.rightBarButtonItem.enabled = NO;
	self.pageViewController.navigationItem.leftBarButtonItem.enabled = NO;
	
	[[PASManageArtists sharedMngr] didSelectArtistWithName:[self nameForArtist:[self _artistForIndexPath:indexPath]]
												completion:^(NSError *error) {
													dispatch_async(dispatch_get_main_queue(), ^{
														[cell showFaving:NO];
														if (![[PASManageArtists sharedMngr] favingInProcess]) {
															self.pageViewController.navigationItem.rightBarButtonItem.enabled = YES;
															self.pageViewController.navigationItem.leftBarButtonItem.enabled = YES;
														}
														
														if (error) {
															[self _handleError:error];
														} else {
															// in success case the cell is reloaded by the kPASDidEditArtistWithName Notification
															// but I've seen cases where it didn't work, so let's be sure by calling
															[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
														}
													});
												}];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 50;
}

#pragma mark - Ordering, UISegmentedControl Action

- (PASAddArtistsSortOrder)sortOrderForIndex:(NSInteger)idx
{
	switch (idx) {
		case 0:
			return PASAddArtistsSortOrderAlphabetical;
		default:
			 return PASAddArtistsSortOrderByPlaycount;
	}
}

- (IBAction)segmentChanged:(UISegmentedControl *)segmentedControl
{
	self.selectedSortOrder = [self sortOrderForIndex:[segmentedControl selectedSegmentIndex]];
	
	[self _refreshUI];
}

#pragma mark - Error Handling

- (void)_handleError:(NSError *)error
{

	NSString *msg;
	switch (error.code) {
		case 141:
		case -999:
			DDLogWarn(@"%@", [error description]);
			msg = @"The operation timed out.";
			break;
		default:
			DDLogError(@"%@", [error description]);
			msg = @"Something went wrong.";
			break;
	}
	
	[self showAlertWithTitle:@"Try again" message:msg actions:nil defaultButton:@"OK"];
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)msg actions:(NSArray *)actions defaultButton:(NSString *)defaultButton
{
	NSAssert(actions.count > 0 || defaultButton, @"Must provide actions or defaultButton to show an Alert");
	UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
																   message:msg
															preferredStyle:UIAlertControllerStyleAlert];
	for (UIAlertAction *alertAction in actions) {
		[alert addAction:alertAction];
	}
	
	if (defaultButton) {
		UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:defaultButton
																style:UIAlertActionStyleCancel
															  handler:nil];
		[alert addAction:defaultAction];
	}
	
	if (self.isViewLoaded && self.view.window) {
		[self presentViewController:alert animated:YES completion:nil];
	} else {
		// cache and present on viewDidAppear
		self.alertController = alert;
	}
}

#pragma mark - MBProgressHUD

- (void)showProgressHudWithMessage:(NSString *)msg
{
	if (self.isViewLoaded) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self _showHudMessage:msg];
			self.extendedNavController.segmentedControl.enabled = NO;
			self.pageViewController.navigationItem.leftBarButtonItem.enabled = NO;
		});
	} else {
		self.hudMsg = msg;
	}
}

// only call on the main thred and when viewIsLoaded
- (void)_showHudMessage:(NSString *)msg
{
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.extendedNavController.view animated:YES];
	hud.labelText = msg;
}

- (void)hideProgressHud
{
	self.hudMsg = nil;
	dispatch_async(dispatch_get_main_queue(), ^{
		[MBProgressHUD hideHUDForView:self.extendedNavController.view animated:YES];
		self.extendedNavController.segmentedControl.enabled = YES;
		self.pageViewController.navigationItem.leftBarButtonItem.enabled = YES;
	});
}

#pragma mark - Private Methods

- (id)_artistForIndexPath:(NSIndexPath *)indexPath
{
	return self._sectionsShorthand[self._sectionIndexShorthand[indexPath.section]][indexPath.row];
}

- (void)_refreshUI
{
	[self.tableView reloadData];
}

@end
