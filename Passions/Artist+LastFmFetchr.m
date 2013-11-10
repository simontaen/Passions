//
//  Artist+LastFmFetchr.m
//  Passions
//
//  Created by Simon Tännler on 24/07/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import "Artist+LastFmFetchr.h"
#import "Tag+Create.h"

@implementation Artist (LastFmFetchr)

+ (Artist *)artistWithLFMArtistInfo:(LFMArtistInfo *)data inManagedObjectContext:(NSManagedObjectContext *)context;
{
	Artist *artist = nil;
	
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Artist"];
	request.sortDescriptors = nil; // only one expected
	request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", [data musicBrianzId]];
	
	NSError *err = nil;
	NSArray *matches = [context executeFetchRequest:request error:&err];
	
	if (!matches || ([matches count] > 1)) {
		// handle error
        NSLog(@"Error in artist creation");
		
	} else if (![matches count]) {
		// create the entity
		artist = [NSEntityDescription insertNewObjectForEntityForName:@"Artist" inManagedObjectContext:context];
        
        // set attributes
		artist.unique = data.musicBrianzId;
		artist.name = data.name;
		artist.thumbnailURL = [[data.imageSmall absoluteString] description];
		artist.isOnTour = [NSNumber numberWithBool:data.isOnTour];
		
		switch ([[UIDevice currentDevice] userInterfaceIdiom]) {
			case UIUserInterfaceIdiomPad:
				artist.imageURL = [[data.imageExtraLarge absoluteString] description];
				break;
			default:
				artist.imageURL = [[data.imageLarge absoluteString] description];
				break;
		}
        
        // create and set relations
		
		NSMutableSet *tagObjects = [NSMutableSet setWithCapacity:[data.tags count]];
		for (LFMTag *tag in data.tags) {
			if (![tag.name isEqualToString:@""]) {
				Tag *tagObject = [Tag tagWithName:tag.name inManagedObjectContext:context];
				[tagObjects addObject:tagObject];
			}
		}
		
		// the inverted relationship is automatically added
		artist.tags = tagObjects;
        
	} else {
		// entity exist
		artist = [matches lastObject];
		
		// updating?
	}
	
	return artist;
}

@end
