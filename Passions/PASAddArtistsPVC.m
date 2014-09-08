//
//  PASAddArtistsPVC.m
//  Passions
//
//  Created by Simon Tännler on 07/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASAddArtistsPVC.h"
#import "PASAddFromSamplesTVC.h"
#import "PASResources.h"

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
    
    // Init the page view controller
	self.dataSource = self;
	[self setViewControllers:@[[self viewControllerAtIndex:0]]
				   direction:UIPageViewControllerNavigationDirectionForward
					animated:NO
				  completion:nil];
	self.edgesForExtendedLayout = UIRectEdgeLeft|UIRectEdgeBottom|UIRectEdgeRight;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[PASResources printViewLayoutStack:self];
}

- (PASAddFromSamplesTVC *)viewControllerAtIndex:(NSUInteger)index
{
	PASAddFromSamplesTVC *addArtistsTVC;
	switch (index) {
		case 0:
			addArtistsTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PASAddFromSamplesTVC"];
			break;
			
		case 1:
			addArtistsTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PASAddFromMusicTVC"];
			break;
			
		default:
			addArtistsTVC = nil;
	}
	addArtistsTVC.pageIndex = index;
	if ([self.parentViewController respondsToSelector:@selector(favArtistNames)]) {
		addArtistsTVC.favArtistNames = [self.parentViewController performSelector:@selector(favArtistNames) withObject:nil];
	}
	
	return addArtistsTVC;
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
	PASAddFromSamplesTVC *dissapearingTVC = ((PASAddFromSamplesTVC*) self.viewControllers[0]);
	if ([dissapearingTVC didAddArtists]) {
		if ([self.parentViewController respondsToSelector:@selector(favArtistsTVC)]) {
			PASFavArtistsTVC *favArtistsTVC = [self.parentViewController performSelector:@selector(favArtistsTVC) withObject:nil];
			[favArtistsTVC refreshUI];
		}
	}
	
	// Go back to the previous view
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
