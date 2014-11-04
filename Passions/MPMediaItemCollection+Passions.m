//
//  MPMediaItemCollection+Passions.m
//  Passions
//
//  Created by Simon Tännler on 05/11/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "MPMediaItemCollection+Passions.h"
#import "MPMediaItem+Passions.h"

@implementation MPMediaItemCollection (Passions)

- (NSString *)PAS_artistName
{
	return [[self representativeItem] PAS_artistItemName];
}

@end
