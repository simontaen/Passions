//
//  PASArtworkCVCell.h
//  Passions
//
//  Created by Simon Tännler on 04/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PASAlbum.h"
#import "PASArtist.h"

// TODO: rename to PASArtworkCVCell
@interface PASArtworkCVCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *albumImage;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *releaseDateBackground;
@property (weak, nonatomic) IBOutlet UILabel *releaseDateLabel;

- (void)showAlbum:(PASAlbum *)album;
- (void)showArtist:(PASArtist *)artist;

+ (NSString *)reuseIdentifier;

@end
