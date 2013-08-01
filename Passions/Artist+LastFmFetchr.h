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

+ (Artist *)artistWithLFMArtistsGetInfo:(LFMArtistsGetInfo *)data inManagedObjectContext:(NSManagedObjectContext *)context;

@end
