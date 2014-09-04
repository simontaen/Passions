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
@property (nonatomic, strong) NSDictionary* albums; // NSString -> NSDictionary, id -> full Album record
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* spotifyId;
@property (nonatomic, strong) NSNumber* totalAlbums;
@property (nonatomic, strong) NSDate* createdAt;
@property (nonatomic, strong) NSDate* updatedAt;
@property (nonatomic, strong) NSArray* favByUsers; // of PFUsers
@property (nonatomic, strong) NSArray* images; // of NSString

#pragma mark - Parse

+ (NSString *)parseClassName;

#pragma mark - Queries

+ (PFQuery *)favArtistsForCurrentUser;

#pragma mark - Actions

+ (void)favoriteArtist:(NSString *)artist byUser:(PFUser *)user;
@end
