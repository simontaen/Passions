//
//  PASResources.m
//  Passions
//
//  Created by Simon Tännler on 04/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASResources.h"

@implementation PASResources

+ (UIImage *) artistThumbnailPlaceholder
{
	static UIImage *artistThumbnailPlaceholder;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		artistThumbnailPlaceholder = [UIImage imageNamed: @"image.png"];
	});
	return artistThumbnailPlaceholder;
}

+ (UIImage *) albumThumbnailPlaceholder
{
	return [self artistThumbnailPlaceholder];
}

+ (void)printViewControllerLayoutStack:(UIViewController *)viewController
{
	UIViewController *vc = viewController;
	while (vc) {
		NSLog(@"%@ %@ | %@", NSStringFromClass([vc class]), NSStringFromCGRect(vc.view.bounds), NSStringFromCGRect(vc.view.frame));
		vc = vc.parentViewController;
	}
}

+ (void)printViewLayoutStack:(UIViewController *)vc
{
	NSLog(@"%@ %@ | %@", NSStringFromClass([vc.view class]), NSStringFromCGRect(vc.view.bounds), NSStringFromCGRect(vc.view.frame));
	for (UIView *aView in vc.view.subviews) {
		NSLog(@"%@ %@ | %@", NSStringFromClass([aView class]), NSStringFromCGRect(aView.bounds), NSStringFromCGRect(aView.frame));
	}
}


@end
