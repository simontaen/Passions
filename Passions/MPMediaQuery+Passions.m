//
//  MPMediaQuery+Passions.m
//  Passions
//
//  Created by Simon Tännler on 22/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "MPMediaQuery+Passions.h"

@implementation MPMediaQuery (Passions)

+ (NSArray *)PAS_artistsQuery
{
	MPMediaQuery *everything = [[MPMediaQuery alloc] init];
	[everything setGroupingType: MPMediaGroupingAlbumArtist];
	
	NSArray *collections = [everything collections];
	
	NSMutableArray *items = [[NSMutableArray alloc] initWithCapacity:collections.count];
	for (MPMediaItemCollection *itemCollection in collections) {
		[items addObject:[itemCollection representativeItem]];
	}
	
	return items;
}

+ (NSArray *)PAS_orderedArtistsByPlaycount:(NSArray *)artists
{
	NSSortDescriptor *playCountSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:MPMediaItemPropertyPlayCount
																			  ascending:NO
																			   selector:@selector(compare:)];
	return [artists sortedArrayUsingDescriptors:@[playCountSortDescriptor]];
}

+ (NSArray *)PAS_orderedArtistsByName:(NSArray *)artists
{
	NSSortDescriptor *artistNameSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:MPMediaItemPropertyArtist
																			   ascending:YES
																				selector:@selector(localizedCaseInsensitiveCompare:)];
	return [artists sortedArrayUsingDescriptors:@[artistNameSortDescriptor]];
}

@end
