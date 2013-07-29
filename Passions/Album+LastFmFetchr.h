//
//  Album+LastFmFetchr.h
//  Passions
//
//  Created by Simon Tännler on 29/07/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import "Album.h"

@interface Album (LastFmFetchr)

+ (Album *)albumWithLastFmJSON:(NSDictionary *)JSON inManagedObjectContext:(NSManagedObjectContext *)context;

@end
