//
//  PASPageViewController.m
//  Passions
//
//  Created by Simon Tännler on 11/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//
//  http://stablekernel.com/blog/view-controller-containers-part-ii/

#import "PASPageViewController.h"
#import "PASPVCAnimator.h"

@interface PASPageViewController () <UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate>
@property (weak, nonatomic) IBOutlet UIView *transitionView;
@property (weak, nonatomic, readwrite) UIViewController *selectedViewController;
@property (weak, nonatomic) IBOutlet PASPageControlView *pageControlView;
@end

@implementation PASPageViewController
@dynamic selectedViewControllerIndex;

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// DEBUG
	self.transitionView.backgroundColor = [UIColor orangeColor];
	
	// setup gesture recognizers
	UIScreenEdgePanGestureRecognizer *leftEdge = [[UIScreenEdgePanGestureRecognizer alloc]
												  initWithTarget:self
												  action:@selector(leftEdgePan:)];
	leftEdge.edges = UIRectEdgeLeft;
	leftEdge.delegate = self;
	[self.transitionView addGestureRecognizer:leftEdge];
	
	UIScreenEdgePanGestureRecognizer *rightEdge = [[UIScreenEdgePanGestureRecognizer alloc]
												   initWithTarget:self
												   action:@selector(rightEdgePan:)];
	rightEdge.edges = UIRectEdgeRight;
	rightEdge.delegate = self;
	[self.transitionView addGestureRecognizer:rightEdge];
	
	// update the page control
	self.pageControlView.numberOfPages = self.viewControllers.count;
	
	// call the setter to make sure the view is swapped
    self.selectedViewController = self.selectedViewController;
}

#pragma mark - Accessors

- (void)setViewControllers:(NSArray *)viewControllers
{
	// remove the currently selected view controller
	[self.selectedViewController willMoveToParentViewController:nil];
	if([self.selectedViewController isViewLoaded]
	   && self.selectedViewController.view.superview == self.transitionView) {
		[self.selectedViewController.view removeFromSuperview];
	}
	[self.selectedViewController removeFromParentViewController];
	
    _viewControllers = viewControllers;
	
	// configure passed viewControllers
	for (UIViewController *vc in viewControllers) {
		// configure transitioning for custom transitions
		vc.transitioningDelegate = self;
		vc.modalPresentationStyle = UIModalPresentationCustom;
	}
	
	self.selectedViewController = [viewControllers firstObject];
}

- (int)selectedViewControllerIndex
{
    return (int)[self.viewControllers indexOfObject:self.selectedViewController];
}

- (void)setSelectedViewControllerIndex:(int)selectedViewControllerIndex
{
    if(selectedViewControllerIndex < 0
	   || selectedViewControllerIndex >= self.viewControllers.count
	   || selectedViewControllerIndex == self.selectedViewControllerIndex)
        return;
	
    self.selectedViewController = [self.viewControllers objectAtIndex:selectedViewControllerIndex];
}

- (void)setSelectedViewController:(UIViewController *)newVc
{
    if(![self.viewControllers containsObject:newVc]) {
		self.pageControlView.currentPage = 0;
		return;
    }
	
    UIViewController *oldVc = self.selectedViewController;
	
    _selectedViewController = newVc;
	
    if([self isViewLoaded]) {
		if (oldVc != newVc) {
			// update the control
			self.pageControlView.currentPage = self.selectedViewControllerIndex;
			
			[self presentViewController:newVc animated:YES completion:nil];
			
//			// start the transitions
//			[oldVc willMoveToParentViewController:nil];
//			[self addChildViewController:newVc];
//			
//			// set the start location of the newView
//			CGRect targetBounds = self.transitionView.bounds;
//			CGRect startingBounds = targetBounds;
//			
//			if ([self.viewControllers indexOfObject:newVc] > [self.viewControllers indexOfObject:oldVc]) {
//				startingBounds.origin.x += startingBounds.size.width;
//			} else {
//				startingBounds.origin.x -= startingBounds.size.width;
//			}
//			
//			newVc.view.frame = startingBounds;
//			
//			// set the target location
//			[newVc.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
//			//newVc.view.alpha = 0.0; // this is doing a manual cross dissolve
//			
//			// perform the swap
//			[self transitionFromViewController:oldVc
//							  toViewController:newVc
//									  duration:0.5
//									   options:UIViewAnimationOptionCurveEaseInOut
//									animations:^{
//										// perform the transition
//										// animates between the view properties set above
//										// and the ones specified here
//										//oldVc.view.alpha = 0.0;
//										//newVc.view.alpha = 1.0;
//										newVc.view.frame = targetBounds;
//									}
//									completion:^(BOOL finished) {
//										
//										// finish the transition
//										[oldVc removeFromParentViewController];
//										[newVc didMoveToParentViewController:self];
//									}];
			
		} else if (!(newVc.view.superview == self.transitionView)) {
			// add the first view
			[self addChildViewController:newVc];
			newVc.view.frame = self.transitionView.bounds;
			[newVc.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
			[self.transitionView addSubview:newVc.view];
			[newVc didMoveToParentViewController:self];
			
		}
	}
}

#pragma mark - PASPageControlView Target-Action

- (IBAction)didChangeCurrentPage:(PASPageControlView *)sender
{
	// TODO: prevent starting a new transition while one is still going on
	if(sender.currentPage != self.selectedViewControllerIndex) {
		self.selectedViewController = [self.viewControllers objectAtIndex:sender.currentPage];
	}
}

#pragma mark - UIScreenEdgePanGestureRecognizer

- (void)leftEdgePan:(UIScreenEdgePanGestureRecognizer *)gesture
{
	if (gesture.state == UIGestureRecognizerStateEnded) {
		//self.selectedViewControllerIndex = self.selectedViewControllerIndex++;
	}
	NSLog(@"left edge");
}

- (void)rightEdgePan:(UIScreenEdgePanGestureRecognizer *)gesture
{
	if (gesture.state == UIGestureRecognizerStateEnded) {
		//self.selectedViewControllerIndex = self.selectedViewControllerIndex--;
	}
	NSLog(@"right edge");
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return YES;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator
{
	static PASPVCAnimator *interactionController;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		interactionController = [PASPVCAnimator new];
	});
	//return interactionController;
	return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
																  presentingController:(UIViewController *)presenting
																	  sourceController:(UIViewController *)source
{
	static PASPVCAnimator *animationController;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		animationController = [PASPVCAnimator new];
	});
	return animationController;
}
@end

#pragma mark - PASPageViewControllerAdditions

@implementation UIViewController (PASPageViewControllerAdditions)
- (PASPageViewController *)pageViewController
{
    UIViewController *parent = [self parentViewController];
    while(parent) {
        if([parent isKindOfClass:[PASPageViewController class]]) {
            return (PASPageViewController *)parent;
        }
        parent = [parent parentViewController];
    }
    return nil;
}
@end
