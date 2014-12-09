//
//  PASResources.m
//  Passions
//
//  Created by Simon Tännler on 04/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASResources.h"
#import "SPTImage.h"

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

NSString * const kPASLastFmApiKey = @"c830eb62c631873914abae9f0bf22d40";
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

NSString *const ImageFormatFamilyAlbumThumbnails = @"ImageFormatFamilyAlbumThumbnails";
NSString *const ImageFormatNameAlbumThumbnailMedium = @"ImageFormatNameAlbumThumbnailMedium";
NSString *const ImageFormatNameAlbumThumbnailLarge = @"ImageFormatNameAlbumThumbnailLarge";

@implementation PASResources

+ (CGSize)imageFormatImageSizeArtistThumbnailLarge
{
	return [PASResources imageFormatImageSizeAlbumThumbnailLarge];
}

+ (CGSize)imageFormatImageSizeAlbumThumbnailMedium
{
	static CGSize imageFormatImageSizeAlbumThumbnailMedium;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		CGFloat halfSize = [UIScreen mainScreen].bounds.size.width / 2;
		imageFormatImageSizeAlbumThumbnailMedium = CGSizeMake(halfSize, halfSize);
	});
	return imageFormatImageSizeAlbumThumbnailMedium;
}

+ (CGSize)imageFormatImageSizeAlbumThumbnailLarge
{
	static CGSize imageFormatImageSizeAlbumThumbnailLarge;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		CGFloat fullSize = [UIScreen mainScreen].bounds.size.width;
		imageFormatImageSizeAlbumThumbnailLarge = CGSizeMake(fullSize, fullSize);
	});
	return imageFormatImageSizeAlbumThumbnailLarge;
}

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

+ (UIImage *)artistPlaceholder
{
	static UIImage *artistPlaceholder;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		artistPlaceholder = [UIImage imageNamed: @"artistPlaceholder"];
	});
	return artistPlaceholder;
}

+ (UIImage *)artistPlaceholderSmall
{
	static UIImage *artistPlaceholderSmall;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		artistPlaceholderSmall = [UIImage imageNamed: @"artistPlaceholderSmall"];
	});
	return artistPlaceholderSmall;
}

+ (UIImage *)albumPlaceholder
{
	static UIImage *albumPlaceholder;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		albumPlaceholder = [UIImage imageNamed: @"albumPlaceholder"];
	});
	return albumPlaceholder;
}

+ (UIImage *)albumPlaceholderHalf
{
	static UIImage *albumPlaceholderHalf;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		albumPlaceholderHalf = [UIImage imageNamed: @"albumPlaceholderHalf"];
	});
	return albumPlaceholderHalf;
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

+ (NSString *)userCountry
{
	NSLocale *locale = [NSLocale autoupdatingCurrentLocale];
	return [locale objectForKey: NSLocaleCountryCode];
}

+ (NSURL *)optimalImageUrlForParseObjects:(NSArray *)images
{
	if (images.count == 0) {
		return nil;
	}
	
	CGFloat screenWidth = [UIScreen mainScreen].nativeBounds.size.width;
	NSDictionary *smallestImgObjForScreen;
	
	for (NSDictionary *imgObj in images) {
		NSNumber *imgWidth = imgObj[@"width"];
		
		if ([imgWidth floatValue] >= screenWidth) {
			smallestImgObjForScreen = imgObj;
		}
	}
	NSString *url = smallestImgObjForScreen ? smallestImgObjForScreen[@"url"] : [images firstObject][@"url"];
	return [NSURL URLWithString:url];
}

+ (NSURL *)optimalImageUrlForSpotifyObjects:(NSArray *)images
{
	if (images.count == 0) {
		return nil;
	}
	
	CGFloat targetSize = kPASSizeArtistThumbnailSmall * [UIScreen mainScreen].nativeScale;
	SPTImage *biggestImgObj;
	SPTImage *optimalImgObj;
	CGFloat optimalDistance;
	
	for (SPTImage *imgObj in images) {
		CGFloat imgWidth = imgObj.size.width;
		CGFloat distance = imgWidth - targetSize;

		if (!optimalImgObj) {
			biggestImgObj = imgObj;
			optimalImgObj = imgObj;
			optimalDistance = distance >= 0 ?: MAXFLOAT;
			
		} else {
			if (distance >= 0 && distance < optimalDistance) {
				optimalDistance = distance;
				optimalImgObj = imgObj;
			}
			
			if (imgWidth > biggestImgObj.size.width) {
				biggestImgObj = imgObj;
			}
		}
	}
	
	if (optimalImgObj) {
		return optimalImgObj.imageURL;
	} else {
		return biggestImgObj.imageURL;
	}
}

+ (void)printViewControllerLayoutStack:(UIViewController *)viewController
{
	DDLogVerbose(@"---- ViewController Stack ----");
	UIViewController *vc = viewController;
	while (vc) {
		DDLogVerbose(@"%@ %@ | %@", NSStringFromClass([vc class]), NSStringFromCGRect(vc.view.bounds), NSStringFromCGRect(vc.view.frame));
		vc = vc.parentViewController;
	}
}

+ (void)printViewLayoutStack:(UIViewController *)vc
{
	DDLogVerbose(@"---- %@ ----", NSStringFromClass([vc class]));
	[self printSubviews:vc.view];
}

+ (void)printSubviews:(UIView *)vw
{
	DDLogVerbose(@"Container %@ %@ | %@", NSStringFromClass([vw class]), NSStringFromCGRect(vw.bounds), NSStringFromCGRect(vw.frame));
	for (UIView *aView in vw.subviews) {
		if (aView.subviews.count == 0) {
			DDLogVerbose(@"%@ | %@ %@", NSStringFromCGRect(aView.bounds), NSStringFromCGRect(aView.frame), NSStringFromClass([aView class]));
		}
		[self printSubviews:aView];
	}
}

+ (void)printGestureRecognizerStack:(UIViewController *)viewController
{
	DDLogVerbose(@"---- Gesture Recognizer Stack ----");
	UIViewController *vc = viewController;
	while (vc) {
		for (UIGestureRecognizer *gr in vc.view.gestureRecognizers) {
			DDLogVerbose(@"%@: %@", NSStringFromClass([vc class]), NSStringFromClass([gr class]));
		}
		vc = vc.parentViewController;
	}
}
@end
