//
//  PASAddArtistsVC.m
//  Passions
//
//  Created by Simon Tännler on 11/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASAddArtistsVC.h"
#import "PASPageViewController.h"
#import "PASAddFromSamplesTVC.h"
#import "PASAddFromMusicTVC.h"

@interface PASAddArtistsVC ()
@property (nonatomic, strong) PASPageViewController *pageViewController;
@property (nonatomic, strong) UITableViewController *testTVC;
@property (weak, nonatomic) IBOutlet UIView *container;
@end

@implementation PASAddArtistsVC

#pragma mark - Init

- (void)awakeFromNib
{
	// Create the page view controller
	self.pageViewController = [[PASPageViewController alloc] initWithNibName:nil bundle:nil];
	
	// init and add the page view controllers view controllers
	self.pageViewController.viewControllers = @[[self _viewControllerAtIndex:0], [self _viewControllerAtIndex:1]];	
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.pageViewController.view.userInteractionEnabled = YES;
	
	// add the page view controller to the hierarchy
	[self addChildViewController:self.pageViewController];
	
	// Set the page view controller's bounds using an inset rect so that self's view is visible around the edges of the pages.
	self.pageViewController.view.frame = self.container.bounds;
	[self.container addSubview:self.pageViewController.view];
	
	// complete the process
	[self.pageViewController didMoveToParentViewController:self];
	
	UILabel *myLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 20, 20)];
	myLabel.backgroundColor = [UIColor blackColor];
	[self.container addSubview:myLabel];
	
	// DEBUG
	self.view.backgroundColor = [UIColor greenColor];
}

- (PASAddFromSamplesTVC *)_viewControllerAtIndex:(NSUInteger)index
{
	static PASAddFromSamplesTVC *addFromSamplesTVC;
	static PASAddFromMusicTVC *addFromMusicTVC;
	
	if (!addFromMusicTVC && !addFromMusicTVC) {
		addFromSamplesTVC = [[PASAddFromSamplesTVC alloc] initWithStyle:UITableViewStylePlain];
		addFromMusicTVC = [[PASAddFromMusicTVC alloc] initWithStyle:UITableViewStylePlain];
	}
	
	PASAddFromSamplesTVC *addArtistsTVC;
	switch (index) {
		case 0:
			if ([[UIDevice currentDevice].model containsString:@"Simulator"]) {
				addArtistsTVC = addFromSamplesTVC;
			} else {
				addArtistsTVC = addFromMusicTVC;
			}
			
			break;
			
		case 1:
			if ([[UIDevice currentDevice].model containsString:@"Simulator"]) {
				addArtistsTVC = addFromMusicTVC;
			} else {
				addArtistsTVC = addFromSamplesTVC;
			}
			break;
			
		default:
			addArtistsTVC = nil;
	}
	
	return addArtistsTVC;
}

@end
