//
//  PASArtistsAlbumsCDTVC.h
//  Passions
//
//  Created by Simon Tännler on 03/08/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "Artist.h"

static NSString *const kSegueName = @"setImageUrl:";

@interface PASArtistsAlbumsCDTVC : CoreDataTableViewController

// will "carry" the NSManagedObjectContext
@property (strong, nonatomic) Artist *artist;

@end
