//
//  PASExtendedNavContainer.m
//  Passions
//
//  Created by Simon Tännler on 12/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASExtendedNavContainer.h"
#import "PASAddFromMusicTVC.h"
#import "PASAddFromSpotifyTVC.h"
#import "UIColor+Utils.h"
#import "PASMediaQueryAccessor.h"

CGFloat const kPASSegmentBarHeight = 44; // UIToolbar height

@interface PASExtendedNavContainer ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIToolbar *segmentBar;
@end

@implementation PASExtendedNavContainer

#pragma mark - Init

- (instancetype)initWithIndex:(NSUInteger)index
{
	self = [super initWithNibName:nil bundle:nil];
	if (!self) return nil;
	_addTvc = [self _viewControllerAtIndex:index];
	return self;
}

- (PASAddFromSamplesTVC *)_viewControllerAtIndex:(NSUInteger)index
{
	self.index = index;
	PASAddFromSamplesTVC *result;
	BOOL isSimulator = [[UIDevice currentDevice].model containsString:@"Simulator"];
	
	if (![PASMediaQueryAccessor sharedMngr].usesMusicApp || isSimulator) {
		switch (index) {
			case 0:
				result = [[PASAddFromSpotifyTVC alloc] initWithNibName:nil bundle:nil];
				break;
			case 1:
				result = [[PASAddFromMusicTVC alloc] initWithNibName:nil bundle:nil];
				break;
			default:
				result = [[PASAddFromSamplesTVC alloc] initWithNibName:nil bundle:nil];
		}
	} else {
		switch (index) {
			case 0:
				result = [[PASAddFromMusicTVC alloc] initWithNibName:nil bundle:nil];
				break;
			case 1:
				result = [[PASAddFromSpotifyTVC alloc] initWithNibName:nil bundle:nil];
				break;
			default:
				result = [[PASAddFromSamplesTVC alloc] initWithNibName:nil bundle:nil];
		}
	}
	
	if (index == 0) {
		// prepare caches for the first adding TVC
		[result prepareCaches];
	}
	return result;
}

#pragma mark - Accessors

- (NSString *)title
{
	// this is a container, forwared the call
	return self.addTvc.title;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.segmentBar.barTintColor = [UIColor defaultNavBarTintColor];
	self.segmentBar.clipsToBounds = YES;
	self.segmentBar.tintColor = [self.addTvc chosenTintColor];
	
	// Setup segmentedControl
	self.segmentedControl.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
	self.segmentedControl.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
	[self.segmentedControl addTarget:self.addTvc action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
	for (NSUInteger i = 0; i < [self.segmentedControl numberOfSegments]; i++) {
		[self.segmentedControl setTitle:[self.addTvc sortOrderDescription:[self.addTvc sortOrderForIndex:(NSInteger)i]] forSegmentAtIndex:i];
	}
	
	[self addChildViewController:self.addTvc];
	// add the child view controller
	[self.addTvc.tableView setTranslatesAutoresizingMaskIntoConstraints:YES];
	self.addTvc.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.addTvc.tableView.frame = self.containerView.bounds;
	
	[self.containerView addSubview:self.addTvc.view];
	
	[self.addTvc didMoveToParentViewController:self];
	
	// kick off the caches for the NEXT vc
	if (self.index != self.pageViewController.viewControllers.count - 1) {
		PASExtendedNavContainer *vc = (PASExtendedNavContainer *)self.pageViewController.viewControllers[self.index + 1];
		[vc.addTvc prepareCaches];
	}
}

#pragma mark - PASPageViewControllerChildDelegate

- (UIColor *)PAS_currentPageIndicatorTintColor
{
	return [self.addTvc chosenTintColor];
}

@end

#pragma mark - PASExtendedNavContainerAdditions

@implementation UIViewController (PASExtendedNavContainerAdditions)
- (PASExtendedNavContainer *)extendedNavController
{
	UIViewController *parent = [self parentViewController];
	while(parent) {
		if([parent isKindOfClass:[PASExtendedNavContainer class]]) {
			return (PASExtendedNavContainer *)parent;
		}
		parent = [parent parentViewController];
	}
	return nil;
}
@end

