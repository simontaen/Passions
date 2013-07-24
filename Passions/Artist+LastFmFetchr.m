//
//  Artist+LastFmFetchr.m
//  Passions
//
//  Created by Simon Tännler on 24/07/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import "Artist+LastFmFetchr.h"
#import "NSDictionary+LastFmFetchr.h"

@implementation Artist (LastFmFetchr)

+ (Artist *)artistWithLastFmJSON:(NSDictionary *)JSON inManagedObjectContext:(NSManagedObjectContext *)context;
{
	Artist *artist = nil;
	
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"artist"];
	request.sortDescriptors = nil; // only one expected
	request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", [JSON artistMusicBrianzId]];
	
	NSError *err = nil;
	NSArray *matches = [context executeFetchRequest:request error:&err];
	
	if (!matches || ([matches count] > 1)) {
		// handle error
        NSLog(@"Error in artist creation");
		
	} else if (![matches count]) {
		// create the entity
		artist = [NSEntityDescription insertNewObjectForEntityForName:@"artist" inManagedObjectContext:context];
        
        // set attributes
		artist.unique = [JSON artistMusicBrianzId];
		artist.name = [JSON artistName];
		artist.thumbnailURL = [JSON artistImageSmall];
		artist.isOnTour = [NSNumber numberWithBool:[JSON artistIsOnTourBool]];
		
		switch ([[UIDevice currentDevice] userInterfaceIdiom]) {
			case UIUserInterfaceIdiomPad:
				artist.imageURL = [JSON	artistImageExtraLarge];
				break;
			default:
				artist.imageURL = [JSON	artistImageLarge];
				break;
		}
        
        // create and set relations
		// guaranteed to not have nil objects inside
		NSMutableSet *tagObjects = [NSMutableSet setWithArray:[JSON artistTagNames]];
		[tagObjects removeObject:@""]; // remove potential empty tag
		// the inverted relationship is automatically added
		artist.tags = [NSSet setWithArray:[JSON artistTagNames]];
        
	} else {
		// entity exist
		artist = [matches lastObject];
	}
	
	return artist;
}

@end
