//
//  PASPVCAnimator.m
//  Passions
//
//  Created by Simon Tännler on 13/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASPVCAnimator.h"

@implementation PASPVCAnimator

#pragma mark - UIViewControllerInteractiveTransitioning

- (void)startInteractiveTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
	NSLog(@"startInteractiveTransition");
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
	return 0.5;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController* toVc = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromVc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

	// add the new view to the container
	[toVc.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [[transitionContext containerView] addSubview:toVc.view];
	
	
	// The final destination of the incoming view is where the controller wants it
	//CGRect destinationFrame = fromVc.view.bounds;
	CGRect destinationFrame = [transitionContext finalFrameForViewController:toVc];

	// The initial location of the incoming view is to the left/right the screen
	CGRect initialFrame = destinationFrame;
	// TODO: pass direction as a property
	//iinitialFrame.origin.x += initialFrame.size.width;
	//initialFrame.origin.x -= initialFrame.size.width;
	initialFrame.origin.y -= destinationFrame.size.height;
	
	// The final destination of the outgoing view is underneath the screen
    CGRect outgoingDestinationFrame = fromVc.view.frame;
    outgoingDestinationFrame.origin.y += outgoingDestinationFrame.size.height;
	
	// set starting properties
	toVc.view.frame = initialFrame;
	
	// perform the swap
	[UIView animateWithDuration:[self transitionDuration:transitionContext]
						  delay:0 options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 // set target properties
						 fromVc.view.frame = outgoingDestinationFrame;
						 toVc.view.frame = destinationFrame;
					 }
					 completion:^(BOOL finished) {
						 [transitionContext completeTransition:finished];
					 }];
}

@end
