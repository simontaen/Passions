//
//  PASArtistInfo.h
//  Passions
//
//  Created by Simon Tännler on 18/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

@import UIKit;
#import "PASArtist.h"

@interface PASArtistInfo : UIViewController

@property (nonatomic, strong) PASArtist *artist;

@property (weak, nonatomic) IBOutlet UIImageView *artistImage;
@property (weak, nonatomic) IBOutlet UILabel *name;
@end
