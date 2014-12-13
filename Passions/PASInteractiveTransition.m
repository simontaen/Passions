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
		self.panRecognizer.delegate = self;
		self.panRecognizer.delaysTouchesBegan = YES; // set to YES so we don't always see the selected TVC
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
		NSUInteger selectedVcIdx = self.pageViewController.selectedViewControllerIndex;
		
		if (!self.leftToRight && selectedVcIdx != self.pageViewController.viewControllers.count - 1) {
			// transition right
			[self.pageViewController transitionToViewControllerAtIndex:++selectedVcIdx interactive:YES];
		} else if (self.leftToRight && selectedVcIdx > 0) {
			// transition left
			[self.pageViewController transitionToViewControllerAtIndex:--selectedVcIdx interactive:YES];
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	BOOL result = NO;
	//DDLogVerbose(@"%@ on %@", NSStringFromClass([otherGestureRecognizer class]), NSStringFromClass([otherGestureRecognizer.view class]));
	if (gestureRecognizer == self.panRecognizer &&
		[otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && // handles scrolling (one for horizontal and one for vertical)
		![otherGestureRecognizer.view isKindOfClass:[UITableView class]] && // handles vertical scrolling
		[NSStringFromClass([otherGestureRecognizer.view class]) containsString:@"rapper"] && // horizontal pan in cell
		![otherGestureRecognizer.view isKindOfClass:[UICollectionView class]] // don't interfere when on Timeline
		) {
		result = YES;
	}
	//DDLogVerbose(@"%hhd", result);
	return result;
}

@end
