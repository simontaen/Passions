//
//  MPMediaItem+Passions.h
//  Passions
//
//  Created by Simon Tännler on 25/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

@interface MPMediaItem (Passions)

- (NSString *)PAS_artistName;
- (NSUInteger)PAS_playcount;

@end
