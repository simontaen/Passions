//
//  PASInteractiveTransition.m
//  Passions
//
//  Created by Simon Tännler on 20/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASInteractiveTransition.h"

@interface PASInteractiveTransition () <PASPageViewControllerDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, weak) PASPageViewController *pageViewController;
@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, assign) BOOL leftToRight;
@end

@implementation PASInteractiveTransition

#pragma mark - PASPageViewControllerDelegate

- (id<UIViewControllerInteractiveTransitioning>)pageViewController:(PASPageViewController *)pageViewController
			  interactionControllerForTransitionFromViewController:(UIViewController *)fromViewController
												  toViewController:(UIViewController *)toViewController
{
	return self;
}

- (void)pageViewController:(PASPageViewController *)pageViewController setupInteractionControllerForTransitionFromViewController:(UIViewController *)fromViewController
		  toViewController:(UIViewController *)toViewController
{
	if (!self.panRecognizer) {
		// cache the PVC for later reference
		self.pageViewController = pageViewController;
		
		// setup gesture recognizers
		self.panRecognizer = [[UIPanGestureRecognizer alloc]
							  initWithTarget:self
							  action:@selector(pan:)];
		//panRecognizer.delegate = self;
		[pageViewController addGestureRecognizerToContainerView:self.panRecognizer];
	}
}

#pragma mark - UIViewControllerInteractiveTransitioning

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
	[super startInteractiveTransition:transitionContext];
	
	self.leftToRight = [self.panRecognizer velocityInView:self.panRecognizer.view].x > 0;
}

#pragma mark - UIPanGestureRecognizer

- (void)pan:(UIPanGestureRecognizer *)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		self.leftToRight = [recognizer velocityInView:recognizer.view].x > 0;
		int selectedVcIdx = self.pageViewController.selectedViewControllerIndex;
		
		if (!self.leftToRight && selectedVcIdx != self.pageViewController.viewControllers.count - 1) {
			// transition right
			self.pageViewController.selectedViewControllerIndex = ++selectedVcIdx;
		} else if (self.leftToRight && selectedVcIdx > 0) {
			// transition left
			self.pageViewController.selectedViewControllerIndex = --selectedVcIdx;
		}
		
	} else if (recognizer.state == UIGestureRecognizerStateChanged) {
		CGPoint translation = [recognizer translationInView:recognizer.view];
		CGFloat d = translation.x / CGRectGetWidth(recognizer.view.bounds);
		if (!self.leftToRight) d *= -1;
		[self updateInteractiveTransition:d*0.5];
		
	} else if (recognizer.state >= UIGestureRecognizerStateEnded) {
		if (self.percentComplete > 0.08) {
			[self finishInteractiveTransition];
		} else {
			[self cancelInteractiveTransition];
		}
	}
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	// TODO: The recognition can probably be improved regarding the delete gesture on the TableViewCell
	BOOL result = NO;
	if (([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) && [otherGestureRecognizer.view isDescendantOfView:gestureRecognizer.view]) {
		result = YES;
	}
	return result;
}

@end
