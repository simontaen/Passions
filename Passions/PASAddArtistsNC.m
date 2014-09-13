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
@property (strong, nonatomic) PASPageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@end

@implementation PASAddArtistsNC

#pragma mark - Init

- (void)awakeFromNib
{
	// make sure the view initially does not slide below the nav bar
	self.edgesForExtendedLayout = UIRectEdgeLeft|UIRectEdgeBottom|UIRectEdgeRight;

	// setup the only child view controller
	self.pageViewController = [[PASPageViewController alloc] initWithNibName:nil bundle:nil];
	
	UIBarButtonItem *lbbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																		  target:self
																		  action:@selector(doneButtonHandler:)];
	// add the navigation item
	[self.pageViewController.navigationItem setLeftBarButtonItem:lbbi];
	
	// init and add the page view controllers view controllers
	self.pageViewController.viewControllers = @[[self viewControllerAtIndex:0], [self viewControllerAtIndex:1]];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// add the child to the nav controller
	[self pushViewController:self.pageViewController animated:NO];

	// DEBUG
	self.view.backgroundColor = [UIColor orangeColor];
}

- (PASAddFromSamplesTVC *)viewControllerAtIndex:(NSUInteger)index
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
			addArtistsTVC = addFromSamplesTVC;
			break;
			
		case 1:
			addArtistsTVC = addFromMusicTVC;
			break;
			
		default:
			addArtistsTVC = nil;
	}
	
	if (addArtistsTVC) {
		if ([self.parentViewController respondsToSelector:@selector(favArtistNames)]) {
			addArtistsTVC.favArtistNames = [self.parentViewController performSelector:@selector(favArtistNames) withObject:nil];
		}
	}
	
	return addArtistsTVC;
}

#pragma mark - Navigation

- (IBAction)doneButtonHandler:(UIBarButtonItem *)sender
{
	PASAddFromSamplesTVC *dissapearingTVC = ((PASAddFromSamplesTVC*) self.pageViewController.selectedViewController);
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
