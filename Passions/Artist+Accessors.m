//
//  Artist+Accessors.m
//  Passions
//
//  Created by Simon Tännler on 29/07/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import "Artist+Accessors.h"

@implementation Artist (Accessors)

+ (Artist *)artistWithName:(NSString *)name inManagedObjectContext:(NSManagedObjectContext *)context
{
	NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Artist"];
	request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
	
	NSError *err = nil;
	NSArray *matches = [context executeFetchRequest:request error:&err];
	
	if (!matches || ([matches count] > 1)) {
		// error occured, or found ambigues
		return nil;
	} else if (![matches count]) {
		// non found
		NSLog(@"WARNING: No artist found with name %@", name);
		return nil;
	} else {
		// entity exist
		return [matches lastObject];
	}
}
@end
