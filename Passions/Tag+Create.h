//
//  Tag+Create.h
//  Passions
//
//  Created by Simon Tännler on 24/07/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import "Tag.h"

@interface Tag (Create)

/// By convention the unique is the lowercase name
+ (Tag *)tagWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context;

@end
