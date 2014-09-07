//
//  PASAddArtistsNavController.h
//  Passions
//
//  Created by Simon Tännler on 07/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PASFavArtistsTVC.h"

@interface PASAddArtistsNavController : UINavigationController
@property (nonatomic, strong) NSArray* favArtistNames; // of NSString, LFM Corrected!
@property (nonatomic, strong) PASFavArtistsTVC *favArtistsTVC ;
@end
