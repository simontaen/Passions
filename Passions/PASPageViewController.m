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

@interface PASPageViewController () <UIGestureRecognizerDelegate, PASPageViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *transitionView;
@property (weak, nonatomic, readwrite) UIViewController *selectedViewController;
@property (weak, nonatomic) IBOutlet PASPageControlView *pageControlView;
@end

@implementation PASPageViewController
@dynamic selectedViewControllerIndex;

#pragma mark - Init

- (void)awakeFromNib
{
	self.delegate = self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
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
	// remove existing view controllers
    for(UIViewController *vc in self.viewControllers) {
        [vc willMoveToParentViewController:nil];
        if([vc isViewLoaded]
		   && vc.view.superview == self.transitionView) {
            [vc.view removeFromSuperview];
        }
        [vc removeFromParentViewController];
    }
	
    _viewControllers = viewControllers;
	
    if(self.viewControllers.count > 0) {
		// add passed viewControllers
		for (int i = 0; i < self.viewControllers.count; i++) {
			UIViewController *vc = self.viewControllers[i];
			[self addChildViewController:vc];
			if (i == 0) {
				// set the first one as the currently selected view controller
				self.selectedViewController = vc;
			}
			[vc didMoveToParentViewController:self];
		}
		
    } else {
        self.selectedViewController = nil;
    }
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

- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    if(![self.viewControllers containsObject:selectedViewController]) {
		self.pageControlView.currentPage = 0;
		return;
    }
	
    UIViewController *previous = self.selectedViewController;
	
    _selectedViewController = selectedViewController;
	
    if([self isViewLoaded]) {
		// update the control
		self.pageControlView.currentPage = self.selectedViewControllerIndex;
		
		// switch the views
        [previous.view removeFromSuperview];
		
        UIView *newView = self.selectedViewController.view;
        newView.frame = self.transitionView.bounds;
        [newView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];

        [self.transitionView addSubview:newView];
    }
}

#pragma mark - PASPageControlView Target-Action

- (IBAction)didChangeCurrentPage:(PASPageControlView *)sender
{
	if(sender.currentPage != self.selectedViewControllerIndex) {
		self.selectedViewController = [self.viewControllers objectAtIndex:sender.currentPage];
	}
}

#pragma mark - UIScreenEdgePanGestureRecognizer

- (void)leftEdgePan:(UIScreenEdgePanGestureRecognizer *)gesture {
	if (gesture.state == UIGestureRecognizerStateEnded) {
		self.selectedViewControllerIndex = self.selectedViewControllerIndex++;
	}
	NSLog(@"left edge");
}

- (void)rightEdgePan:(UIScreenEdgePanGestureRecognizer *)gesture
{
	if (gesture.state == UIGestureRecognizerStateEnded) {
		self.selectedViewControllerIndex = self.selectedViewControllerIndex--;
	}
	NSLog(@"right edge");
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return YES;
}

#pragma mark - PASPageViewControllerDelegate

- (id <UIViewControllerInteractiveTransitioning>)pageViewController:(PASPageViewController *)pageViewController
						interactionControllerForAnimationController: (id <UIViewControllerAnimatedTransitioning>)animationController
{
	static id<UIViewControllerInteractiveTransitioning> interactionController;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		interactionController = [[PASPVCAnimator alloc] init];
	});
	return interactionController;
}

- (id <UIViewControllerAnimatedTransitioning>)pageViewController:(PASPageViewController *)pageViewController
			  animationControllerForTransitionFromViewController:(UIViewController *)fromVC
												toViewController:(UIViewController *)toVC
{
	static id<UIViewControllerAnimatedTransitioning> animationController;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		animationController = [[PASPVCAnimator alloc] init];
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
