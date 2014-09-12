//
//  PASPageViewController.m
//  Passions
//
//  Created by Simon Tännler on 11/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//
//  http://stablekernel.com/blog/view-controller-containers-part-ii/

#import "PASPageViewController.h"

@interface PASPageViewController () <PASPageControlViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *transitionView;
@property (weak, nonatomic) UIViewController *selectedViewController;

@property (strong, nonatomic) IBOutlet UIScreenEdgePanGestureRecognizer *leftEdgeSwipeGestureRecognizer;
@property (strong, nonatomic) IBOutlet UIScreenEdgePanGestureRecognizer *rightEdgeSwipeGestureRecognizer;

@property (weak, nonatomic) IBOutlet PASPageControlView *pageControlView;
@end

@implementation PASPageViewController
@dynamic selectedViewControllerIndex;

#pragma mark - Init

- (void)awakeFromNib
{
	[self.leftEdgeSwipeGestureRecognizer addTarget:self action:@selector(leftEdgeSwipe:)];
	self.leftEdgeSwipeGestureRecognizer.edges = UIRectEdgeLeft;
	
	[self.rightEdgeSwipeGestureRecognizer addTarget:self action:@selector(rightEdgeSwipe:)];
	self.rightEdgeSwipeGestureRecognizer.edges = UIRectEdgeRight;
	
    self.pageControlView.delegate = self;
}

#pragma mark - View Lifecycle

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
	
	// update the page controle
	self.pageControlView.numberOfPages = viewControllers.count;
	
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

#pragma mark - View Hierarchy

- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    if(![self.viewControllers containsObject:selectedViewController]) {
		self.pageControlView.currentPage = 0;
		return;
    }
	
    UIViewController *previous = self.selectedViewController;
	
    _selectedViewController = selectedViewController;
	
    if([self isViewLoaded]) {
		self.pageControlView.currentPage = self.selectedViewControllerIndex;
		
        [previous.view removeFromSuperview];
		
        UIView *newView = self.selectedViewController.view;
        newView.frame = self.transitionView.bounds;
        [newView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
		// TODO: maybe the gesture recoginzers need to be attachted here
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

#pragma mark - UIScreenEdgePanGestureRecognizer

- (void)leftEdgeSwipe:(UIScreenEdgePanGestureRecognizer *)gesture {
	if (gesture.state == UIGestureRecognizerStateEnded) {
		self.selectedViewControllerIndex = self.selectedViewControllerIndex++;
	}
	NSLog(@"left edge %ld", gesture.state);
}

- (void)rightEdgeSwipe:(UIScreenEdgePanGestureRecognizer *)gesture {
	if (gesture.state == UIGestureRecognizerStateEnded) {
		self.selectedViewControllerIndex = self.selectedViewControllerIndex--;
	}
	NSLog(@"right edge %ld", gesture.state);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end

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
