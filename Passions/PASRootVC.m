//
//  PASRootVC.m
//  Passions
//
//  Created by Simon Tännler on 12/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASRootVC.h"
#import "PASPageViewController.h"
#import "PASTimelineCVC.h"
#import "PASInteractiveTransition.h"

@interface PASRootVC ()
@property (nonatomic, strong) PASPageViewController *pageViewController;
@property (nonatomic, strong) PASInteractiveTransition *bla;
@end

@implementation PASRootVC

#pragma mark - Init

- (void)awakeFromNib
{
    // Create the page view controller
	self.pageViewController = [[PASPageViewController alloc] initWithNibName:nil bundle:nil];
	
	// TODO: temporary
	self.bla = [PASInteractiveTransition new];
	self.pageViewController.delegate = self.bla;

	// init and add the page view controllers view controllers
	self.pageViewController.viewControllers = @[[self _favArtistsNavController], [self _timelineCVC]];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
				
	// add the page view controller to the hierarchy
	[self addChildViewController:self.pageViewController];
	
	// Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
	self.pageViewController.view.frame = self.view.bounds;
	[self.view addSubview:self.pageViewController.view];
	
	// complete the process
	[self.pageViewController didMoveToParentViewController:self];
	
	// DEBUG
	self.view.backgroundColor = [UIColor yellowColor];
}

- (UINavigationController *)_favArtistsNavController
{
	// Create a nav controller to hack around the status bar problem (also creates containing view controller)
	return [self.storyboard instantiateViewControllerWithIdentifier:@"FavArtistsNav"];
}

- (PASTimelineCVC *)_timelineCVC
{
	return [self.storyboard instantiateViewControllerWithIdentifier:@"PASTimelineCVC"];
}

#pragma mark - UIViewController

- (BOOL)prefersStatusBarHidden
{
	return [self.pageViewController prefersStatusBarHidden];
}

@end
