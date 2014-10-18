//
//  PASArtistInfo.h
//  Passions
//
//  Created by Simon Tännler on 18/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

@import UIKit;
#import "PASArtist.h"
#import "PASAlbum.h"

@interface PASArtistInfo : UIViewController

@property (nonatomic, strong) PASArtist *artist;
@property (nonatomic, strong) PASAlbum *album;

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *name;
@end
