//
//  PASAddFromSamplesTVC.m
//  Passions
//
//  Created by Simon Tännler on 04/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASAddFromSamplesTVC.h"

@interface PASAddFromSamplesTVC ()
@property (nonatomic, strong) NSArray* artists; // of NSString
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
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
						   @"Eminem", @"Enigma", @"Deadmouse"
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
	
	cell.textLabel.text = self.artists[indexPath.row];
	
	return cell;
}



@end
