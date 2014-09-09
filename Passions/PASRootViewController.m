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
#import "PASRootPVC.h"

@interface PASRootViewController ()
@property (strong, nonatomic) UIPageViewController *pageViewController;
@end

@implementation PASRootViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	//self.view.backgroundColor = [UIColor redColor];
	self.pageViewController.view.backgroundColor = [UIColor blueColor];
    
    // Create and init page view controller
	self.pageViewController = [[PASRootPVC alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
															  navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
																			options:@{UIPageViewControllerOptionSpineLocationKey : @(UIPageViewControllerSpineLocationNone)}];
	self.pageViewController.dataSource = self;
    [self.pageViewController setViewControllers:@[[self favArtistsNavController]]
									  direction:UIPageViewControllerNavigationDirectionForward
									   animated:NO
									 completion:nil];
	// add the page view controller to hierarchy
	[self addChildViewController:self.pageViewController];
	[self.view addSubview:self.pageViewController.view];
	// Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
	CGRect pageViewRect = self.view.bounds;
	self.pageViewController.view.frame = pageViewRect;
	[self.pageViewController didMoveToParentViewController:self];
	// Add the page view controller's gesture recognizers to the book view controller's view so that the gestures are started more easily.
	self.view.gestureRecognizers = self.pageViewController.gestureRecognizers;
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
