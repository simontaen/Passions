//
//  PASFavArtistsTVC.h
//  Passions
//
//  Created by Simon Tännler on 03/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import <Parse/Parse.h>

// Notification sent to pass the already favorited Artists
extern NSString * const kPASSetFavArtists;
// Notification received when favorite Artists have been edited
extern NSString * const kPASDidEditFavArtists;

@interface PASFavArtistsTVC : PFQueryTableViewController

@end
