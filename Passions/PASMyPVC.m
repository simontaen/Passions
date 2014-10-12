//
//  PASMyPVC.m
//  Passions
//
//  Created by Simon Tännler on 12/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASMyPVC.h"
#import "PASAddFromSamplesTVC.h"
#import "PASAddFromMusicTVC.h"

@interface PASMyPVC ()
@property (weak, nonatomic) IBOutlet UIToolbar *segmentbar;
@end

@implementation PASMyPVC

#pragma mark - Accessors

- (void)setFavArtists:(NSMutableArray *)favArtists
{
	for (PASAddFromSamplesTVC *vc in self.viewControllers) {
		vc.favArtists = favArtists;
	}
}

#pragma mark - Init

- (void)awakeFromNib
{
	[super awakeFromNib];

	// init and add the page view controllers view controllers
	self.viewControllers = @[[self _viewControllerAtIndex:0], [self _viewControllerAtIndex:1]];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];

	// Setup navigationBar Items
	UIBarButtonItem *lbbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
																		  target:self
																		  action:@selector(doneButtonHandler:)];
	self.navigationItem.leftBarButtonItem = lbbi;
	UIBarButtonItem *rbbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																		  target:self
																		  action:@selector(doneButtonHandler:)];
	self.navigationItem.rightBarButtonItem = rbbi;
	
	// The navigation bar's shadowImage is set to a transparent image.  In
	// conjunction with providing a custom background image, this removes
	// the grey hairline at the bottom of the navigation bar.  The
	// ExtendedNavBarView will draw its own hairline.
	self.navigationController.navigationBar.shadowImage = [UIImage imageNamed:@"TransparentPixel"];
	[self.segmentbar setShadowImage:[UIImage imageNamed:@"TransparentPixel"] forToolbarPosition:UIBarPositionAny];
	// "Pixel" is a solid white 1x1 image.
	[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"Pixel"] forBarMetrics:UIBarMetricsDefault];
	[self.segmentbar setBackgroundImage:[UIImage imageNamed:@"Pixel"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
	
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

#pragma mark - Navigation

- (IBAction)doneButtonHandler:(UIBarButtonItem *)sender
{
	PASAddFromSamplesTVC *dissapearingTVC = ((PASAddFromSamplesTVC*) self.selectedViewController);
	if ([self.myDelegate respondsToSelector:@selector(viewController:didEditArtists:)]) {
		[self.myDelegate viewController:dissapearingTVC didEditArtists:[dissapearingTVC didEditArtists]];
	} else {
		[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
	}
}

@end
