//
//  PASResources.m
//  Passions
//
//  Created by Simon Tännler on 04/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASResources.h"

NSString * const kPASLastFmApiKey = @"aed3367b0133ab707cb4e5b6b04da3e7";

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

NSString * const kPASSetFavArtists = @"kPASSetFavArtists";
NSString * const kPASDidEditFavArtists = @"kPASDidEditFavArtists";

NSString * const kPASShowAlbumDetails = @"kPASShowAlbumDetails";

NSString * const kPASDidFavoriteInitialArtists = @"kPASDidFavoriteInitialArtists";

NSString *const ImageFormatFamilyArtistThumbnails = @"ImageFormatFamilyArtistThumbnails";
NSString *const ImageFormatNameArtistThumbnailSmall = @"ImageFormatNameArtistThumbnailSmall";
CGSize const ImageFormatImageSizeArtistThumbnailSmall = {43, 43};
NSString *const ImageFormatNameArtistThumbnailLarge = @"ImageFormatNameArtistThumbnailLarge";
CGSize const ImageFormatImageSizeArtistThumbnailLarge = {320, 320};

NSString *const ImageFormatFamilyAlbumThumbnails = @"ImageFormatFamilyAlbumThumbnails";
NSString *const ImageFormatNameAlbumThumbnailMedium = @"ImageFormatNameAlbumThumbnailMedium";
CGSize const ImageFormatImageSizeAlbumThumbnailMedium = {160, 160};
NSString *const ImageFormatNameAlbumThumbnailLarge = @"ImageFormatNameAlbumThumbnailLarge";
CGSize const ImageFormatImageSizeAlbumThumbnailLarge = {320, 320};

@implementation PASResources

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
	return [self artistThumbnailPlaceholder];
}

+ (UIImage *)outlinedStar
{
	static UIImage *outlinedStar;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		outlinedStar = [UIImage imageNamed: @"star"];
	});
	return outlinedStar;
}

+ (UIImage *)favoritedStar
{
	return [self outlinedStar];
}

+ (void)printViewControllerLayoutStack:(UIViewController *)viewController
{
	NSLog(@"---- ViewController Stack ----");
	UIViewController *vc = viewController;
	while (vc) {
		NSLog(@"%@ %@ | %@", NSStringFromClass([vc class]), NSStringFromCGRect(vc.view.bounds), NSStringFromCGRect(vc.view.frame));
		vc = vc.parentViewController;
	}
}

+ (void)printViewLayoutStack:(UIViewController *)vc
{
	NSLog(@"---- %@ ----", NSStringFromClass([vc class]));
	[self printSubviews:vc.view];
}

+ (void)printSubviews:(UIView *)vw
{
	NSLog(@"Container %@ %@ | %@", NSStringFromClass([vw class]), NSStringFromCGRect(vw.bounds), NSStringFromCGRect(vw.frame));
	for (UIView *aView in vw.subviews) {
		if (aView.subviews.count == 0) {
			return NSLog(@"%@ | %@ %@ ", NSStringFromCGRect(aView.bounds), NSStringFromCGRect(aView.frame), NSStringFromClass([aView class]));
		}
		[self printSubviews:aView];
	}
}

+ (void)printGestureRecognizerStack:(UIViewController *)viewController
{
	NSLog(@"---- Gesture Recognizer Stack ----");
	UIViewController *vc = viewController;
	while (vc) {
		NSString *vcName = NSStringFromClass([vc class]);
		for (UIGestureRecognizer *gr in vc.view.gestureRecognizers) {
			NSLog(@"%@: %@", vcName, NSStringFromClass([gr class]));
		}
		vc = vc.parentViewController;
	}
}
@end
