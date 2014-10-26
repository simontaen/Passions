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
#import "STKTableViewCell.h"

@interface PASArtistTVCell : STKTableViewCell

@property (nonatomic, weak) IBOutlet UILabel *artistName;
@property (nonatomic, weak) IBOutlet UILabel *detailText;
@property (nonatomic, weak) IBOutlet UIImageView *artistImage;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *starButton;

- (void)showArtist:(PASArtist *)artist;
- (void)showArtist:(id<PASSourceImage>)artist withName:(NSString *)name isFavorite:(BOOL)isFav playcount:(NSUInteger)playcount;

- (IBAction)starTapped:(id)sender;

+ (NSString *)reuseIdentifier;

@end
