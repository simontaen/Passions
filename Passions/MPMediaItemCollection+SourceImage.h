//
//  MPMediaItemCollection+SourceImage.h
//  Passions
//
//  Created by Simon Tännler on 06/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "PASSourceImage.h"

@interface MPMediaItemCollection (SourceImage) <PASSourceImage>

+ (NSArray *)PAS_artistsOrderedByName; // of MPMediaItemCollection
+ (NSArray *)PAS_artistsOrderedByPlaycount; // of MPMediaItemCollection
+ (NSUInteger)PAS_playcountForArtistWithName:(NSString *)artistName;

- (NSString *)PAS_artistName;

@end
