//
//  Artist+Accessors.h
//  Passions
//
//  Created by Simon Tännler on 29/07/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import "Artist.h"

@interface Artist (Accessors)

+ (Artist *)artistWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;

@end
