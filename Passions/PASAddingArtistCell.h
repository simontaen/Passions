//
//  PASAddingArtistCell.h
//  Passions
//
//  Created by Simon Tännler on 09/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

@import UIKit;

@interface PASAddingArtistCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *artistName;
@property (weak, nonatomic) IBOutlet UILabel *detailText;
@property (weak, nonatomic) IBOutlet UIImageView *artistImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end
