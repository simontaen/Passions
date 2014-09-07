//
//  PASAddArtistsPVC.m
//  Passions
//
//  Created by Simon Tännler on 07/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASAddArtistsPVC.h"
#import "PASAddFromSamplesTVC.h"

// Number of Pages the page view controller displays
static int const kNumberOfPages = 2;

@interface PASAddArtistsPVC ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@end

@implementation PASAddArtistsPVC

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create and init page view controller
	//    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
	//															  navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
	//																			options:@{UIPageViewControllerOptionSpineLocationKey : @(UIPageViewControllerSpineLocationNone)}];
	self.dataSource = self;
	[self setViewControllers:@[[self viewControllerAtIndex:0]]
				   direction:UIPageViewControllerNavigationDirectionForward
					animated:NO
				  completion:nil];
	//	// add the page view controller to hierarchy
	//	[self addChildViewController:self.pageViewController];
	//	[self.view addSubview:self.pageViewController.view];
	//	[self.pageViewController didMoveToParentViewController:self];
}

- (PASAddFromSamplesTVC *)viewControllerAtIndex:(NSUInteger)index
{
	PASAddFromSamplesTVC *addArtistsNavC;
	switch (index) {
		case 0:
			addArtistsNavC = [self.storyboard instantiateViewControllerWithIdentifier:@"PASAddFromSamplesTVC"];
			break;
			
		case 1:
			addArtistsNavC = [self.storyboard instantiateViewControllerWithIdentifier:@"PASAddFromSamplesTVC"];
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
    NSUInteger index = ((PASAddFromSamplesTVC*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PASAddFromSamplesTVC*) viewController).pageIndex;
    
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

#pragma mark - Navigation

- (IBAction)doneButtonHandler:(UIBarButtonItem *)sender
{
//	if (self.favArtistNames.count != 0) {
//		[self.previousController refreshUI];
//	}
	// Go back to the previous view
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
