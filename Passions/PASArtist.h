//
//  PASArtist.h
//  Passions
//
//  Created by Simon Tännler on 04/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import <Parse/Parse.h>
#import "PASParseObjectWithImages.h"

@interface PASArtist : PASParseObjectWithImages <PFSubclassing>

@property (nonatomic, strong) NSString* objectId;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSNumber* iTunesId;
@property (nonatomic, strong) NSDictionary* iTunesUrlMap;
@property (nonatomic, strong) NSString* iTunesGenreName;
@property (nonatomic, strong) NSNumber* iTunesGenreId;
@property (nonatomic, strong) NSString* iTunesRadioUrl;
@property (nonatomic, strong) NSNumber* amgId;
@property (nonatomic, strong) NSNumber* totalAlbums;
@property (nonatomic, strong) NSArray* favByUsers; // of NSString PFUser.objectId
@property (nonatomic, strong) NSString* spotifyId;
@property (nonatomic, strong) NSString* spotifyUrl;
@property (nonatomic, strong) NSDate* createdAt;
@property (nonatomic, strong) NSDate* updatedAt;

#pragma mark - Parse

+ (NSString *)parseClassName;

#pragma mark - Queries

+ (PFQuery *)favArtistsForCurrentUser;

#pragma mark - Compound properties

- (NSString *)availableAlbums;
- (NSURL *)iTunesAttributedUrl;
- (NSString *)iTunesUrl;
- (BOOL)isProcessingOnServer;

#pragma mark - adding / creating

+ (void)favoriteArtistByCurrentUser:(NSString *)artistName
					needsCorrection:(BOOL)needsCorrection
						   saveUser:(BOOL)saveUser
				  timeoutMultiplier:(float)multiplier
						 completion:(void (^)(PASArtist *artist, NSError *error))completion;

#pragma mark - removing / deleting

- (void)removeCurrentUserAsFavoriteWithCompletion:(void (^)(BOOL succeeded, NSError *error))completion;

@end
