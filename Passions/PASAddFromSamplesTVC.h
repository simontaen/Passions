//
//  PASAddFromSamplesTVC.h
//  Passions
//
//  Created by Simon Tännler on 04/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

@import UIKit;
#import "PASArtistTVCell.h"

@interface PASAddFromSamplesTVC : UITableViewController

@property (nonatomic, strong) NSArray* favArtists; // of PASArtist, passed by the segue, LFM Corrected!

- (BOOL)didAddArtists;

// for subclassing
- (NSArray *)artists; // of the appropriate object
- (NSString *)nameForArtist:(id)artist;
- (id)artistForIndexPath:(NSIndexPath *)indexPath;
- (NSString *)getTitle;

@end
