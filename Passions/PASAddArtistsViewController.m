//
//  PASAddArtistsViewController.m
//  Passions
//
//  Created by Simon Tännler on 07/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASAddArtistsViewController.h"
#import "PASAddArtistsNavController.h"
#import "PASAddFromSamplesTVC.h"

// Number of Pages the page view controller displays
static int const kNumberOfPages = 2;

@interface PASAddArtistsViewController ()
@property (strong, nonatomic) UIPageViewController *pageViewController;
@end

@implementation PASAddArtistsViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create and init page view controller
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
															  navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
																			options:@{UIPageViewControllerOptionSpineLocationKey : @(UIPageViewControllerSpineLocationNone)}];
    self.pageViewController.dataSource = self;
    [self.pageViewController setViewControllers:@[[self viewControllerAtIndex:0]]
									  direction:UIPageViewControllerNavigationDirectionForward
									   animated:NO
									 completion:nil];
	// add the page view controller to hierarchy
	[self addChildViewController:self.pageViewController];
	[self.view addSubview:self.pageViewController.view];
	[self.pageViewController didMoveToParentViewController:self];
}

- (PASAddArtistsNavController *)viewControllerAtIndex:(NSUInteger)index
{
	PASAddArtistsNavController *addArtistsNavC;
	switch (index) {
		case 0:
			addArtistsNavC = [self.storyboard instantiateViewControllerWithIdentifier:@"PASAddArtistsNavController"];
			break;
			
		case 1:
			addArtistsNavC = [self.storyboard instantiateViewControllerWithIdentifier:@"PASAddArtistsNavController"];
			break;
			
		default:
			addArtistsNavC = nil;
	}
	addArtistsNavC.pageIndex = index;
	addArtistsNavC.favArtistNames = self.favArtistNames;
	
	return addArtistsNavC;
}

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PASAddArtistsNavController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PASAddArtistsNavController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == kNumberOfPages) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return kNumberOfPages;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

@end
