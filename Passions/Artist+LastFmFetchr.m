//
//  Artist+LastFmFetchr.m
//  Passions
//
//  Created by Simon Tännler on 24/07/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import "Artist+LastFmFetchr.h"
#import "NSDictionary+LastFmFetchr.h"
#import "Tag+Create.h"

@implementation Artist (LastFmFetchr)

+ (Artist *)artistWithLastFmJSON:(NSDictionary *)JSON inManagedObjectContext:(NSManagedObjectContext *)context;
{
	Artist *artist = nil;
	
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Artist"];
	request.sortDescriptors = nil; // only one expected
	request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", [JSON artistMusicBrianzId]];
	
	NSError *err = nil;
	NSArray *matches = [context executeFetchRequest:request error:&err];
	
	if (!matches || ([matches count] > 1)) {
		// handle error
        NSLog(@"Error in artist creation");
		
	} else if (![matches count]) {
		// create the entity
		artist = [NSEntityDescription insertNewObjectForEntityForName:@"Artist" inManagedObjectContext:context];
        
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
		NSMutableSet *tags = [NSMutableSet setWithArray:[JSON artistTagNames]];
		[tags removeObject:@""]; // remove potential empty tag

		NSMutableSet *tagObjects = [NSMutableSet setWithCapacity:[tags count]];
		
		for (NSString *tag in tags) {
			Tag *tagObject = [Tag tagWithName:[tag lowercaseString] andUnique:[tag lowercaseString] inManagedObjectContext:context];
			[tagObjects addObject:tagObject];
		}
		
		// the inverted relationship is automatically added
		artist.tags = tagObjects;
        
	} else {
		// entity exist
		artist = [matches lastObject];
	}
	
	return artist;
}

@end
