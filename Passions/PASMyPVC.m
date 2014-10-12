//
//  PASMyPVC.m
//  Passions
//
//  Created by Simon Tännler on 12/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASMyPVC.h"
#import "PASExtendedNavContainer.h"

@interface PASMyPVC ()
@end

@implementation PASMyPVC

#pragma mark - Accessors

- (void)setFavArtists:(NSMutableArray *)favArtists
{
//	for (PASExtendedNavContainer *vc in self.viewControllers) {
//		vc.favArtists = favArtists;
//	}
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

#pragma mark - Navigation

- (IBAction)doneButtonHandler:(UIBarButtonItem *)sender
{
	//PASExtendedNavContainer *dissapearingTVC = ((PASExtendedNavContainer*) self.selectedViewController);
	if ([self.myDelegate respondsToSelector:@selector(viewController:didEditArtists:)]) {
//		[self.myDelegate viewController:dissapearingTVC didEditArtists:[dissapearingTVC didEditArtists]];
	} else {
		[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
	}
}

@end
