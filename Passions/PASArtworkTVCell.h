//
//  PASArtworkTVCell.h
//  Passions
//
//  Created by Simon Tännler on 08/11/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

@import UIKit;
#import "PASAlbum.h"

@interface PASArtworkTVCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *artworkImage;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

- (void)showAlbum:(PASAlbum *)album;

+ (NSString *)reuseIdentifier;

@end
