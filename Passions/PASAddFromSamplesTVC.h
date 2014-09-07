//
//  PASAddFromSamplesTVC.h
//  Passions
//
//  Created by Simon Tännler on 04/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PASFavArtistsTVC.h"

// intended to be defined by the subclass
extern NSString *const kArtistNameCorrectionsCacheKey;

@interface PASAddFromSamplesTVC : UITableViewController

@property (nonatomic, strong) NSArray* favArtistNames; // of NSString, LFM Corrected!
@property (nonatomic, strong) PASFavArtistsTVC* previousController;

- (IBAction)doneButtonHandler:(UIBarButtonItem *)sender;

@end
