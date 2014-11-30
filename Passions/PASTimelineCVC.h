//
//  PASTimelineCVC.h
//  Passions
//
//  Created by Simon Tännler on 07/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

@import UIKit;
#import "CPFQueryCollectionViewController.h"

/// Listens to kPASDidEditFavArtists and kPASShowAlbumDetails
@interface PASTimelineCVC : CPFQueryCollectionViewController <UICollectionViewDelegateFlowLayout>

/// Show swipe hints when no albums
@property (nonatomic, assign) BOOL showSwipeHint;

- (void)commonInit;

@end
