//
//  PASArtist.h
//  Passions
//
//  Created by Simon Tännler on 04/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import <Parse/Parse.h>

@interface PASArtist : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString* objectId;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* spotifyId;
@property (nonatomic, strong) NSNumber* totalAlbums;
@property (nonatomic, strong) NSArray* images; // of NSString
@property (nonatomic, strong) NSArray* favByUsers; // of NSString PFUser.objectId
@property (nonatomic, strong) NSDate* createdAt;
@property (nonatomic, strong) NSDate* updatedAt;

#pragma mark - Parse

+ (NSString *)parseClassName;

#pragma mark - Queries

+ (PFQuery *)favArtistsForCurrentUser;

#pragma mark - adding / creating

+ (void)favoriteArtistByCurrentUser:(NSString *)artistName withBlock:(void (^)(PASArtist *artist, NSError *error))block;

#pragma mark - removing / deleting

+ (void)removeCurrentUserFromArtist:(PASArtist *)artist withBlock:(void (^)(BOOL succeeded, NSError *error))block;

@end
