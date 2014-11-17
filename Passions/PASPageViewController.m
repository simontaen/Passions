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
#import "PASInteractiveTransition.h"

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
/// Private setter for the transition cacelled property.
@property (nonatomic, assign) BOOL transitionWasCancelled;
@end

#pragma mark - PASTransitionAnimator

/// Instances of this private class perform the default transition animation which is to slide child views horizontally.
@interface PASTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>
@end

#pragma mark - PASPageViewController

@interface PASPageViewController ()
@property (nonatomic, assign, readwrite) int selectedViewControllerIndex;
@property (nonatomic, weak, readwrite) UIViewController *selectedViewController;
@property (nonatomic, assign) BOOL interactive;

@property (strong, nonatomic) IBOutlet UIVisualEffectView *blurView;
@property (nonatomic, weak) IBOutlet UIPageControl *pageControlView;
@property (nonatomic, strong) PASInteractiveTransition *bla;

@property (nonatomic, strong) NSMutableArray *containerViewRecognizers;
@end

@implementation PASPageViewController
@dynamic selectedViewControllerIndex;

#pragma mark - Init

- (void)awakeFromNib
{
	// TODO: temporary
	self.bla = [PASInteractiveTransition new];
	self.delegate = (id<PASPageViewControllerDelegate>)self.bla;
	self.containerViewRecognizers = [NSMutableArray array];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// hook up the page control
	[self.pageControlView addTarget:self action:@selector(didChangeCurrentPage:) forControlEvents:UIControlEventValueChanged];
	
	// update the page control
	self.pageControlView.numberOfPages = self.viewControllers.count;
	self.pageControlView.backgroundColor = [UIColor clearColor];
	self.pageControlView.currentPageIndicatorTintColor = [UIColor whiteColor];
	self.pageControlView.pageIndicatorTintColor = [UIColor lightGrayColor];
	
	// add rounded edgeds
	//self.pageControlView.opaque = YES;
	//self.pageControlView.alpha = 0.8f;
	self.blurView.layer.cornerRadius = 7.5;
	self.blurView.layer.masksToBounds = YES;
	
	// resize to fit number of pages
	NSLayoutConstraint *cn = [NSLayoutConstraint constraintWithItem:self.blurView
														  attribute:NSLayoutAttributeWidth
														  relatedBy:NSLayoutRelationEqual
															 toItem:nil
														  attribute:NSLayoutAttributeNotAnAttribute
														 multiplier:1
														   constant:([self.pageControlView sizeForNumberOfPages:self.viewControllers.count].width + 16)];
	[self.blurView addConstraint:cn];
	
	
	[self _setupDelegateForTransitionsBetweenViewControllers:self.viewControllers];
	
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
	   && self.selectedViewController.view.superview == self.containerView) {
		[self.selectedViewController.view removeFromSuperview];
	}
	[self.selectedViewController removeFromParentViewController];
	
	if ([self isViewLoaded]) {
		[self _setupDelegateForTransitionsBetweenViewControllers:viewControllers];
	}
	
	_viewControllers = viewControllers;
	
	self.selectedViewController = [_viewControllers firstObject];
}

- (void)_setupDelegateForTransitionsBetweenViewControllers:(NSArray *)viewControllers
{
	BOOL delegateConforms = [self.delegate respondsToSelector:@selector(pageViewController:setupInteractionControllerForTransitionFromViewController:toViewController:)];
	NSUInteger nrOfVcs = viewControllers.count;
	
	if (delegateConforms && nrOfVcs > 1) {
		for (int i = 0; i < nrOfVcs; i++) {
			UIViewController *thisVc = viewControllers[i];
			UIViewController *nextVc;
			UIViewController *previousVc;
			
			if (i == 0) {
				// first item
				nextVc = viewControllers[i + 1];
			} else if (i == nrOfVcs - 1) {
				// last item
				previousVc = viewControllers[i - 1];
			} else {
				nextVc = viewControllers[i + 1];
				previousVc = viewControllers[i - 1];
			}
			
			if (previousVc) {
				[self.delegate pageViewController:self setupInteractionControllerForTransitionFromViewController:previousVc
								 toViewController:thisVc];
			}
			if (nextVc) {
				[self.delegate pageViewController:self setupInteractionControllerForTransitionFromViewController:thisVc
								 toViewController:nextVc];
			}
		}
	}
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
	
	[self _transitionToChildViewController:newVc completion:^(BOOL didTransition) {
		if (didTransition) {
//			for (UIGestureRecognizer *gr in _selectedViewController.view.gestureRecognizers) {
//				[self removeGestureRecognizerFromContainerView:gr];
//			}
			_selectedViewController = newVc;
			self.title = newVc.title;
			[self setNeedsStatusBarAppearanceUpdate];
//			for (UIGestureRecognizer *gr in newVc.view.gestureRecognizers) {
//				[self addGestureRecognizerToContainerView:gr];
//			}
			if ([newVc conformsToProtocol:@protocol(PASPageViewControllerChildDelegate)]) {
				id<PASPageViewControllerChildDelegate> childDelegate = (id<PASPageViewControllerChildDelegate>)newVc;
				if ([newVc respondsToSelector:@selector(PAS_currentPageIndicatorTintColor)]) {
					self.pageControlView.currentPageIndicatorTintColor = [childDelegate PAS_currentPageIndicatorTintColor];
				}
				if ([newVc respondsToSelector:@selector(PAS_leftBarButtonItem)]) {
					self.navigationItem.leftBarButtonItem = [childDelegate PAS_leftBarButtonItem];
				}
			}
			self.pageControlView.currentPage = self.selectedViewControllerIndex;
		}
	}];
}

- (void)setPageControlHidden:(BOOL)pageControlHidden
{
	if (_pageControlHidden != pageControlHidden) {
		_pageControlHidden = pageControlHidden;
		
		self.blurView.hidden = pageControlHidden;
		
		if (pageControlHidden) {
			for (UIGestureRecognizer *recognizer in self.containerViewRecognizers) {
				[self.containerView removeGestureRecognizer:recognizer];
			}
		} else {
			for (UIGestureRecognizer *recognizer in self.containerViewRecognizers) {
				[self.containerView addGestureRecognizer:recognizer];
			}
		}
	}
}

#pragma mark - Public Methods

- (void)transitionToViewControllerAtIndex:(int)index interactive:(BOOL)interactive
{
	self.interactive = interactive;
	self.selectedViewControllerIndex = index;
}

#pragma mark - PASPageControlView Target-Action

- (IBAction)didChangeCurrentPage:(UIPageControl *)sender
{
	if(sender.currentPage != self.selectedViewControllerIndex) {
		[self transitionToViewControllerAtIndex:(int)sender.currentPage interactive:NO];
	}
}

#pragma mark - Gesture Recogizers

- (void)addGestureRecognizerToContainerView:(UIGestureRecognizer *)recognizer
{
	[self.containerViewRecognizers addObject:recognizer];
	[self.containerView addGestureRecognizer:recognizer];
}

- (void)removeGestureRecognizerFromContainerView:(UIGestureRecognizer *)recognizer
{
	[self.containerView removeGestureRecognizer:recognizer];
	[self.containerViewRecognizers removeObject:recognizer];
}

#pragma mark - UIViewController

- (BOOL)prefersStatusBarHidden
{
	return [self.selectedViewController prefersStatusBarHidden];
}

#pragma mark - Private Methods

- (void)_transitionToChildViewController:(UIViewController *)toVc completion:(void (^)(BOOL didTransition))completion
{
	UIViewController *fromVc = ([self.childViewControllers count] > 0 ? self.childViewControllers[0] : nil);
	if (toVc == fromVc || ![self isViewLoaded]) {
		return;
	}
	
	// prepare the view
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
		completion(YES);
		return;
	}
	
	// Animate the transition by calling the animator with our private transition context.
	// If we don't have a delegate, or if it doesn't return an animated transitioning object, we will use our own, private animator.
	
	id<UIViewControllerAnimatedTransitioning> animator = nil;
	if ([self.delegate respondsToSelector:@selector (pageViewController:animationControllerForTransitionFromViewController:toViewController:)]) {
		animator = [self.delegate pageViewController:self animationControllerForTransitionFromViewController:fromVc toViewController:toVc];
	}
	// if no animator is provided, the Apple way is to not as for an interactiveTransitionDelegate
	animator = (animator ?: [PASTransitionAnimator new]);
	
	id<UIViewControllerInteractiveTransitioning> interactiveTransitionDelegate = nil;
	if ([self.delegate respondsToSelector:@selector (pageViewController:interactionControllerForTransitionFromViewController:toViewController:)]) {
		interactiveTransitionDelegate = [self.delegate pageViewController:self interactionControllerForTransitionFromViewController:fromVc toViewController:toVc];
	}
	interactiveTransitionDelegate = (interactiveTransitionDelegate ?: [PASInteractiveTransition new]);
	if ([interactiveTransitionDelegate respondsToSelector:@selector (setAnimator:)]) {
		// AWPercentDrivenInteractiveTransition
		[interactiveTransitionDelegate performSelector:@selector(setAnimator:) withObject:animator];
	}
	
	// Because of the nature of our view controller, with horizontally arranged buttons, we instantiate our private transition context with information about whether this is a left-to-right or right-to-left transition. The animator can use this information if it wants.
	NSUInteger fromIndex = [self.viewControllers indexOfObject:fromVc];
	NSUInteger toIndex = [self.viewControllers indexOfObject:toVc];
	PASPrivateTransitionContext *transitionContext = [[PASPrivateTransitionContext alloc] initWithFromViewController:fromVc toViewController:toVc goingRight:toIndex > fromIndex];
	
	transitionContext.animated = YES;
	transitionContext.interactive = self.interactive && interactiveTransitionDelegate != nil;
	transitionContext.completionBlock = ^(BOOL didComplete) {
		if (didComplete) {
			[fromVc.view removeFromSuperview];
			[fromVc removeFromParentViewController];
			[toVc didMoveToParentViewController:self];
			
		} else {
			[toVc.view removeFromSuperview];
		}
		completion(didComplete);
		
		if ([animator respondsToSelector:@selector(animationEnded:)]) {
			[animator animationEnded:didComplete];
		}
		self.pageControlView.userInteractionEnabled = YES;
	};
	
	self.pageControlView.userInteractionEnabled = NO; // Prevent user tapping buttons mid-transition, messing up state
	if (transitionContext.interactive) {
		[interactiveTransitionDelegate startInteractiveTransition:transitionContext];
	} else {
		[animator animateTransition:transitionContext];
	}
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

- (void)finishInteractiveTransition
{
	self.transitionWasCancelled = NO;
}

- (void)cancelInteractiveTransition
{
	self.transitionWasCancelled = YES;
}

// Supress warnings by implementing empty interaction methods for the remainder of the protocol:
- (void)updateInteractiveTransition:(CGFloat)percentComplete {}

@end

#pragma mark - PASTransitionAnimator

@implementation PASTransitionAnimator

#pragma mark - UIViewControllerAnimatedTransitioning

static CGFloat const kPASChildViewPadding = 0;
static CGFloat const kPASDamping = 0.75;
static CGFloat const kPASInitialSpringVelocity = 0.5;

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
	CGFloat travelDistance = [transitionContext containerView].bounds.size.width + kPASChildViewPadding;
	CGAffineTransform travel = CGAffineTransformMakeTranslation(goingRight ? travelDistance : -travelDistance, 0);
	
	// WWDC2013 - 218 - Insertion of "to" view controller's view into the container view
	[[transitionContext containerView] addSubview:toVc.view];
	toVc.view.alpha = 0;
	toVc.view.transform = CGAffineTransformInvert(travel);
	
	[UIView animateWithDuration:[self transitionDuration:transitionContext]
						  delay:0 usingSpringWithDamping:kPASDamping
		  initialSpringVelocity:kPASInitialSpringVelocity options:0x00
					 animations:^{
						 fromVc.view.transform = travel;
						 fromVc.view.alpha = 0;
						 toVc.view.transform = CGAffineTransformIdentity;
						 toVc.view.alpha = 1;
					 } completion:^(BOOL finished) {
						 // make sure you reset the fromVc view in case we got cancelled
						 fromVc.view.transform = CGAffineTransformIdentity;
						 fromVc.view.alpha = 1;
						 [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
					 }];
}

@end
