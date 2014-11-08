//
//  PASArtworkCVCell.h
//  Passions
//
//  Created by Simon Tännler on 04/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

@import UIKit;
#import "PASAlbum.h"
#import "PASArtist.h"

@interface PASArtworkCVCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *artworkImage;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *releaseDateBackground;
@property (weak, nonatomic) IBOutlet UILabel *releaseDateLabel;

- (void)showAlbum:(PASAlbum *)album;
- (void)showArtist:(PASArtist *)artist;

+ (NSString *)reuseIdentifier;

@end
