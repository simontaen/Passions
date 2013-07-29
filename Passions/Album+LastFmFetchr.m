//
//  Album+LastFmFetchr.m
//  Passions
//
//  Created by Simon Tännler on 29/07/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import "Album+LastFmFetchr.h"
#import "NSDictionary+LastFmFetchr.h"
#import "Artist+Accessors.h"
#import "Tag+Create.h"

@implementation Album (LastFmFetchr)

+ (Album *)albumWithLastFmJSON:(NSDictionary *)JSON inManagedObjectContext:(NSManagedObjectContext *)context
{
	Album *album = nil;
	
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Album"];
	request.sortDescriptors = nil; // only one expected
	request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", [JSON albumMusicBrianzId]];
	
	NSError *err = nil;
	NSArray *matches = [context executeFetchRequest:request error:&err];
	
	if (!matches || ([matches count] > 1)) {
		// handle error
		NSLog(@"Error in album creation");
        
	} else if (![matches count]) {
		// create the entity
		album = [NSEntityDescription insertNewObjectForEntityForName:@"Album" inManagedObjectContext:context];
        
        // set attributes
		album.unique = [JSON albumMusicBrianzId];
		album.name = [JSON albumName];
		album.albumId = [JSON albumIdNumber];
		album.releaseDate = [JSON albumReleasedateDate];
		album.thumbnailURL = [JSON artistImageSmall];
		
		switch ([[UIDevice currentDevice] userInterfaceIdiom]) {
			case UIUserInterfaceIdiomPad:
				album.imageURL = [JSON	artistImageExtraLarge];
				break;
			default:
				album.imageURL = [JSON	artistImageLarge];
				break;
		}
        
        // create and set relations
		Artist *albumArtist = [Artist artistWithName:[JSON albumArtistName]
							  inManagedObjectContext:context];
		if (albumArtist) {
			album.artists = [NSSet setWithObject:albumArtist];
		}
		
		NSArray *topTags = [JSON albumToptagNames];
		if (topTags) {
			NSMutableSet *topTagsSet = [NSMutableSet setWithCapacity:[topTags count]];
			for (NSString *topTag in topTags) {
				[topTagsSet addObject:[Tag tagWithName:topTag
								inManagedObjectContext:context]];
			}
			album.topTags = topTagsSet;
		}
		
		// TODO: add tracks
		//NSArray *tracks = [JSON albumTracksArray];
        
	} else {
		// entity exist
		album = [matches lastObject];
	}
	return album;
}

@end
