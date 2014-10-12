//
//  PASMyPVC.h
//  Passions
//
//  Created by Simon Tännler on 12/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASPageViewController.h"

@class PASAddFromSamplesTVC;

@protocol PASAddArtistsTVCDelegate <NSObject>

- (void)viewController:(PASAddFromSamplesTVC *)vc didEditArtists:(BOOL)didEditArtists;

@end

@interface PASMyPVC : PASPageViewController

@property (nonatomic, weak) id<PASAddArtistsTVCDelegate> myDelegate;

- (void)setFavArtists:(NSMutableArray *)favArtists; // of PASArtist, passed by the segue, LFM Corrected!


@end
