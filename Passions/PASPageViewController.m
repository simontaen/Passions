//
//  PASPageViewController.m
//  Passions
//
//  Created by Simon Tännler on 11/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//
//  http://stablekernel.com/blog/view-controller-containers-part-ii/

#import "PASPageViewController.h"

@interface PASPageViewController () <PASPageControlViewDelegate, PASPageControlViewDataSource>
@property (nonatomic, weak) UIView *transitionView;
@property (nonatomic, weak) UIViewController *selectedViewController;

@property (nonatomic, strong, readwrite) UIScreenEdgePanGestureRecognizer *leftEdgeSwipeGestureRecognizer;
@property (nonatomic, strong, readwrite) UIScreenEdgePanGestureRecognizer *rightEdgeSwipeGestureRecognizer;
@property (nonatomic, weak, readwrite) PASPageControlView *pageControlView;
@end

@implementation PASPageViewController

#pragma mark - View Lifecycle

- (void)loadView
{
    UIView *layoutView = [[UIView alloc] init];
	
	self.leftEdgeSwipeGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(leftEdgeSwipe:)];
	self.leftEdgeSwipeGestureRecognizer.edges = UIRectEdgeLeft;
	[layoutView addGestureRecognizer:self.leftEdgeSwipeGestureRecognizer];
	
	self.rightEdgeSwipeGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(rightEdgeSwipe:)];
	self.rightEdgeSwipeGestureRecognizer.edges = UIRectEdgeRight;
	[layoutView addGestureRecognizer:self.rightEdgeSwipeGestureRecognizer];
	
	// TODO: this might better be a scroll view!
    UIView *transitionView = [[UIView alloc] initWithFrame:layoutView.bounds];
    [transitionView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [layoutView addSubview:transitionView];
	
	// TODO: position the pageControlView correctly
    PASPageControlView *pageControlView = [[PASPageControlView alloc] initWithFrame:layoutView.bounds];
    [pageControlView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [pageControlView setDelegate:self];
    [layoutView addSubview:pageControlView];
	
    self.view = layoutView;
    self.transitionView = transitionView;
    self.pageControlView = pageControlView;
	
	// TODO: the the page control view to visible
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
	
    for(UIViewController *vc in self.viewControllers) {
        [self addChildViewController:vc];
        [vc didMoveToParentViewController:self];
    }
	
    if([self.viewControllers count] > 0) {
        self.selectedViewController = [self.viewControllers objectAtIndex:0];
    } else {
        self.selectedViewController = nil;
    }
}

@dynamic selectedViewControllerIndex;

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

#pragma mark - View Hierarchy

- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    if(![self.viewControllers containsObject:selectedViewController]) {
        return;
    }
	
    UIViewController *previous = self.selectedViewController;
	
    _selectedViewController = selectedViewController;
	
    if([self isViewLoaded]) {
        [previous.view removeFromSuperview];
		
        UIView *newView = self.selectedViewController.view;
        newView.frame = self.transitionView.bounds;
        [newView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [self.transitionView addSubview:newView];
    }
}

#pragma mark - PASPageControlViewDelegate

- (void)pageControlView:(PASPageControlView *)pageControlView didMoveToIndex:(int)index
{
	if(index != self.selectedViewControllerIndex) {
		self.selectedViewController = [self.viewControllers objectAtIndex:index];
	}
}


#pragma mark - PASPageControlViewDataSource

- (NSInteger)presentationCountForPageControlView:(PASPageControlView *)pageControlView
{
	return self.viewControllers.count;
}

- (NSInteger)presentationIndexForPageControlView:(PASPageControlView *)pageControlView
{
	return 0;
}

#pragma mark - UIScreenEdgePanGestureRecognizer

- (void)leftEdgeSwipe:(UIScreenEdgePanGestureRecognizer *)gesture {
	if (gesture.state == UIGestureRecognizerStateEnded) {
		self.selectedViewControllerIndex = self.selectedViewControllerIndex++;
	}
}

- (void)rightEdgeSwipe:(UIScreenEdgePanGestureRecognizer *)gesture {
	if (gesture.state == UIGestureRecognizerStateEnded) {
		self.selectedViewControllerIndex = self.selectedViewControllerIndex--;
	}
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
