//
//  PASAddArtistsNC.h
//  Passions
//
//  Created by Simon Tännler on 07/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

@import UIKit;
#import "PASFavArtistsTVC.h"

@interface PASAddArtistsNC : UINavigationController
@property (nonatomic, strong) NSArray* favArtistNames; // passed by the segue, LFM Corrected!
@property (nonatomic, strong) PASFavArtistsTVC *favArtistsTVC ;
@end
