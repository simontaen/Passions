//
//  PASArtistCDTVC.h
//  Passions
//
//  Created by Simon Tännler on 24/07/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface PASArtistCDTVC : CoreDataTableViewController
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@end
