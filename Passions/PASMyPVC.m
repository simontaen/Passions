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
@property (weak, nonatomic) UIImageView *navHairline;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
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
	self.view.backgroundColor = [UIColor whiteColor];

	// Setup navigationBar Items
	UIBarButtonItem *lbbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
																		  target:self
																		  action:@selector(doneButtonHandler:)];
	self.navigationItem.leftBarButtonItem = lbbi;
	UIBarButtonItem *rbbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																		  target:self
																		  action:@selector(doneButtonHandler:)];
	self.navigationItem.rightBarButtonItem = rbbi;
	
	// Setup segmentedControl
	[self.segmentedControl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
	
	// find the hairline below the navigationBar
	for (UIView *aView in self.navigationController.navigationBar.subviews) {
		for (UIView *bView in aView.subviews) {
			if ([bView isKindOfClass:[UIImageView class]] &&
				bView.bounds.size.width == self.navigationController.navigationBar.frame.size.width &&
				bView.bounds.size.height < 2) {
				self.navHairline = (UIImageView *)bView;
			}
		}
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self _moveHairline:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[self _moveHairline:NO];
}

- (void)_moveHairline:(BOOL)appearing
{
	// move the hairline below the segmentbar
	CGRect hairlineFrame = self.navHairline.frame;
	if (appearing) {
		hairlineFrame.origin.y += self.segmentbar.bounds.size.height;
	} else {
		hairlineFrame.origin.y -= self.segmentbar.bounds.size.height;
	}
	self.navHairline.frame = hairlineFrame;
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

#pragma mark - Ordering

- (IBAction)segmentChanged:(UISegmentedControl *)sender
{
	NSLog(@"Selected Segment: %ld", (long)[sender selectedSegmentIndex]);
}

@end
