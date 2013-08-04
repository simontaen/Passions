//
//  Album+LastFmFetchr.h
//  Passions
//
//  Created by Simon Tännler on 29/07/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import "Album.h"
#import "LastFmFetchr.h"

@interface Album (LastFmFetchr)

+ (Album *)albumWithLFMAlbumGetInfo:(LFMAlbumGetInfo *)data inManagedObjectContext:(NSManagedObjectContext *)context;
+ (NSArray *)albumsWithLFMArtistGetTopAlbums:(LFMArtistGetTopAlbums *)data inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Album *)albumWithLFMAlbumTopAlbum:(LFMAlbumTopAlbum *)data andArtistName:(NSString *)artistName inManagedObjectContext:(NSManagedObjectContext *)context;

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
				   tracks:(NSSet *)tracks;
@end
