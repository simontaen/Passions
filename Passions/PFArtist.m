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
	[query whereKey:@"favByUsers" containsAllObjectsInArray:@[[PFUser currentUser].objectId]];
	[query orderByAscending:@"name"];
	return query;
}

+ (PFQuery *)artistWithName:(NSString *)name
{
	PFQuery *query = [PFArtist query];
	[query whereKey:@"name" equalTo:name];
	return query;
}

#pragma mark - adding / creating

+ (void)favoriteArtistByCurrentUser:(NSString *)artistName withBlock:(void (^)(PFArtist *artist, NSError *error))block
{
	// Query for the Artist in Question
	PFQuery *query = [PFArtist artistWithName:artistName];
	
	[query findObjectsInBackgroundWithBlock:^(NSArray *artists, NSError *error) {
		if (artists && !error) {
			if (artists.count == 1) {
				// exactly one is expected, no duplicates allowed
				// TODO: need to call corrections since we only get exact matches on the artist name
				
				// add user to artist
				PFArtist *artist = artists.lastObject;
				[artist addCurrentUserAsFavoriteAndRegisterForNotifications];
				[artist saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
					// The artist exists and the user has favorited him
					// ready to pass it back to the caller
					if (succeeded) {
						block(artist, nil);
					} else {
						block(nil, error);
					}
				}];
				
				
			} else if (artists.count == 0) {
				// the artist does not exists yet, create it
				[PFArtist createArtistFavoritedByCurrentUser:artistName withBlock:^(PFArtist *artist, NSError *error) {
					// The artist exists and the user has favorited him
					// ready to pass it back to the caller
					if (artist && !error) {
						block(artist, nil);
					} else {
						block(nil, error);
					}
				}];
				
				
			} else {
				NSLog(@"Too many artists found (%u)", artists.count);
			}
		} else {
			NSLog(@"%@", error);
		}
	}];
}

- (void)addCurrentUserAsFavoriteAndRegisterForNotifications
{
	// register notifications
	PFInstallation *currentInstallation = [PFInstallation currentInstallation];
	[currentInstallation addObject:self.objectId forKey:@"favArtists"];
	[currentInstallation saveInBackground];
	
	// add user as "fan" to the artist, currently I don't use this relation
	[self addObject:[PFUser currentUser].objectId forKey:@"favByUsers"];
}

+ (void)createArtistFavoritedByCurrentUser:(NSString *)artistName withBlock:(void (^)(PFArtist *artist, NSError *error))block
{
	// Create a new Artist object
	PFArtist *newArtist = [PFArtist object];
	newArtist.name	= artistName;
	
	// create the relationsship with the user
	[newArtist addCurrentUserAsFavoriteAndRegisterForNotifications];
	
	// Allow public write access (other users need to modify the Artist when they favorite it)
	PFACL *artistACL = [PFACL ACL];
	[artistACL setPublicReadAccess:YES];
	[artistACL setPublicWriteAccess:YES];
	[newArtist setACL:artistACL];
	
	[newArtist saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		if (succeeded && !error) {
			block(newArtist, nil);
		} else {
			block(nil, error);
		}
	}];
}

#pragma mark - removing / deleting

+ (void)removeCurrentUserFromArtist:(PFArtist *)artist withBlock:(void (^)(BOOL succeeded, NSError *error))block
{
	[artist removeCurrentUserAsFavoriteAndDeregisterNotifications];
	
	[artist saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		block(succeeded, error);
	}];
}

- (void)removeCurrentUserAsFavoriteAndDeregisterNotifications
{
	// deregister notifications
	PFInstallation *currentInstallation = [PFInstallation currentInstallation];
	[currentInstallation removeObject:self.objectId forKey:@"favArtists"];
	[currentInstallation saveInBackground];
	
	// remove the relation
	[self removeObject:[PFUser currentUser].objectId forKey:@"favByUsers"];
}


@end
