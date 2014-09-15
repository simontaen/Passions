//
//  PASPageViewController.m
//  Passions
//
//  Created by Simon Tännler on 11/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//
//  http://stablekernel.com/blog/view-controller-containers-part-ii/
//  http://www.objc.io/issue-12/custom-container-view-controller-transitions.html

#import "PASPageViewController.h"
#import "PASPVCAnimator.h"

@interface PASPageViewController () <UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate>
// TODO: rename to containerView
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
    self.selectedViewController = (self.selectedViewController ?: [self.viewControllers firstObject]);
}

#pragma mark - Accessors

- (void)setViewControllers:(NSArray *)viewControllers
{
	NSParameterAssert ([viewControllers count] > 0);
	
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
		// TODO: maybe this is done by the context
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
	NSParameterAssert (newVc);
	NSAssert([self.viewControllers containsObject:newVc], @"Only known View Controllers are allowed to be selected");
	
	[self _transitionToChildViewController:newVc];
	
    _selectedViewController = newVc;
	
	// TODO: can this be done in the _transitionToChildViewController
	self.pageControlView.currentPage = self.selectedViewControllerIndex;
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

#pragma mark - Private Methods

- (void)_transitionToChildViewController:(UIViewController *)toVc
{
	// TODO: how did childViewControllers get filled?
	UIViewController *fromVc = ([self.childViewControllers count] > 0 ? self.childViewControllers[0] : nil);
	if (toVc == fromVc || ![self isViewLoaded]) {
		return;
	}
	
	UIView *toView = toVc.view;
	[toView setTranslatesAutoresizingMaskIntoConstraints:YES];
	toView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	toView.frame = self.transitionView.bounds;
	
	[fromVc willMoveToParentViewController:nil];
	[self addChildViewController:toVc];
	[self.transitionView addSubview:toView];
	[fromVc.view removeFromSuperview];
	[fromVc removeFromParentViewController];
	[toVc didMoveToParentViewController:self];
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
