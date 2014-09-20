//
//  PASInteractiveTransition.m
//  Passions
//
//  Created by Simon Tännler on 20/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASInteractiveTransition.h"

@interface PASInteractiveTransition ()
@property (nonatomic, weak) PASPageViewController *pageViewController;
@end

@implementation PASInteractiveTransition

- (void)pageViewController:(PASPageViewController *)pageViewController setupInteractionControllerForTransitionFromViewController:(UIViewController *)fromViewController
		  toViewController:(UIViewController *)toViewController
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		// cache the PVC for later reference
		self.pageViewController = pageViewController;
		
		// setup gesture recognizers
		UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]
												 initWithTarget:self
												 action:@selector(pan:)];
		//panRecognizer.delegate = self;
		[pageViewController addGestureRecognizerToContainerView:panRecognizer];
	});
}

#pragma mark - UIPanGestureRecognizer

- (void)pan:(UIPanGestureRecognizer *)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		
		BOOL leftToRight = [recognizer velocityInView:recognizer.view].x > 0;
		
		int currentVCIndex = self.pageViewController.selectedViewControllerIndex;
		if (!leftToRight && currentVCIndex != self.pageViewController.viewControllers.count-1) {
			self.pageViewController.selectedViewControllerIndex = ++currentVCIndex;
			
		} else if (leftToRight && currentVCIndex > 0) {
			self.pageViewController.selectedViewControllerIndex = --currentVCIndex;
			
		}
	}
	NSLog(@"%d", recognizer.state);
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
