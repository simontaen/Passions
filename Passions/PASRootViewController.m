//
//  PASRootViewController.m
//  Passions
//
//  Created by Simon Tännler on 07/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASRootViewController.h"
#import "PASFavArtistsTVC.h"
#import "PASTimelineCVC.h"

@interface PASRootViewController ()
@end

@implementation PASRootViewController

#pragma mark - Init

- (void)awakeFromNib
{
    // Configure page view controller
	self.dataSource = self;
    [self setViewControllers:@[[self favArtistsNavController]]
				   direction:UIPageViewControllerNavigationDirectionForward
					animated:NO
				  completion:nil];
}

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

- (UINavigationController *)favArtistsNavController
{
	// Create a nav controller to hack around the status bar problem (also creates containing view controller)
	return [self.storyboard instantiateViewControllerWithIdentifier:@"FavArtistsNav"];
}

- (PASTimelineCVC *)timelineCVC
{
	return [self.storyboard instantiateViewControllerWithIdentifier:@"PASTimelineCVC"];
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
	if ([viewController isKindOfClass:[PASTimelineCVC class]]) {
		return [self favArtistsNavController];
	}
	return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
	if ([viewController isKindOfClass:[UINavigationController class]]) {
		return [self timelineCVC];
	}
	return nil;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return 2;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
	return 0;
}

@end
