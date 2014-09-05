//
//  PASAddFromSamplesTVC.m
//  Passions
//
//  Created by Simon Tännler on 04/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASAddFromSamplesTVC.h"
#import "PFArtist.h"

#define FAV_ARTISTS @"FAV_ARTISTS_FROM_SAMPLES"

@interface PASAddFromSamplesTVC ()
@property (nonatomic, strong) NSArray* artists; // of NSString
@property (nonatomic, strong) NSMutableArray* favorites; // of NSString
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, strong) dispatch_queue_t favoritesMutatorQueue;
@end

@implementation PASAddFromSamplesTVC

#pragma mark - Accessors

- (NSArray *)artists
{
	static NSArray *sampleArtists;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		//sampleArtists = @[@"Beatles", @"AC/DC", @"Pink Floid", @"Guns 'n roses"];
		//sampleArtists = @[@"Deadmouse"];
		sampleArtists = [@[
						   @"The Beatles", @"Air", @"Pink Floid", @"Rammstein", @"Bloodhound Gang",
						   @"Ancien Régime", @"Genius/GZA ", @"Belle & Sebastian", @"Björk",
						   @"Ugress", @"ADELE", @"The Asteroids Galaxy Tour", @"Bar 9",
						   @"Baskerville", @"Beastie Boys", @"Bee Gees", @"Bit Shifter",
						   @"Bomfunk MC's", @"C-Mon & Kypski", @"The Cardigans", @"Carly Commando",
						   @"Caro Emerald", @"Coldplay", @"Coolio", @"Cypress Hill",
						   @"David Bowie", @"Dukes of Stratosphear", @"[dunkelbunt]",
						   @"Eminem", @"Enigma", @"Deadmouse", @"AC/DC"
						   ] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	});
	return sampleArtists;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setTitle:@"Samples"];
	
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.favoritesMutatorQueue = dispatch_queue_create("FavoritedMutator", DISPATCH_QUEUE_CONCURRENT);
	
	// no need for barrier, we are just appearing
	dispatch_async(self.favoritesMutatorQueue, ^{
		self.favorites = [[[NSUserDefaults standardUserDefaults] arrayForKey:FAV_ARTISTS] mutableCopy];
		if (!self.favorites) {
			self.favorites = [[NSMutableArray alloc] initWithCapacity:self.artists.count / 4];
		}
	});
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	
	// use barrier, let adding tasks finish
	dispatch_barrier_async(self.favoritesMutatorQueue, ^{
		if (self.favorites) {
			[[NSUserDefaults standardUserDefaults] setObject:self.favorites forKey:FAV_ARTISTS];
			[[NSUserDefaults standardUserDefaults] synchronize];
		}
	});
}

- (IBAction)doneButtonHandler:(UIBarButtonItem *)sender
{
	// Go back to the previous view
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource required

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.artists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"SampleArtist";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	
	NSString *artistName = self.artists[indexPath.row];
	cell.textLabel.text = artistName;
	if ([self.favorites containsObject:artistName]) {
		cell.detailTextLabel.text = @"Favorite!";
	} else {
		cell.detailTextLabel.text = nil;
	}
	
	return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *artistName = self.artists[indexPath.row];
	NSLog(@"Selected %@", artistName);
	[PFArtist favoriteArtistByCurrentUser:artistName withBlock:^(PFArtist *artist, NSError *error) {
		dispatch_barrier_async(self.favoritesMutatorQueue, ^{
			[self.favorites addObject:artistName];
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
			});
		});
	}];
}



@end
