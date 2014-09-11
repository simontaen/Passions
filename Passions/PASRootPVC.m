//
//  PASRootPVC.m
//  Passions
//
//  Created by Simon Tännler on 09/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASRootPVC.h"

@interface PASRootPVC ()

@end

@implementation PASRootPVC

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	UIPageControl *pageControl = [UIPageControl appearanceWhenContainedIn:[self class], nil];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
	pageControl.backgroundColor = [UIColor clearColor];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
//	for (UIView *view in self.view.subviews) {
//		if ([view isKindOfClass:[NSClassFromString(@"_UIQueuingScrollView") class]]) {
//			// extend the height of the scrollview
//			CGRect frame = view.frame;
//			frame.size.height = view.superview.frame.size.height;
//			view.frame = frame;
//		} else 	if ([view isKindOfClass:[NSClassFromString(@"UIPageControl") class]]) {
//			// make sure the page control is the topmost
//			[self.view bringSubviewToFront:view];
//		}
//		
//	}
	NSLog(@"viewDidLayoutSubviews %@", NSStringFromClass([self class]));
}

@end
