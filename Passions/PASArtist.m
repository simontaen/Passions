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
#import "PASResources.h"

@implementation PASArtist

@dynamic objectId;
@dynamic name;
@dynamic iTunesId;
@dynamic iTunesUrlMap;
@dynamic iTunesGenreName;
@dynamic iTunesGenreId;
@dynamic iTunesRadioUrl;
@dynamic amgId;
@dynamic totalAlbums;
@dynamic favByUsers; // of NSString PFUser.objectId
@dynamic spotifyId;
@dynamic spotifyUrl;
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

#pragma mark - Compound properties

- (NSString *)availableAlbums
{
	if (!self.totalAlbums) {
		return @"Processing on server...";
	} else if (self.totalAlbums.longValue == 1) {
		return [NSString stringWithFormat:@"%lu album available", self.totalAlbums.longValue];
	} else {
		return [NSString stringWithFormat:@"%lu albums available", self.totalAlbums.longValue];
	}
}

- (NSURL *)iTunesAttributedUrl
{
	return [NSURL URLWithString:[NSString stringWithFormat:@"%@&%@", [self iTunesUrl], kITunesAffiliation]];
}

- (NSString *)iTunesUrl
{
	return self.iTunesUrlMap[[PASResources userCountry]] ?: self.iTunesUrlMap[@"US"];
}

- (BOOL)isProcessingOnServer
{
	return !self.totalAlbums;
}
#pragma mark - adding / creating

+ (void)favoriteArtistByCurrentUser:(NSString *)artistName
					needsCorrection:(BOOL)needsCorrection
						   saveUser:(BOOL)saveUser
						 completion:(void (^)(PASArtist *artist, NSError *error))completion
{
	NSParameterAssert(artistName);
	NSDate *start = [NSDate date];
	
	void (^favingBlock)(PASArtist*, NSError*) = ^void(PASArtist *favingArtist, NSError *error) {
		if (favingArtist && !error) {
			// create the relationsship with the user
			[favingArtist _addCurrentUserAsFavoriteAndSave:saveUser completion:^(PASArtist *blockArtist, NSError *error) {
				[PASArtist _logStats:start artistName:blockArtist.name success:(blockArtist && !error) add:YES];
				blockArtist && !error ? completion(blockArtist, nil) : completion(nil, error);
			}];
		} else {
			completion(nil, error);
		}
	};
	
	if (needsCorrection) {
		NSURLSessionTask *task = [[LastFmFetchr fetchr] getCorrectionForArtist:artistName
																	completion:^(LFMArtist *data, NSError *error) {
																		if (!error) {
																			// now get the corrected name
																			BOOL isValidName = !error && data && data.name && ![data.name isEqualToString:@""];
																			NSString *resolvedName = isValidName ? data.name : artistName;
																			DDLogDebug(@"Resolved Name after Correction to \"%@\"", resolvedName);
																			
																			[PASArtist _createOrFindArtist:resolvedName completion:favingBlock];
																		} else {
																			completion(nil, error);
																		}
		}];
		
		// Setup a Timeout
		 void (^timer)(void) = ^{
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, kPASLastFmTimeoutInSec * NSEC_PER_SEC);
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				if ([task state] == NSURLSessionTaskStateRunning) {
					// Task is running too long, cancel it
					DDLogDebug(@"Cancelling getCorrectionForArtist Request");
					[task cancel];
				}
			});
		};
		// Start the timer
		timer();
		
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
			DDLogDebug(@"Creating new Artist \"%@\"", artistName);
			[PASArtist _createArtist:artistName completion:completion];
			
		} else if (object && !error) {
			DDLogDebug(@"Found existing Artist \"%@\"", artistName);
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
		if (succeeded && !error) {
			[PASArtist _triggerAlbumFetching];
			completion(newArtist, nil);
		} else {
			completion(nil, error);
		}
	}];
}

+ (void)_triggerAlbumFetching
{
	NSURL *url = [NSURL URLWithString:@"https://api.parse.com/1/jobs/fetchFullAlbums"];
	NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
	req.HTTPMethod = @"POST";
	
	NSData *body = [NSJSONSerialization dataWithJSONObject:@{ @"i" : [PFInstallation currentInstallation].objectId }
												   options:NSJSONWritingPrettyPrinted error:nil];

	[req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
	[req setValue:[NSString stringWithFormat:@"%tu", [body length]] forHTTPHeaderField:@"Content-Length"];
	[req setValue:kPASParseAppId forHTTPHeaderField:@"X-Parse-Application-Id"];
	[req setValue:kPASParseMasterKey forHTTPHeaderField:@"X-Parse-Master-Key"];
	req.HTTPBody = body;
	
	[NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue mainQueue] completionHandler:nil];
}

- (void)_addCurrentUserAsFavoriteAndSave:(BOOL)saveUser completion:(void (^)(PASArtist *artist, NSError *error))completion
{
	// add artist to the users favorites
	PFUser *currentUser = [PFUser currentUser];
	NSArray *alreadyFavArtists = [currentUser objectForKey:@"favArtists"];
	
	if (alreadyFavArtists && [alreadyFavArtists containsObject:self.objectId]) {
		// this usually only happens if you are trying to fav a misspelled Artists
		// which you already faved with the correct name
		// AC/DC is fav but we could add ACDC
		// There are more problems in this case when removing, but lets not code for exceptions
		DDLogWarn(@"User \"%@\" has \"%@\" already favorited (The ACDC Problem)", currentUser.objectId, self.name);
		completion(self, nil);
		
	} else {
		DDLogDebug(@"Faving \"%@\" for User \"%@\"", self.name,  currentUser.objectId);
		
		[currentUser addObject:self.objectId forKey:@"favArtists"];
		if (saveUser) {
			[currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
				succeeded && !error ? completion(self, nil) : completion(nil, error);
			}];
		} else {
			completion(self, nil);
		}
	}
}

#pragma mark - removing / deleting

- (void)removeCurrentUserAsFavoriteWithCompletion:(void (^)(BOOL succeeded, NSError *error))completion
{
	NSAssert(self.objectId, @"The passed artist does not have a valid objectId. Maybe save the artist first.");
	// remove the relation
	PFUser *currentUser = [PFUser currentUser];
	[currentUser removeObject:self.objectId forKey:@"favArtists"];

	DDLogDebug(@"Removing \"%@\" from User \"%@\"", self.name, currentUser.objectId);
	
	NSDate *start = [NSDate date];
	[currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
		[PASArtist _logStats:start artistName:self.name success:(succeeded && !error) add:NO];
		completion(succeeded, error);
	}];
}

#pragma mark - Private Methods

+ (void)_logStats:(NSDate *)start artistName:(NSString *)artistName success:(BOOL)success add:(BOOL)add
{
	NSString *duration = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSinceDate:start]];
	NSString *faving = add ? @"favorite" : @"unfavorite";
	
	if (success) {
		DDLogInfo(@"Took %@ seconds to %@ Aritst \"%@\" for User \"%@\"", duration, faving, artistName, [PFUser currentUser].objectId);
	} else {
		DDLogInfo(@"Took %@ seconds and failed to %@ Aritst \"%@\" for User \"%@\"", duration, faving, artistName, [PFUser currentUser].objectId);
	}
}

@end
