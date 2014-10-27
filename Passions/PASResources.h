//
//  PASResources.h
//  Passions
//
//  Created by Simon Tännler on 04/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

@import UIKit;

// Constants
extern NSString * const kPASLastFmApiKey;
extern NSString * const kPASParseAppId;
extern NSString * const kPASParseClientKey;
extern NSString * const kPASParseMasterKey;

// Notification sent to pass the already favorited Artists
extern NSString * const kPASSetFavArtists;
// Notification received when favorite Artists have been edited
extern NSString * const kPASDidEditFavArtists;

// Notification received when album details should be shown for the passed Album
extern NSString * const kPASShowAlbumDetails;

// Notification sent when the initial Artists have been favorited.
extern NSString * const kPASDidFavoriteInitialArtists;

// Constant for Artist Artwork
extern NSString *const ImageFormatFamilyArtistThumbnails;
extern NSString *const ImageFormatNameArtistThumbnailSmall;
extern CGSize const ImageFormatImageSizeArtistThumbnailSmall;
extern NSString *const ImageFormatNameArtistThumbnailLarge;
extern CGSize const ImageFormatImageSizeArtistThumbnailLarge;

// Constant for Album Artwork
extern NSString *const ImageFormatFamilyAlbumThumbnails;
extern NSString *const ImageFormatNameAlbumThumbnailMedium;
extern CGSize const ImageFormatImageSizeAlbumThumbnailMedium;
extern NSString *const ImageFormatNameAlbumThumbnailLarge;
extern CGSize const ImageFormatImageSizeAlbumThumbnailLarge;

@interface PASResources : NSObject

+ (UIImage *) artistThumbnailPlaceholder;
+ (UIImage *) albumThumbnailPlaceholder;

+ (UIImage *)outlinedStar;
+ (UIImage *)favoritedStar;

+ (UIImage *)whitePixel;

+ (void)printViewControllerLayoutStack:(UIViewController *)viewController;
+ (void)printViewLayoutStack:(UIViewController *)vc;
+ (void)printSubviews:(UIView *)vw;
+ (void)printGestureRecognizerStack:(UIViewController *)viewController;

@end
