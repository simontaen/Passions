//
//  PASArtistTVCell.h
//  Passions
//
//  Created by Simon Tännler on 09/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

@import UIKit;
#import "PASArtist.h"
#import "PASSourceImage.h"

@interface PASArtistTVCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *artistName;
@property (nonatomic, weak) IBOutlet UILabel *detailText;
@property (nonatomic, weak) IBOutlet UIImageView *artistImage;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

- (void)showArtist:(PASArtist *)artist;
- (void)showArtist:(id<PASSourceImage>)artist withName:(NSString *)name isFavorite:(BOOL)isFav;

+ (NSString *)reuseIdentifier;

@end