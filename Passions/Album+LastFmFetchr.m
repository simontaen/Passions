//
//  Album+LastFmFetchr.m
//  Passions
//
//  Created by Simon Tännler on 29/07/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import "Album+LastFmFetchr.h"
#import "Artist+Accessors.h"
#import "Artist+LastFmFetchr.h"
#import "Tag+Create.h"

@implementation Album (LastFmFetchr)

+ (Album *)albumWithLFMAlbumInfo:(LFMAlbumInfo *)data inManagedObjectContext:(NSManagedObjectContext *)context
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
	
	// get artist
	Artist *albumArtist = [Artist artistWithName:[data artistName] inManagedObjectContext:context];
	NSSet *artists = nil;
	if (albumArtist) {
		artists = [NSSet setWithObject:albumArtist];
	}
	
	// create tags
	NSMutableSet *tagObjects = [NSMutableSet setWithCapacity:[data.topTags count]];
	for (LFMTag *tag in data.topTags) {
		if (![tag.name isEqualToString:@""]) {
			Tag *tagObject = [Tag tagWithName:tag.name inManagedObjectContext:context];
			[tagObjects addObject:tagObject];
		}
	}
		
	// create tracks
	//NSArray *tracks = [JSON albumTracksArray];
	
	//
	NSDate *date = data.releaseDate;
	
	return [self albumInContext:context
						albumId:data.lfmId
					   imageURL:url
					  isLoading:nil
						   name:data.name
				   rankInArtist:nil
					releaseDate:(date ? date : [NSDate dateWithTimeIntervalSince1970:-47304000000])
					  thumbnail:nil
				   thumbnailURL:data.imageSmallString
						 unique:data.musicBrianzId
						artists:artists
						topTags:tagObjects
						 tracks:nil];
	
	
}

+ (NSArray *)albumsWithLFMArtistsTopAlbums:(LFMArtistsTopAlbums *)data inManagedObjectContext:(NSManagedObjectContext *)context
{
	NSArray *albumsData = data.albums; // of LFMAlbumTopAlbum
	NSMutableArray *managedObjectAlbums = [NSMutableArray arrayWithCapacity:[albumsData count]];

	for (LFMAlbumTopAlbum *albumData in albumsData) {
		Album *aAlbum = [self albumWithLFMAlbumTopAlbum:albumData inManagedObjectContext:context];
		[managedObjectAlbums addObject:aAlbum];
	}
	return managedObjectAlbums;
}

+ (Album *)albumWithLFMAlbumTopAlbum:(LFMAlbumTopAlbum *)data inManagedObjectContext:(NSManagedObjectContext *)context
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
	
	// create artists
	Artist *albumArtist = [Artist artistWithLFMArtist:data.artist inManagedObjectContext:context];
	NSSet *artists = nil;
	if (albumArtist) {
		artists = [NSSet setWithObject:albumArtist];
	}
	
	//NSLog(@"albumWithLFMAlbumTopAlbum %@ %@", data.name, data.imageSmallString);
	
	return [self albumInContext:context
						albumId:nil
					   imageURL:url
					  isLoading:nil
						   name:data.name
				   rankInArtist:data.rankInAllArtistAlbums
					releaseDate:nil
					  thumbnail:nil
				   thumbnailURL:data.imageSmallString
						 unique:data.musicBrianzId
						artists:artists
						topTags:nil
						 tracks:nil];
	
	
}

+ (Album *)albumInContext:(NSManagedObjectContext *)context
				  albumId:(NSNumber *)albumId
				 imageURL:(NSString *)imageURL
				isLoading:(NSNumber *)isLoading
					 name:(NSString *)name
			 rankInArtist:(NSNumber *)rankInArtist
			  releaseDate:(NSDate *)releaseDate
				thumbnail:(NSData *)thumbnail
			 thumbnailURL:(NSString *)thumbnailURL
				   unique:(NSString *)unique
				  artists:(NSSet *)artists
				  topTags:(NSSet *)topTags
				   tracks:(NSSet *)tracks
{
	NSParameterAssert(unique);
	
	Album *album = nil;
	
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Album"];
	request.sortDescriptors = nil; // only one expected
	request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
	
	NSError *err = nil;
	NSArray *matches = [context executeFetchRequest:request error:&err];
	
	if (!matches || ([matches count] > 1)) {
		// handle error
		NSLog(@"ERROR in album creation");
		return nil;
		
	} else if (![matches count]) {
		// create the entity
		album = [NSEntityDescription insertNewObjectForEntityForName:@"Album" inManagedObjectContext:context];
		album.unique = unique;
		NSLog(@"Creating album with unique='%@' and name='%@'", unique, name);
		
		// set attributes
		if (albumId) {
			album.albumId = albumId;
		}
		if (imageURL) {
			album.imageURL = imageURL;
		}
		if (isLoading) {
			album.isLoading = isLoading;
		} else {
			album.isLoading = @NO;
		}
		if (name) {
			album.name = name;
		}
		if (rankInArtist) {
			album.rankInArtist = rankInArtist;
		}
		if (releaseDate) {
			album.releaseDate = releaseDate;
		}
		if (thumbnail) {
			album.thumbnail = thumbnail;
		}
		if (thumbnailURL) {
			album.thumbnailURL = thumbnailURL;
		}
		if (artists) {
			album.artists = artists;
		}
		if (topTags) {
			album.topTags = topTags;
		}
		if (tracks) {
			album.tracks = tracks;
		}
	} else {
		// entity exist
		album = [matches lastObject];
		
		// update the found entity
		// set attributes
		if (albumId && !album.albumId) {
			album.albumId = albumId;
		}
		if (imageURL && !album.imageURL) {
			album.imageURL = imageURL;
		}
		if (isLoading && !album.isLoading) {
			album.isLoading = isLoading;
		}
		if (name && !album.name) {
			album.name = name;
		}
		if (rankInArtist && !album.rankInArtist) {
			album.rankInArtist = rankInArtist;
		}
		if (releaseDate && !album.releaseDate) {
			album.releaseDate = releaseDate;
		}
		if (thumbnail && !album.thumbnail) {
			album.thumbnail = thumbnail;
		}
		if (thumbnailURL && !album.thumbnailURL) {
			album.thumbnailURL = thumbnailURL;
		}
		if (artists && !album.artists) {
			album.artists = artists;
		}
		if (topTags && !album.topTags) {
			album.topTags = topTags;
		}
		if (tracks && !album.tracks) {
			album.tracks = tracks;
		}
	}
	return album;
}

@end
