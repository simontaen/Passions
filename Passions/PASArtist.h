//
//  PASArtist.h
//  Passions
//
//  Created by Simon Tännler on 04/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import <Parse/Parse.h>
#import "PASParseObjectWithImages.h"

extern NSString *const ImageFormatFamilyArtistThumbnails;
extern NSString *const ImageFormatNameArtistThumbnailSmall;
extern CGSize const ImageFormatImageSizeArtistThumbnailSmall;
extern NSString *const ImageFormatNameArtistThumbnailLarge;
extern CGSize const ImageFormatImageSizeArtistThumbnailLarge;

@interface PASArtist : PASParseObjectWithImages <PFSubclassing>

@property (nonatomic, strong) NSString* objectId;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* iTunesId;
@property (nonatomic, strong) NSString* iTunesLink;
@property (nonatomic, strong) NSNumber* totalAlbums;
@property (nonatomic, strong) NSArray* favByUsers; // of NSString PFUser.objectId
@property (nonatomic, strong) NSString* spotifyId;
@property (nonatomic, strong) NSDate* createdAt;
@property (nonatomic, strong) NSDate* updatedAt;

#pragma mark - Parse

+ (NSString *)parseClassName;

#pragma mark - Queries

+ (PFQuery *)favArtistsForCurrentUser;

#pragma mark - Compound properties

- (NSString *)availableAlbums;

#pragma mark - adding / creating

+ (void)favoriteArtistByCurrentUser:(NSString *)artistName
					needsCorrection:(BOOL)needsCorrection
						 completion:(void (^)(PASArtist *artist, NSError *error))completion;

#pragma mark - removing / deleting

- (void)removeCurrentUserAsFavoriteWithCompletion:(void (^)(BOOL succeeded, NSError *error))completion;

@end
