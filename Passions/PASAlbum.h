//
//  PASAlbum.h
//  Passions
//
//  Created by Simon Tännler on 04/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import <Parse/Parse.h>
#import "PASParseObjectWithImages.h"

extern NSString *const ImageFormatFamilyAlbumThumbnails;
extern NSString *const ImageFormatNameAlbumThumbnailMedium;
extern CGSize const ImageFormatImageSizeAlbumThumbnailMedium;

@interface PASAlbum : PASParseObjectWithImages <PFSubclassing>

@property (nonatomic, strong) NSString* objectId;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* spotifyId;
@property (nonatomic, strong) NSString* href;
@property (nonatomic, strong) NSString* artistId; // PASArtist.objectId
@property (nonatomic, strong) NSString* releaseDate;
@property (nonatomic, strong) NSString* releaseDatePrecision;
@property (nonatomic, strong) NSNumber* utc;
@property (nonatomic, strong) NSDate* createdAt;
@property (nonatomic, strong) NSDate* updatedAt;

#pragma mark - Parse

+ (NSString *)parseClassName;

#pragma mark - Queries

+ (PFQuery *)albumsOfCurrentUsersFavoriteArtists;

@end