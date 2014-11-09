//
//  PASAlbumInfoTVCell.h
//  Passions
//
//  Created by Simon Tännler on 09/11/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

@import UIKit;
#import "PASAlbum.h"

@interface PASAlbumInfoTVCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *mainText;
@property (weak, nonatomic) IBOutlet UILabel *detailText;

+ (NSString *)reuseIdentifier;

@end
