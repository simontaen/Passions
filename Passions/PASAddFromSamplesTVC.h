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

@interface PASAddFromSamplesTVC : UITableViewController

// Formatting Blocks
@property (nonatomic, copy) NSString * (^detailTextBlock)(id<FICEntity> artist, NSString *name);
// a potential alert that needs to be presented
@property (nonatomic, strong) UIAlertController *alertController;

// Mapping an index, usually from a UISegmentedControl, to a sort order.
- (PASAddArtistsSortOrder)sortOrderForIndex:(NSInteger)idx;

// Caches handling
- (void)prepareCaches;
- (void)clearCaches;
- (BOOL)cachesAreReady;

// UISegmentedControl Action
- (IBAction)segmentChanged:(UISegmentedControl *)sender;

// Error handling
- (void)showAlertWithTitle:(NSString *)title message:(NSString *)msg actions:(NSArray *)actions defaultButton:(NSString *)defaultButton;

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
