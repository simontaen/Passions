//
//  PASResources.m
//  Passions
//
//  Created by Simon Tännler on 04/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASResources.h"

NSString * const kPASLastFmApiKey = @"aed3367b0133ab707cb4e5b6b04da3e7";
NSString * const kPASParseAppId = @"nLPKoK0wdW9csg2mTwwPkiGEDBh4AlU3f6il9qqQ";
NSString * const kPASParseClientKey = @"jxhd6vVmIttc1EVfre4Lcza9uwlKzDrCzqZJGSI9";
NSString * const kPASParseMasterKey = @"Mx6FjfJ4FYW6fi9Ra1G23AEcQuDgtm2xBH1yRhS7";

@implementation PASResources

+ (UIImage *) artistThumbnailPlaceholder
{
	static UIImage *artistThumbnailPlaceholder;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		artistThumbnailPlaceholder = [UIImage imageNamed: @"artistPlaceholder"];
	});
	return artistThumbnailPlaceholder;
}

+ (UIImage *) albumThumbnailPlaceholder
{
	return [self artistThumbnailPlaceholder];
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
