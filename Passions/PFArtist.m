//
//  PFArtist.m
//  Passions
//
//  Created by Simon Tännler on 04/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PFArtist.h"
#import <Parse/PFObject+Subclass.h>

@implementation PFArtist

@dynamic objectId;
@dynamic albums;
@dynamic name;
@dynamic spotifyId;
@dynamic totalAlbums;
@dynamic createdAt;
@dynamic updatedAt;
@dynamic favByUsers;
@dynamic images;

// maybe a UIImage getter (small, medium, large), see https://parse.com/docs/ios_guide#subclasses-properties/iOS

// utility functions for delete/create

// query creators


#pragma mark - Parse

+ (void)load {
	[self registerSubclass];
}

+ (NSString *)parseClassName {
	return @"Artist";
}

#pragma mark - Queries

+ (PFQuery *)favArtistsForCurrentUser
{
	PFQuery *query = [PFArtist query];
	[query whereKey:@"favByUsers" containsAllObjectsInArray:@[[PFUser currentUser]]];
	[query orderByAscending:@"name"];
	return query;
}

#pragma mark - Actions

+ (void)favoriteArtist:(NSString *)artist byUser:(PFUser *)user
{
	return;
}


#pragma mark - Serach and create Artists

- (void)getArtists:(NSArray *)artists
{
	
	NSMutableArray *queries = [NSMutableArray array];
	for (NSString *artist in artists) {
		PFQuery *query = [PFQuery queryWithClassName:@"Artist"];
		[query whereKey:@"name" equalTo:artist];
		[queries addObject:query];
	}
	
	PFQuery *orQuery = [PFQuery orQueryWithSubqueries:queries];
	
	[orQuery findObjectsInBackgroundWithBlock:^(NSArray *artists, NSError *error) {
		if (!error) {
			if (artists.count > 0) {
				// the current implementation never creates additional artists if you match a subset
				// also we only get exact matched on the artist name -> need to call corrections
				for (PFObject *artist in artists) {
					NSLog(@"Found %@", [artist objectForKey:@"name"]);
					// add yourself to favByUsers
					[artist addObject:[PFUser currentUser] forKey:@"favByUsers"];
					[artist save];
				}
				// some callback if all is completed to reload tableView would be good
				
			} else {
				[self createArtists:artists];
			}
			
		} else {
			NSLog(@"%@", error);
		}
	}];
}

- (void)deleteArtists:(NSArray *)artists
{
	for (PFObject *artist in artists) {
		[artist delete];
	}
}

- (NSArray *)createArtists:(NSArray *)artists
{
	NSMutableArray *newArtists = [NSMutableArray array];
	
	for (NSString *artist in artists) {
		// Create a new Artist object and create relationship with PFUser
		PFObject *newArtist = [PFObject objectWithClassName:@"Artist"];
		[newArtist setObject:artist	forKey:@"name"];
		[newArtist setObject:@[[PFUser currentUser]] forKey:@"favByUsers"]; // One-to-Many relationship created here!
		
		// Allow public write access (other users need to modify the Artist when they favorite it)
		PFACL *artistACL = [PFACL ACL];
		[artistACL setPublicReadAccess:YES];
		[artistACL setPublicWriteAccess:YES];
		[newArtist setACL:artistACL];
		
		// Cache it
		[newArtists addObject:newArtist];
		
		// Save new Artist object in Parse
		[newArtist saveInBackground];
		
		// DEBUG
		// change number of total Albums and save again
		//[newArtist setObject:@2 forKey:@"totalAlbums"];
		//[newArtist save];
	}
	return newArtists;
}



@end
