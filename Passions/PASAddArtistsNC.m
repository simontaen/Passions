//
//  PASAddArtistsNC.m
//  Passions
//
//  Created by Simon Tännler on 07/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASAddArtistsNC.h"
#import "PASPageViewController.h"
#import "PASAddFromSamplesTVC.h"
#import "PASAddFromMusicTVC.h"

@interface PASAddArtistsNC ()
@property (nonatomic, strong) PASPageViewController *pageViewController;
@end

@implementation PASAddArtistsNC

#pragma mark - Accessors

- (void)setFavArtists:(NSMutableArray *)favArtists
{
	for (PASAddFromSamplesTVC *vc in self.pageViewController.viewControllers) {
		vc.favArtists = favArtists;
	}
}

#pragma mark - Init

- (void)awakeFromNib
{
	// setup the only child view controller
	self.pageViewController = [[PASPageViewController alloc] initWithNibName:nil bundle:nil];
	// don't scroll under top bars, pageViewController does not support automaticallyAdjustsScrollViewInsets
	self.pageViewController.edgesForExtendedLayout = UIRectEdgeLeft|UIRectEdgeBottom|UIRectEdgeRight;
	
	UIBarButtonItem *lbbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																		  target:self
																		  action:@selector(doneButtonHandler:)];
	// add the navigation item
	[self.pageViewController.navigationItem setLeftBarButtonItem:lbbi];
	
	// init and add the page view controllers view controllers
	self.pageViewController.viewControllers = @[[self _viewControllerAtIndex:0], [self _viewControllerAtIndex:1]];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// add the child to the nav controller
	[self pushViewController:self.pageViewController animated:NO];
	// make sure the NavBar looks the same as on PASFavArtistsTVC
	self.view.backgroundColor = [UIColor whiteColor];
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

#pragma mark - Navigation

- (IBAction)doneButtonHandler:(UIBarButtonItem *)sender
{
	PASAddFromSamplesTVC *dissapearingTVC = ((PASAddFromSamplesTVC*) self.pageViewController.selectedViewController);
	if ([self.myDelegate respondsToSelector:@selector(viewController:didEditArtists:)]) {
		[self.myDelegate viewController:dissapearingTVC didEditArtists:[dissapearingTVC didEditArtists]];
	}
}

@end
