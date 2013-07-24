//
//  Tag+Create.m
//  Passions
//
//  Created by Simon Tännler on 24/07/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import "Tag+Create.h"

@implementation Tag (Create)

+ (Tag *)tagWithName:(NSString *)name andUnique:(NSString *)unique inManagedObjectContext:(NSManagedObjectContext *)context
{
	Tag *tag = nil;
	
	// sanity check
	if ([name length] && [unique length]) {
		NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
		request.sortDescriptors = nil; // only one expected
		request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
		
		NSError *err = nil;
		NSArray *matches = [context executeFetchRequest:request error:&err];
		
		if (!matches || ([matches count] > 1)) {
			// handle error
			NSLog(@"Error in Tag creation");
			
		} else if (![matches count]) {
			// create the entity
			tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
			
			// set attributes
			tag.name = name;
			tag.unique = unique;
			
		} else {
			// entity exist
			tag = [matches lastObject];
		}
	}
	
	return tag;
}

@end
