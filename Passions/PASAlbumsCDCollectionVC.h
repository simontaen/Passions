//
//  PASAlbumsCDCollectionVC.h
//  Passions
//
//  Created by Simon Tännler on 10/11/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import "CoreDataCollectionViewController.h"
#import "Artist.h"

@interface PASAlbumsCDCollectionVC : CoreDataCollectionViewController

@property (strong, nonatomic) Artist *artist;

@end
