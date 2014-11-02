//
//  PASAddFromSamplesTVC.h
//  Passions
//
//  Created by Simon Tännler on 04/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

@import UIKit;
#import "PASArtistTVCell.h"

typedef NS_ENUM(NSUInteger, PASAddArtistsSortOrder) {
	PASAddArtistsSortOrderAlphabetical,
	PASAddArtistsSortOrderByPlaycount
};

// Listens for kPASSetFavArtists Notifications to receive already favorited Artists
@interface PASAddFromSamplesTVC : UITableViewController

// Formatting Blocks
@property (nonatomic, copy) NSString * (^detailTextBlock)(id<FICEntity> artist, NSString *name);


// Mapping an index, usually from a UISegmentedControl, to a sort order.
- (PASAddArtistsSortOrder)sortOrderForIndex:(NSInteger)idx;

// When returning to the presenting Vc
- (BOOL)didEditArtists;

// UISegmentedControl Action
- (IBAction)segmentChanged:(UISegmentedControl *)sender;

// for subclassing, called once
// cacheing of these results is handled by this class
- (NSArray *)artistsOrderedByName; // of the appropriate object
- (NSArray *)artistsOrderedByPlaycount; // of the appropriate object
- (UIColor *)chosenTintColor;
- (NSString *)sortOrderDescription:(PASAddArtistsSortOrder)sortOrder;

// called during cell config
- (NSString *)nameForArtist:(id)artist;
- (NSUInteger)playcountForArtist:(id)artist withName:(NSString *)name;

@end
