//
//  MPMediaItem+Passions.m
//  Passions
//
//  Created by Simon Tännler on 25/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "MPMediaItem+Passions.h"

@implementation MPMediaItem (Passions)

- (NSString *)PAS_artistItemName
{
	return [self valueForProperty:MPMediaItemPropertyArtist];
}

- (NSUInteger)PAS_playcount
{
	return [(NSNumber *)[self valueForProperty:MPMediaItemPropertyPlayCount] unsignedIntegerValue];
}

@end
