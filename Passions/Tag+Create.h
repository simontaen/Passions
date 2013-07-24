//
//  Tag+Create.h
//  Passions
//
//  Created by Simon Tännler on 24/07/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import "Tag.h"

@interface Tag (Create)

+ (Tag *)tagWithName:(NSString *)name andUnique:(NSString *)unique inManagedObjectContext:(NSManagedObjectContext *)context;

@end
