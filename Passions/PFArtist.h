//
//  PFArtist.h
//  Passions
//
//  Created by Simon Tännler on 04/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFArtist : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString* objectId;
@property (nonatomic, strong) NSArray* albums; // of NSString referencing an Album Record
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* spotifyId;
@property (nonatomic, strong) NSNumber* totalAlbums;
@property (nonatomic, strong) NSDate* createdAt;
@property (nonatomic, strong) NSDate* updatedAt;
@property (nonatomic, strong) NSArray* images; // of NSString

#pragma mark - Parse

+ (NSString *)parseClassName;

#pragma mark - Queries

+ (PFQuery *)favArtistsForCurrentUser;

#pragma mark - adding / creating

+ (void)favoriteArtistByCurrentUser:(NSString *)artistName withBlock:(void (^)(PFArtist *artist, NSError *error))block;

#pragma mark - removing / deleting

+ (void)removeCurrentUserFromArtist:(PFArtist *)artist withBlock:(void (^)(BOOL succeeded, NSError *error))block;

@end
