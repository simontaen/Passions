//
//  PASAddFromSamplesTVC.h
//  Passions
//
//  Created by Simon Tännler on 04/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

@import UIKit;
#import "PASArtistTVCell.h"

// Listens for kPASSetFavArtists Notifications to receive already favorited Artists
@interface PASAddFromSamplesTVC : UITableViewController

- (BOOL)didEditArtists;

// for subclassing, called once
// cacheing of these results is handled by this class
- (NSArray *) artistsOrderedByName; // of the appropriate object
- (NSArray *) artistsOrderedByPlaycout; // of the appropriate object

// called during cell config
- (NSString *)nameForArtist:(id)artist;
- (NSUInteger)playcountForArtist:(id)artist withName:(NSString *)name;

// UISegmentedControl Action
- (IBAction)segmentChanged:(UISegmentedControl *)sender;

@end
