//
//  PASPageViewController.m
//  Passions
//
//  Created by Simon Tännler on 11/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//
//  http://stablekernel.com/blog/view-controller-containers-part-ii/
//  http://www.objc.io/issue-12/custom-container-view-controller-transitions.html
//  http://www.iosnomad.com/blog/2014/5/12/interactive-custom-container-view-controller-transitions

#import "PASPageViewController.h"

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

#pragma mark - PASTransitionAnimator

/// Instances of this private class perform the default transition animation which is to slide child views horizontally.
@interface PASTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>
@end

#pragma mark - PASPageViewController

@interface PASPageViewController () <UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic, readwrite) UIViewController *selectedViewController;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControlView;
@end

@implementation PASPageViewController
@dynamic selectedViewControllerIndex;

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// setup gesture recognizers
	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]
											 initWithTarget:self
											 action:@selector(pan:)];
	//panRecognizer.delegate = self;
	[self.containerView addGestureRecognizer:panRecognizer];
	
	// update the page control
	self.pageControlView.numberOfPages = self.viewControllers.count;
	
	// add rounded edgeds
	// TODO: maybe add blur using UIVisualEffectView (iOS 8 only)?
	self.pageControlView.backgroundColor = [UIColor lightGrayColor];
	self.pageControlView.opaque = NO;
	self.pageControlView.alpha = 0.8f;
	self.pageControlView.layer.cornerRadius = 7.5;
	self.pageControlView.layer.masksToBounds = YES;
	
	// call the setter to make sure the view is swapped
    self.selectedViewController = (self.selectedViewController ?: [self.viewControllers firstObject]);
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self doSomeCustomLayoutStuff];
}

- (void)doSomeCustomLayoutStuff
{
	CGRect newFrame = self.pageControlView.frame;
	CGFloat heightAdj = (int)(newFrame.size.height * 0.541);
	CGFloat widthAdj = (int)(newFrame.size.width * 0.348);
	
	newFrame.size.width += widthAdj;
	newFrame.size.height -= heightAdj;
	
	newFrame.origin.x -= (widthAdj/2);
	newFrame.origin.y += (heightAdj/2);
	self.pageControlView.frame = newFrame;
}

#pragma mark - Accessors

- (void)setViewControllers:(NSArray *)viewControllers
{
	NSParameterAssert ([viewControllers count] > 0);
	
	// remove the currently selected view controller
	[self.selectedViewController willMoveToParentViewController:nil];
	if([self.selectedViewController isViewLoaded]
	   && self.selectedViewController.view.superview == self.containerView) {
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

- (IBAction)didChangeCurrentPage:(UIPageControl *)sender
{
	if(sender.currentPage != self.selectedViewControllerIndex) {
		self.selectedViewControllerIndex = (int)sender.currentPage;
	}
}

#pragma mark - UIPanGestureRecognizer

- (void)pan:(UIPanGestureRecognizer *)recognizer
{
	if (recognizer.state == UIGestureRecognizerStateBegan) {
		
		BOOL leftToRight = [recognizer velocityInView:recognizer.view].x > 0;
		
		int currentVCIndex = self.selectedViewControllerIndex;
		if (!leftToRight && currentVCIndex != self.viewControllers.count-1) {
			self.selectedViewControllerIndex = ++currentVCIndex;
			
		} else if (leftToRight && currentVCIndex > 0) {
			self.selectedViewControllerIndex = --currentVCIndex;
			
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
	toView.frame = self.containerView.bounds;
	
	[fromVc willMoveToParentViewController:nil];
	[self addChildViewController:toVc];
	
	// If this is the initial presentation, add the new child with no animation.
	if (!fromVc) {
		[self.containerView addSubview:toVc.view];
		[toVc didMoveToParentViewController:self];
		return;
	}
	
	// Animate the transition by calling the animator with our private transition context. If we don't have a delegate, or if it doesn't return an animated transitioning object, we will use our own, private animator.
	
	id<UIViewControllerAnimatedTransitioning> animator = nil;
	if ([self.delegate respondsToSelector:@selector (pageViewController:animationControllerForTransitionFromViewController:toViewController:)]) {
		animator = [self.delegate pageViewController:self animationControllerForTransitionFromViewController:fromVc toViewController:toVc];
	}
	animator = (animator ?: [[PASTransitionAnimator alloc] init]);
	
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
@property (nonatomic, strong) NSDictionary *viewControllers;
@property (nonatomic, assign) CGRect disappearingFromRect;
@property (nonatomic, assign) CGRect appearingFromRect;
@property (nonatomic, assign) CGRect disappearingToRect;
@property (nonatomic, assign) CGRect appearingToRect;
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
		self.viewControllers = @{
								 UITransitionContextFromViewControllerKey:fromVc,
								 UITransitionContextToViewControllerKey:toVc,
								 };
		
		// Set the view frame properties which make sense in our specialized ContainerViewController context. Views appear from and disappear to the sides, corresponding to where the icon buttons are positioned. So tapping a button to the right of the currently selected, makes the view disappear to the left and the new view appear from the right. The animator object can choose to use this to determine whether the transition should be going left to right, or right to left, for example.
		CGFloat travelDistance = (goingRight ? -self.containerView.bounds.size.width : self.containerView.bounds.size.width);
		self.disappearingFromRect = self.appearingToRect = self.containerView.bounds;
		self.disappearingToRect = CGRectOffset (self.containerView.bounds, travelDistance, 0);
		self.appearingFromRect = CGRectOffset (self.containerView.bounds, -travelDistance, 0);
	}
	
	return self;
}

- (CGRect)initialFrameForViewController:(UIViewController *)viewController
{
	if (viewController == [self viewControllerForKey:UITransitionContextFromViewControllerKey]) {
		return self.disappearingFromRect;
	} else {
		return self.appearingFromRect;
	}
}

- (CGRect)finalFrameForViewController:(UIViewController *)viewController
{
	if (viewController == [self viewControllerForKey:UITransitionContextFromViewControllerKey]) {
		return self.disappearingToRect;
	} else {
		return self.appearingToRect;
	}
}

- (UIViewController *)viewControllerForKey:(NSString *)key
{
	return self.viewControllers[key];
}

- (void)completeTransition:(BOOL)didComplete
{
	if (self.completionBlock) {
		self.completionBlock (didComplete);
	}
}

- (BOOL)transitionWasCancelled
{
	// Our non-interactive transition can't be cancelled (it could be interrupted, though)
	return NO;
}

- (UIView *)viewForKey:(NSString *)key
{
	// no manipulation
	return nil;
}


- (CGAffineTransform)targetTransform
{
	// no transformation
	return CGAffineTransformIdentity;
}

// Supress warnings by implementing empty interaction methods for the remainder of the protocol:

- (void)updateInteractiveTransition:(CGFloat)percentComplete { NSLog(@"updateInteractiveTransition"); }
- (void)finishInteractiveTransition { NSLog(@"finishInteractiveTransition"); }
- (void)cancelInteractiveTransition { NSLog(@"cancelInteractiveTransition"); }

@end

#pragma mark - PASTransitionAnimator

@implementation PASTransitionAnimator

#pragma mark - UIViewControllerAnimatedTransitioning

static CGFloat const kChildViewPadding = 16;
static CGFloat const kDamping = 0.75;
static CGFloat const kInitialSpringVelocity = 0.5;

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
	return 0.7;
}

/// Slide views horizontally, with a bit of space between, while fading out and in.
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
	UIViewController* toVc = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	UIViewController* fromVc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	
	// When sliding the views horizontally in and out, figure out whether we are going left or right.
	BOOL goingRight = ([transitionContext initialFrameForViewController:toVc].origin.x < [transitionContext finalFrameForViewController:toVc].origin.x);
	CGFloat travelDistance = [transitionContext containerView].bounds.size.width + kChildViewPadding;
	CGAffineTransform travel = CGAffineTransformMakeTranslation(goingRight ? travelDistance : -travelDistance, 0);
	
	[[transitionContext containerView] addSubview:toVc.view];
	toVc.view.alpha = 0;
	toVc.view.transform = CGAffineTransformInvert(travel);
	
	[UIView animateWithDuration:[self transitionDuration:transitionContext]
						  delay:0 usingSpringWithDamping:kDamping
		  initialSpringVelocity:kInitialSpringVelocity options:0x00
					 animations:^{
						 fromVc.view.transform = travel;
						 fromVc.view.alpha = 0;
						 toVc.view.transform = CGAffineTransformIdentity;
						 toVc.view.alpha = 1;
					 } completion:^(BOOL finished) {
						 fromVc.view.transform = CGAffineTransformIdentity;
						 [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
					 }];
}

@end
