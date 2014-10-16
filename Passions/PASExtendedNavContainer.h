//
//  PASExtendedNavContainer.h
//  Passions
//
//  Created by Simon Tännler on 12/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PASAddFromSamplesTVC.h"

extern CGFloat const kPASSegmentBarHeight;

// Sends kPASDidEditFavArtists Notifications to signal if favorite Artists have been edited
// currently only when and edit actually happened
@interface PASExtendedNavContainer : UIViewController

// the contained view controller
@property (nonatomic, strong) PASAddFromSamplesTVC *addTvc;

/// designated initializer
- (instancetype)initWithIndex:(NSUInteger)index;

@end
