//
//  PASAddingArtistCell.m
//  Passions
//
//  Created by Simon Tännler on 09/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASAddingArtistCell.h"

@implementation PASAddingArtistCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - Static

+ (NSString *)reuseIdentifier {
	return @"PASAddingArtistCell";
}

@end
