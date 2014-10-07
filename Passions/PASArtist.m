//
//  PASArtist.m
//  Passions
//
//  Created by Simon Tännler on 04/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASArtist.h"
#import <Parse/PFObject+Subclass.h>
#import "LastFmFetchr.h"

NSString *const ImageFormatFamilyArtistThumbnails = @"ImageFormatFamilyArtistThumbnails";
NSString *const ImageFormatNameArtistThumbnailSmall = @"ImageFormatNameArtistThumbnailSmall";
CGSize const ImageFormatImageSizeArtistThumbnailSmall = {43, 43};

@implementation PASArtist

@dynamic objectId;
@dynamic name;
@dynamic spotifyId;
@dynamic totalAlbums;
@dynamic favByUsers; // of NSString PFUser.objectId
@dynamic createdAt;
@dynamic updatedAt;

#pragma mark - Parse

+ (void)load
{
	[self registerSubclass];
}

+ (NSString *)parseClassName
{
	return @"Artist";
}

#pragma mark - Queries

+ (PFQuery *)favArtistsForCurrentUser
{
	PFQuery *query = [PASArtist query];
	[query whereKey:@"objectId" containedIn:(NSArray *)[[PFUser currentUser] objectForKey:@"favArtists"]];
	[query orderByAscending:@"name"];
	return query;
}

+ (PFQuery *)_artistWithName:(NSString *)name
{
	NSParameterAssert(name);
	PFQuery *query = [PASArtist query];
	[query whereKey:@"name" equalTo:name];
	return query;
}

#pragma mark - adding / creating

/// query in Parse, if found ok, if 0 create it, if >1 error
+ (void)favoriteArtistByCurrentUser:(NSString *)artistName completion:(void (^)(PASArtist *artist, NSError *error))completion
{
	NSParameterAssert(artistName);
	// TODO: pass a param if the name needs correction
	// if it does, call LFM now
	// leads to duplicate artists on parse currently
	
	// Query for the Artist in Question
	PFQuery *query = [PASArtist _artistWithName:artistName];
	
	[query findObjectsInBackgroundWithBlock:^(NSArray *artists, NSError *error) {
		if (artists && !error) {
			if (artists.count == 1) {
				// exactly one is expected, no duplicates allowed
				
				// add user to artist
				PASArtist *artist = [artists firstObject];
				[artist _addCurrentUserAsFavorite];
				[artist saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
					// The artist exists and the user has favorited him
					// ready to pass it back to the caller
					if (succeeded) {
						completion(artist, nil);
					} else {
						completion(nil, error);
					}
				}];
				
				
			} else if (artists.count == 0) {
				// the artist does not exists yet, create it
				[PASArtist _createArtistFavoritedByCurrentUser:artistName completion:^(PASArtist *artist, NSError *error) {
					// The artist exists and the user has favorited him
					// ready to pass it back to the caller
					if (artist && !error) {
						completion(artist, nil);
					} else {
						completion(nil, error);
					}
				}];
				
				
			} else {
				NSLog(@"Too many artists found (%u)", (int)artists.count);
			}
			
		} else {
			NSLog(@"%@", error);
		}
	}];
}

- (void)_addCurrentUserAsFavorite
{
	// TODO: this should be done by a PFUser subclass
	// add artist to the users favorites
	[[PFUser currentUser] addObject:self.objectId forKey:@"favArtists"];
	[[PFUser currentUser] saveInBackground];
}

/// calls LFM for corrections and adds the Artists to Parse
+ (void)_createArtistFavoritedByCurrentUser:(NSString *)artistName completion:(void (^)(PASArtist *artist, NSError *error))completion
{
	NSParameterAssert(artistName);
	// artistName is from unknown source, needs correction
	[[LastFmFetchr fetchr] getCorrectionForArtist:artistName completion:^(LFMArtist *data, NSError *error) {
		// now get the corrected name
		BOOL isValidName = !error && data && data.name && ![data.name isEqualToString:@""];
		NSString *resolvedName = isValidName ? data.name : artistName;
		
		// Create a new Artist object
		PASArtist *newArtist = [PASArtist object];
		newArtist.name	= resolvedName;
		
		// Allow public write access (other users need to modify the Artist when they favorite it)
		PFACL *artistACL = [PFACL ACL];
		[artistACL setPublicReadAccess:YES];
		[artistACL setPublicWriteAccess:YES];
		[newArtist setACL:artistACL];
		
		[newArtist saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
			if (succeeded && !error) {
				// create the relationsship with the user
				[newArtist _addCurrentUserAsFavorite];
				
				completion(newArtist, nil);
			} else {
				completion(nil, error);
			}
		}];
		
	}];
}

#pragma mark - removing / deleting

+ (void)removeCurrentUserFromArtist:(PASArtist *)artist completion:(void (^)(BOOL succeeded, NSError *error))completion
{
	// TODO: this should be done by a PFUser subclass
	// remove the relation
	[[PFUser currentUser] removeObject:artist.objectId forKey:@"favArtists"];
	[[PFUser currentUser] saveInBackground];
	
	[artist saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		completion(succeeded, error);
	}];
}

@end
