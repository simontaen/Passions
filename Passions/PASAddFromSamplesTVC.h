//
//  PASAddFromSamplesTVC.h
//  Passions
//
//  Created by Simon Tännler on 04/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

@import UIKit;
#import "PASFavArtistsTVC.h"
#import "PASAddingArtistCell.h"

@interface PASAddFromSamplesTVC : UITableViewController

@property (nonatomic, strong) NSArray* favArtistNames; // passed by the segue, LFM Corrected!

- (BOOL)didAddArtists;

// for subclassing
- (NSArray *)artists; // of the appropriate object
- (NSArray *)artistNames; // of NSString
- (NSString *)getTitle;
- (void)setThumbnailImageForCell:(PASAddingArtistCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end
