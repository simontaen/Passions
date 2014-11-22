//
//  PASResources.m
//  Passions
//
//  Created by Simon Tännler on 04/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASResources.h"

//For archive build, use "Passions"
#ifndef DEBUG
NSString * const kPASParseAppId = @"ymoWy7LcvcSg1tEGehR46hgLAEGP2mR3wyePOsQd";
NSString * const kPASParseClientKey = @"Lp7MQjIGpM5O9Zp3CFyI8FU6NNmUBfa9xySu1Mgx";
NSString * const kPASParseMasterKey = @"3ZYFrBWkSWjbxkN7korFuRp1JqvdPzroDzjFp2E5";
#endif

//For developer build, use "PassionsDev"
#ifdef DEBUG
NSString * const kPASParseAppId = @"nLPKoK0wdW9csg2mTwwPkiGEDBh4AlU3f6il9qqQ";
NSString * const kPASParseClientKey = @"jxhd6vVmIttc1EVfre4Lcza9uwlKzDrCzqZJGSI9";
NSString * const kPASParseMasterKey = @"Mx6FjfJ4FYW6fi9Ra1G23AEcQuDgtm2xBH1yRhS7";
#endif

NSString * const kPASLastFmApiKey = @"aed3367b0133ab707cb4e5b6b04da3e7";
CGFloat const kPASLastFmTimeoutInSec = 5.0;

NSString * const kPASSpotifyClientId = @"e3e0a8c3a7c14f488c166528b08d095e";

NSString * const kPASDidEditFavArtists = @"kPASDidEditFavArtists";
NSString * const kPASDidEditArtistWithName = @"kPASDidEditArtistWithName";

NSString * const kPASShowAlbumDetails = @"kPASShowAlbumDetails";

NSString * const kPASDidFavoriteInitialArtists = @"kPASDidFavoriteInitialArtists";

NSString * const kITunesAffiliation = @"at=10lMuD";

CGFloat const kPASSizeArtistThumbnailSmall = 50;

NSString *const ImageFormatFamilyArtistThumbnails = @"ImageFormatFamilyArtistThumbnails";
NSString *const ImageFormatNameArtistThumbnailSmall = @"ImageFormatNameArtistThumbnailSmall";
CGSize const ImageFormatImageSizeArtistThumbnailSmall = {kPASSizeArtistThumbnailSmall, kPASSizeArtistThumbnailSmall};
NSString *const ImageFormatNameArtistThumbnailLarge = @"ImageFormatNameArtistThumbnailLarge";
CGSize const ImageFormatImageSizeArtistThumbnailLarge = {320, 320};

NSString *const ImageFormatFamilyAlbumThumbnails = @"ImageFormatFamilyAlbumThumbnails";
NSString *const ImageFormatNameAlbumThumbnailMedium = @"ImageFormatNameAlbumThumbnailMedium";
CGSize const ImageFormatImageSizeAlbumThumbnailMedium = {160, 160};
NSString *const ImageFormatNameAlbumThumbnailLarge = @"ImageFormatNameAlbumThumbnailLarge";
CGSize const ImageFormatImageSizeAlbumThumbnailLarge = {320, 320};

@implementation PASResources

+ (NSURL *)spotifyCallbackUri
{
	static NSURL *spotifyCallbackUri;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		spotifyCallbackUri = [NSURL URLWithString:@"passionsapp://"];
	});
	return spotifyCallbackUri;
}

+ (NSURL *)spotifyTokenSwap
{
	static NSURL *spotifyTokenSwap;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		spotifyTokenSwap = [NSURL URLWithString:@"https://nameless-spire-5298.herokuapp.com/swap"];
	});
	return spotifyTokenSwap;
}

+ (NSURL *)spotifyTokenRefresh
{
	static NSURL *spotifyTokenRefresh;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		spotifyTokenRefresh = [NSURL URLWithString:@"https://nameless-spire-5298.herokuapp.com/refresh"];
	});
	return spotifyTokenRefresh;
}

+ (UIImage *)spotifyLogin
{
	static UIImage *spotifyLogin;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		spotifyLogin = [UIImage imageNamed: @"spotifyLogin"];
	});
	return spotifyLogin;
}

+ (UIImage *)artistThumbnailPlaceholder
{
	static UIImage *artistThumbnailPlaceholder;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		artistThumbnailPlaceholder = [UIImage imageNamed: @"artistPlaceholder"];
	});
	return artistThumbnailPlaceholder;
}

+ (UIImage *)albumThumbnailPlaceholder
{
	static UIImage *albumThumbnailPlaceholder;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		albumThumbnailPlaceholder = [UIImage imageNamed: @"albumPlaceholder"];
	});
	return albumThumbnailPlaceholder;
}

+ (UIImage *)outlinedStar
{
	static UIImage *outlinedStar;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		outlinedStar = [UIImage imageNamed: @"outlinedStar"];
	});
	return outlinedStar;
}

+ (UIImage *)favoritedStar
{
	static UIImage *favoritedStar;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		favoritedStar = [UIImage imageNamed: @"favoritedStar"];
	});
	return favoritedStar;
}

+ (UIImage *)swipeLeft
{
	static UIImage *swipeLeft;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		swipeLeft = [UIImage imageNamed: @"swipeLeft"];
	});
	return swipeLeft;
}

+ (void)printViewControllerLayoutStack:(UIViewController *)viewController
{
	CLS_LOG(@"---- ViewController Stack ----");
	UIViewController *vc = viewController;
	while (vc) {
		CLS_LOG(@"%@ %@ | %@", NSStringFromClass([vc class]), NSStringFromCGRect(vc.view.bounds), NSStringFromCGRect(vc.view.frame));
		vc = vc.parentViewController;
	}
}

+ (void)printViewLayoutStack:(UIViewController *)vc
{
	CLS_LOG(@"---- %@ ----", NSStringFromClass([vc class]));
	[self printSubviews:vc.view];
}

+ (void)printSubviews:(UIView *)vw
{
	CLS_LOG(@"Container %@ %@ | %@", NSStringFromClass([vw class]), NSStringFromCGRect(vw.bounds), NSStringFromCGRect(vw.frame));
	for (UIView *aView in vw.subviews) {
		if (aView.subviews.count == 0) {
			return CLS_LOG(@"%@ | %@ %@ ", NSStringFromCGRect(aView.bounds), NSStringFromCGRect(aView.frame), NSStringFromClass([aView class]));
		}
		[self printSubviews:aView];
	}
}

+ (void)printGestureRecognizerStack:(UIViewController *)viewController
{
	CLS_LOG(@"---- Gesture Recognizer Stack ----");
	UIViewController *vc = viewController;
	while (vc) {
		NSString *vcName = NSStringFromClass([vc class]);
		for (UIGestureRecognizer *gr in vc.view.gestureRecognizers) {
			CLS_LOG(@"%@: %@", vcName, NSStringFromClass([gr class]));
		}
		vc = vc.parentViewController;
	}
}
@end
