//
//  PASAddingArtistCell.h
//  Passions
//
//  Created by Simon Tännler on 09/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

@import UIKit;
#import "PASArtist.h"

@interface PASAddingArtistCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *artistName;
@property (nonatomic, weak) IBOutlet UILabel *detailText;
@property (nonatomic, weak) IBOutlet UIImageView *artistImage;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, copy) PASArtist *artist;

+ (NSString *)reuseIdentifier;

@end
