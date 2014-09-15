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
	return 0.4;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController* toVc = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromVc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

	// add the new view to the container
    [[transitionContext containerView] addSubview:toVc.view];
	
	// get final properties
	CGRect finalToFrame = [transitionContext finalFrameForViewController:toVc];
	CGRect finalFromFrame = [transitionContext finalFrameForViewController:fromVc];

	// The initial location of the incoming view is to the left/right the screen
	//initialFrame.origin.x += initialFrame.size.width;
	//initialFrame.origin.x -= initialFrame.size.width;
	
	// set starting properties
	toVc.view.frame = [transitionContext initialFrameForViewController:toVc];
	fromVc.view.frame = [transitionContext initialFrameForViewController:fromVc];
	
	// perform the swap
	[UIView animateWithDuration:[self transitionDuration:transitionContext]
						  delay:0 options:UIViewAnimationOptionCurveEaseInOut
					 animations:^{
						 // set target properties
						 toVc.view.frame = finalToFrame;
						 fromVc.view.frame = finalFromFrame;
					 }
					 completion:^(BOOL finished) {
						 [transitionContext completeTransition:finished];
					 }];
}

- (void)animationEnded:(BOOL)transitionCompleted
{
	
}

@end
