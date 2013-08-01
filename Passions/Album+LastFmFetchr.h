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

+ (Album *)albumInContext:(NSManagedObjectContext *)context
				  albumId:(NSNumber *)albumId
				 imageURL:(NSString *)imageURL
					 name:(NSString *)name
			  releaseDate:(NSDate *)releaseDate
				thumbnail:(NSData *)thumbnail
			 thumbnailURL:(NSString *)thumbnailURL
				   unique:(NSString *)unique
				  artists:(NSSet *)artists
				  topTags:(NSSet *)topTags
				   tracks:(NSSet *)tracks;
@end
