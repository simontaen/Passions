//
//  PASMyPVC.m
//  Passions
//
//  Created by Simon Tännler on 12/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASMyPVC.h"
#import "PASExtendedNavContainer.h"
#import "PASFavArtistsTVC.h"

@interface PASMyPVC ()
@property (weak, nonatomic) UIImageView *navHairline;
@end

@implementation PASMyPVC

#pragma mark - Init

- (void)awakeFromNib
{
	[super awakeFromNib];
	// init and add the page view controllers view controllers
	self.viewControllers = @[[self _viewControllerAtIndex:0], [self _viewControllerAtIndex:1]];
}

- (PASExtendedNavContainer *)_viewControllerAtIndex:(NSUInteger)index
{
	static NSMutableArray *viewControllers;
	if (!viewControllers) viewControllers = [NSMutableArray arrayWithCapacity:2];
	
	if (index >= viewControllers.count) {
		viewControllers[index] = [[PASExtendedNavContainer alloc] initWithIndex:index];
	}
	
	return viewControllers[index];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];

	// Setup navigationBar Items
//	UIBarButtonItem *lbbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
//																		  target:self
//																		  action:@selector(doneButtonTapped:)];
//	self.navigationItem.leftBarButtonItem = lbbi;
	UIBarButtonItem *rbbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																		  target:self
																		  action:@selector(doneButtonTapped:)];
	self.navigationItem.rightBarButtonItem = rbbi;

	// find the hairline below the navigationBar
	if (!self.navHairline) {
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
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self _moveHairline:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[self _moveHairline:NO];
}

- (void)_moveHairline:(BOOL)appearing
{
	// move the hairline below the segmentBar
	CGRect hairlineFrame = self.navHairline.frame;
	if (appearing) {
		hairlineFrame.origin.y += kPASSegmentBarHeight;
	} else {
		hairlineFrame.origin.y -= kPASSegmentBarHeight;
	}
	self.navHairline.frame = hairlineFrame;
}

#pragma mark - Navigation

- (IBAction)doneButtonTapped:(UIBarButtonItem *)sender
{
	BOOL didEditArtists = [((PASExtendedNavContainer*) self.selectedViewController).addTvc didEditArtists];
	[[NSNotificationCenter defaultCenter] postNotificationName:kPASDidEditFavArtists
														object:self
													  userInfo:@{ kPASDidEditFavArtists : [NSNumber numberWithBool:didEditArtists] }];
	// Go back to the previous view
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
