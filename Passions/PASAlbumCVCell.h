//
//  PASAlbumCVCell.h
//  Passions
//
//  Created by Simon Tännler on 04/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PASAlbum.h"

@interface PASAlbumCVCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIImageView *albumImage;
@property (weak, nonatomic) IBOutlet UILabel *releaseDateLabel;

@property (nonatomic, strong) PASAlbum *album;

+ (NSString *)reuseIdentifier;

@end
