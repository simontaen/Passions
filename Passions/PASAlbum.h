//
//  PASAlbum.h
//  Passions
//
//  Created by Simon Tännler on 04/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import <Parse/Parse.h>
#import "PASParseObjectWithImages.h"

@interface PASAlbum : PASParseObjectWithImages <PFSubclassing>

@property (nonatomic, strong) NSString* objectId;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSNumber* iTunesId;
@property (nonatomic, strong) NSDictionary* iTunesUrlMap;
@property (nonatomic, strong) NSString* explicitness;
@property (nonatomic, strong) NSNumber* trackCount;
@property (nonatomic, strong) NSString* iTunesGenreName;
@property (nonatomic, strong) NSString* artistId; // PASArtist.objectId
@property (nonatomic, strong) NSString* artistName; // PASArtist.name
@property (nonatomic, strong) NSDate* releaseDate;
@property (nonatomic, strong) NSString* spotifyId;
@property (nonatomic, strong) NSString* spotifyLink;
@property (nonatomic, strong) NSDate* createdAt;
@property (nonatomic, strong) NSDate* updatedAt;

#pragma mark - Parse

+ (NSString *)parseClassName;

#pragma mark - Queries

+ (PFQuery *)albumsOfCurrentUsersFavoriteArtists;

#pragma mark - Compound properties

- (NSURL *)iTunesAttributedUrl;
- (NSString *)iTunesUrl;
@property (nonatomic, strong, readonly) NSString* releaseDateFormatted;

@end
