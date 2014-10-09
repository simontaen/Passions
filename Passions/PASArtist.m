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

+ (void)favoriteArtistByCurrentUser:(NSString *)artistName
					needsCorrection:(BOOL)needsCorrection
						 completion:(void (^)(PASArtist *artist, NSError *error))completion;
{
	NSParameterAssert(artistName);
	
	void (^favingBlock)(PASArtist*, NSError*) = ^void(PASArtist *favingArtist, NSError *error) {
		// create the relationsship with the user
		[favingArtist _addCurrentUserAsFavoriteWithCompletion:^(PASArtist *blockArtist, NSError *error) {
			blockArtist && !error ? completion(blockArtist, nil) : completion(nil, error);
		}];
	};
	
	if (needsCorrection) {
		[[LastFmFetchr fetchr] getCorrectionForArtist:artistName completion:^(LFMArtist *data, NSError *error) {
			// now get the corrected name
			BOOL isValidName = !error && data && data.name && ![data.name isEqualToString:@""];
			NSString *resolvedName = isValidName ? data.name : artistName;
			
			[PASArtist _createOrFindArtist:resolvedName completion:favingBlock];
		}];
	} else {
		[PASArtist _createOrFindArtist:artistName completion:favingBlock];
	}
}

+ (void)_createOrFindArtist:(NSString *)artistName completion:(void (^)(PASArtist *artist, NSError *error))completion
{
	// Query for the Artist in question
	PFQuery *query = [PASArtist _artistWithName:artistName];
	
	// exactly one is expected, no duplicates allowed
	[query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
		if (!object && error.code == kPFErrorObjectNotFound) {
			// the artist does not exists yet, create it
			NSLog(@"Creating new Artist \"%@\"", artistName);
			[PASArtist _createArtist:artistName completion:completion];
			
		} else if (object && !error) {
			NSLog(@"Found existing Artist \"%@\"", artistName);
			completion((PASArtist *)object, error);
			
		} else {
			completion(nil, error);
		}
	}];
}

+ (void)_createArtist:(NSString *)artistName completion:(void (^)(PASArtist *artist, NSError *error))completion
{
	// Create a new Artist object
	PASArtist *newArtist = [PASArtist object];
	newArtist.name	= artistName;
	
	// Allow public readwrite access (although currently I never write again)
	PFACL *artistACL = [PFACL ACL];
	[artistACL setPublicReadAccess:YES];
	[artistACL setPublicWriteAccess:YES];
	[newArtist setACL:artistACL];
	
	[newArtist saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		succeeded && !error ? completion(newArtist, nil) : completion(nil, error);
	}];
}

- (void)_addCurrentUserAsFavoriteWithCompletion:(void (^)(PASArtist *artist, NSError *error))completion
{
	// add artist to the users favorites
	PFUser *currentUser = [PFUser currentUser];
	NSLog(@"Faving \"%@\" for User \"%@\"", self.name,  currentUser.objectId);

	[currentUser addObject:self.objectId forKey:@"favArtists"];
	[currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		succeeded && !error ? completion(self, nil) : completion(nil, error);
	}];
}

#pragma mark - removing / deleting

- (void)removeCurrentUserAsFavoriteWithCompletion:(void (^)(BOOL succeeded, NSError *error))completion
{
	NSAssert(self.objectId, @"The passed artist does not have a valid objectId. Maybe save the artist first.");
	// remove the relation
	PFUser *currentUser = [PFUser currentUser];
	NSLog(@"Removing \"%@\" from User \"%@\"", self.name,  currentUser.objectId);

	[currentUser removeObject:self.objectId forKey:@"favArtists"];
	[currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		completion(succeeded, error);
	}];
}

@end
