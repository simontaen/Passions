//
//  MPMediaQuery+Passions.h
//  Passions
//
//  Created by Simon Tännler on 22/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

@interface MPMediaQuery (Passions)

+ (NSArray *)PAS_artistsQuery;
+ (NSArray *)PAS_orderedArtistsByPlaycount:(NSArray *)artists;
+ (NSArray *)PAS_orderedArtistsByName:(NSArray *)artists;

@end
