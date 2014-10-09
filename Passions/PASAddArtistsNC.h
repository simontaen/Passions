//
//  PASAddArtistsNC.h
//  Passions
//
//  Created by Simon Tännler on 07/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

@import UIKit;

@class PASAddFromSamplesTVC;

@protocol PASAddArtistsTVCDelegate <NSObject>

- (void)viewController:(PASAddFromSamplesTVC *)vc didAddArtists:(BOOL)didAddArtists;

@end

@interface PASAddArtistsNC : UINavigationController

@property (nonatomic, weak) id<PASAddArtistsTVCDelegate> myDelegate;

- (void)setFavArtists:(NSArray *)favArtists; // of PASArtist, passed by the segue, LFM Corrected!

@end
