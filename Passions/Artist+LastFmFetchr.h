//
//  Artist+LastFmFetchr.h
//  Passions
//
//  Created by Simon Tännler on 24/07/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import "Artist.h"
#import "LastFmFetchr.h"

@interface Artist (LastFmFetchr)

+ (Artist *)artistWithLFMArtistInfo:(LFMArtistInfo *)data inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Artist *)artistWithLFMArtist:(LFMArtist *)data inManagedObjectContext:(NSManagedObjectContext *)context;

+ (Artist *)artistInContext:(NSManagedObjectContext *)context
				   imageURL:(NSString *)imageURL
				   isOnTour:(NSNumber *)isOnTour
					   name:(NSString *)name
				  thumbnail:(NSData *)thumbnail
			   thumbnailURL:(NSString *)thumbnailURL
					 unique:(NSString *)unique
					 albums:(NSSet *)albums
					   tags:(NSSet *)tags
					 tracks:(NSSet *)tracks;
@end
