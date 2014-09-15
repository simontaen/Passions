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

#pragma mark - PASPrivateTransitionContext

/** A private UIViewControllerContextTransitioning class to be provided transitioning delegates.
 @discussion Because we are a custom UIVievController class, with our own containment implementation, we have to provide an object conforming to the UIViewControllerContextTransitioning protocol. The system view controllers use one provided by the framework, which we cannot configure, let alone create. This class will be used even if the developer provides their own transitioning objects.
 @note The only methods that will be called on objects of this class are the ones defined in the UIViewControllerContextTransitioning protocol. The rest is our own private implementation.
 */
@interface PASPrivateTransitionContext : NSObject <UIViewControllerContextTransitioning>
/// Designated initializer.
- (instancetype)initWithFromViewController:(UIViewController *)fromVc
						  toViewController:(UIViewController *)toVc
								goingRight:(BOOL)goingRight;
/// A block of code we can set to execute after having received the completeTransition: message.
@property (nonatomic, copy) void (^completionBlock)(BOOL didComplete);
/// Private setter for the animated property.
@property (nonatomic, assign, getter=isAnimated) BOOL animated;
/// Private setter for the interactive property.
@property (nonatomic, assign, getter=isInteractive) BOOL interactive;
@end

#pragma mark - PASPageViewController

@interface PASPageViewController () <UIGestureRecognizerDelegate, PASPageViewControllerDelegate>
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
	
	self.delegate = self;
	
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
	
	self.selectedViewController = [viewControllers firstObject];
}

- (int)selectedViewControllerIndex
{
    return (int)[self.viewControllers indexOfObject:self.selectedViewController];
}

- (void)setSelectedViewControllerIndex:(int)selectedViewControllerIndex
{
	// this is the main method for user initiated view controller switching
    if(selectedViewControllerIndex < 0
	   || selectedViewControllerIndex >= self.viewControllers.count
	   || selectedViewControllerIndex == self.selectedViewControllerIndex)
        return;
	
    self.selectedViewController = [self.viewControllers objectAtIndex:selectedViewControllerIndex];
	
	if ([self.delegate respondsToSelector:@selector (pageViewController:didSelectViewController:)]) {
		[self.delegate pageViewController:self didSelectViewController:self.selectedViewController];
	}
}

- (void)setSelectedViewController:(UIViewController *)newVc
{
	NSParameterAssert (newVc);
	NSAssert([self.viewControllers containsObject:newVc], @"Only known View Controllers are allowed to be selected");
	
	[self _transitionToChildViewController:newVc];
	
    _selectedViewController = newVc;
}

#pragma mark - PASPageControlView Target-Action

- (IBAction)didChangeCurrentPage:(PASPageControlView *)sender
{
	if(sender.currentPage != self.selectedViewControllerIndex) {
		self.selectedViewControllerIndex = (int)sender.currentPage;
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

#pragma mark - PASPageViewControllerDelegate

//- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator
//{
//	static PASPVCAnimator *interactionController;
//	static dispatch_once_t onceToken;
//	dispatch_once(&onceToken, ^{
//		interactionController = [PASPVCAnimator new];
//	});
//	//return interactionController;
//	return nil;
//}

- (id <UIViewControllerAnimatedTransitioning>)pageViewController:(PASPageViewController *)pageViewController
			  animationControllerForTransitionFromViewController:(UIViewController *)fromViewController
												toViewController:(UIViewController *)toViewController;
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
	
	// If this is the initial presentation, add the new child with no animation.
	if (!fromVc) {
		[self.transitionView addSubview:toVc.view];
		[toVc didMoveToParentViewController:self];
		return;
	}
	
	// Animate the transition by calling the animator with our private transition context. If we don't have a delegate, or if it doesn't return an animated transitioning object, we will use our own, private animator.
	
	id<UIViewControllerAnimatedTransitioning> animator = nil;
	if ([self.delegate respondsToSelector:@selector (pageViewController:animationControllerForTransitionFromViewController:toViewController:)]) {
		animator = [self.delegate pageViewController:self animationControllerForTransitionFromViewController:fromVc toViewController:toVc];
	}
	animator = (animator ?: [[PASPVCAnimator alloc] init]);
	
	// Because of the nature of our view controller, with horizontally arranged buttons, we instantiate our private transition context with information about whether this is a left-to-right or right-to-left transition. The animator can use this information if it wants.
	NSUInteger fromIndex = [self.viewControllers indexOfObject:fromVc];
	NSUInteger toIndex = [self.viewControllers indexOfObject:toVc];
	PASPrivateTransitionContext *transitionContext = [[PASPrivateTransitionContext alloc] initWithFromViewController:fromVc toViewController:toVc goingRight:toIndex > fromIndex];
	
	transitionContext.animated = YES;
	transitionContext.interactive = NO;
	transitionContext.completionBlock = ^(BOOL didComplete) {
		[fromVc.view removeFromSuperview];
		[fromVc removeFromParentViewController];
		[toVc didMoveToParentViewController:self];
		
		if ([animator respondsToSelector:@selector (animationEnded:)]) {
			[animator animationEnded:didComplete];
		}
		self.pageControlView.currentPage = self.selectedViewControllerIndex + (toIndex - fromIndex);
		self.pageControlView.userInteractionEnabled = YES;
	};
	
	self.pageControlView.userInteractionEnabled = NO; // Prevent user tapping buttons mid-transition, messing up state
	[animator animateTransition:transitionContext];
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


#pragma mark - PASPrivateTransitionContext

@interface PASPrivateTransitionContext ()
@property (nonatomic, strong) NSDictionary *privateViewControllers;
@property (nonatomic, assign) CGRect privateDisappearingFromRect;
@property (nonatomic, assign) CGRect privateAppearingFromRect;
@property (nonatomic, assign) CGRect privateDisappearingToRect;
@property (nonatomic, assign) CGRect privateAppearingToRect;
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, assign) UIModalPresentationStyle presentationStyle;
@end

@implementation PASPrivateTransitionContext

- (instancetype)initWithFromViewController:(UIViewController *)fromVc
						  toViewController:(UIViewController *)toVc
								goingRight:(BOOL)goingRight
{
	NSAssert ([fromVc isViewLoaded] && fromVc.view.superview, @"The fromVc view must reside in the container view upon initializing the transition context.");
	
	if ((self = [super init])) {
		self.presentationStyle = UIModalPresentationCustom;
		self.containerView = fromVc.view.superview;
		self.privateViewControllers = @{
										UITransitionContextFromViewControllerKey:fromVc,
										UITransitionContextToViewControllerKey:toVc,
										};
		
		// Set the view frame properties which make sense in our specialized ContainerViewController context. Views appear from and disappear to the sides, corresponding to where the icon buttons are positioned. So tapping a button to the right of the currently selected, makes the view disappear to the left and the new view appear from the right. The animator object can choose to use this to determine whether the transition should be going left to right, or right to left, for example.
		CGFloat travelDistance = (goingRight ? -self.containerView.bounds.size.width : self.containerView.bounds.size.width);
		self.privateDisappearingFromRect = self.privateAppearingToRect = self.containerView.bounds;
		self.privateDisappearingToRect = CGRectOffset (self.containerView.bounds, travelDistance, 0);
		self.privateAppearingFromRect = CGRectOffset (self.containerView.bounds, -travelDistance, 0);
	}
	
	return self;
}

- (CGRect)initialFrameForViewController:(UIViewController *)viewController {
	if (viewController == [self viewControllerForKey:UITransitionContextFromViewControllerKey]) {
		return self.privateDisappearingFromRect;
	} else {
		return self.privateAppearingFromRect;
	}
}

- (CGRect)finalFrameForViewController:(UIViewController *)viewController {
	if (viewController == [self viewControllerForKey:UITransitionContextFromViewControllerKey]) {
		return self.privateDisappearingToRect;
	} else {
		return self.privateAppearingToRect;
	}
}

- (UIViewController *)viewControllerForKey:(NSString *)key {
	return self.privateViewControllers[key];
}

- (void)completeTransition:(BOOL)didComplete {
	if (self.completionBlock) {
		self.completionBlock (didComplete);
	}
}

- (BOOL)transitionWasCancelled { return NO; } // Our non-interactive transition can't be cancelled (it could be interrupted, though)

// Supress warnings by implementing empty interaction methods for the remainder of the protocol:

- (void)updateInteractiveTransition:(CGFloat)percentComplete {}
- (void)finishInteractiveTransition {}
- (void)cancelInteractiveTransition {}

@end
