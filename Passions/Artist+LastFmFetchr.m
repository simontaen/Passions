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
	NSString *url = nil;
	switch ([[UIDevice currentDevice] userInterfaceIdiom]) {
		case UIUserInterfaceIdiomPad:
			url = data.imageExtraLargeString;
			break;
		default:
			url = data.imageLargeString;
			break;
	}
	
	// create tags
	NSMutableSet *tagObjects = [NSMutableSet setWithCapacity:[data.tags count]];
	for (LFMTag *tag in data.tags) {
		if (![tag.name isEqualToString:@""]) {
			Tag *tagObject = [Tag tagWithName:tag.name inManagedObjectContext:context];
			[tagObjects addObject:tagObject];
		}
	}
	
	return [self artistInContext:context
						imageURL:url
						isOnTour:data.isOnTour
							name:data.name
					   thumbnail:nil
					thumbnailURL:data.imageSmallString
						  unique:data.musicBrianzId
						  albums:nil
							tags:tagObjects
						  tracks:nil];
}

+ (Artist *)artistWithLFMArtist:(LFMArtist *)data inManagedObjectContext:(NSManagedObjectContext *)context
{
	return [self artistInContext:context
						imageURL:nil
						isOnTour:nil
							name:data.name
					   thumbnail:nil
					thumbnailURL:nil
						  unique:data.musicBrianzId
						  albums:nil
							tags:nil
						  tracks:nil];
}

+ (Artist *)artistInContext:(NSManagedObjectContext *)context
				   imageURL:(NSString *)imageURL
				   isOnTour:(NSNumber *)isOnTour
					   name:(NSString *)name
				  thumbnail:(NSData *)thumbnail
			   thumbnailURL:(NSString *)thumbnailURL
					 unique:(NSString *)unique
					 albums:(NSSet *)albums
					   tags:(NSSet *)tags
					 tracks:(NSSet *)tracks
{
	NSParameterAssert(unique);
	
	Artist *artist = nil;
	
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Artist"];
	request.sortDescriptors = nil; // only one expected
	request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
	
	NSError *err = nil;
	NSArray *matches = [context executeFetchRequest:request error:&err];
	
	if (!matches || ([matches count] > 1)) {
		// handle error
		NSLog(@"ERROR in artist creation");
		return nil;
		
	} else if (![matches count]) {
		// create the entity
		artist = [NSEntityDescription insertNewObjectForEntityForName:@"Artist" inManagedObjectContext:context];
		artist.unique = unique;
		NSLog(@"Creating artist with unique='%@' and name='%@'", unique, name);
		
		// set attributes
		if (imageURL) {
			artist.imageURL = imageURL;
		}
		if (isOnTour) {
			artist.isOnTour = isOnTour;
		} else {
			artist.isOnTour = @NO;
		}
		if (name) {
			artist.name = name;
		}
		if (thumbnail) {
			artist.thumbnail = thumbnail;
		}
		if (thumbnailURL) {
			artist.thumbnailURL = thumbnailURL;
		}
		if (albums) {
			artist.albums = albums;
		}
		if (tags) {
			artist.tags = tags;
		}
		if (tracks) {
			artist.tracks = tracks;
		}
	} else {
		// entity exist
		artist = [matches lastObject];
		
		// update the found entity
		// set attributes
		if (imageURL && !artist.imageURL) {
			artist.imageURL = imageURL;
		}
		if (isOnTour && !artist.isOnTour) {
			artist.isOnTour = isOnTour;
		}
		if (name && !artist.name) {
			artist.name = name;
		}
		if (thumbnail && !artist.thumbnail) {
			artist.thumbnail = thumbnail;
		}
		if (thumbnailURL && !artist.thumbnailURL) {
			artist.thumbnailURL = thumbnailURL;
		}
		if (albums && !artist.albums) {
			artist.albums = albums;
		}
		if (tags && !artist.tags) {
			artist.tags = tags;
		}
		if (tracks && !artist.tracks) {
			artist.tracks = tracks;
		}
	}
	return artist;
}

@end
