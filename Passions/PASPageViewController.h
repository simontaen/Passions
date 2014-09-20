//
//  PASPageViewController.h
//  Passions
//
//  Created by Simon Tännler on 11/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

@import UIKit;

@protocol PASPageViewControllerDelegate;

@interface PASPageViewController : UIViewController

/// The container view controller delegate receiving the protocol callbacks.
@property (nonatomic, weak) id<PASPageViewControllerDelegate>delegate;

/// setting this will move the page!
@property (nonatomic, assign) int selectedViewControllerIndex;
/// the currently displaying view controller
@property (nonatomic, weak, readonly) UIViewController *selectedViewController;
/// all the view controllers this container displays
@property (nonatomic, strong) NSArray *viewControllers;

/// let the delegate assign gesture recogizers for an interactive transition
- (void)addGestureRecognizerToContainerView:(UIGestureRecognizer *)recognizer;
/// let the delegate remove gesture recogizers for an interactive transition
- (void)removeGestureRecognizerFromContainerView:(UIGestureRecognizer *)recognizer;

@end

@protocol PASPageViewControllerDelegate <NSObject>
// this is very similar to UIViewControllerTransitioningDelegate
@optional
/** Informs the delegate that the user selected view controller by tapping the corresponding icon.
 @note The method is called regardless of whether the selected view controller changed or not and only as a result of the user tapped a button. The method is not called when the view controller is changed programmatically. This is the same pattern as UITabBarController uses.
 */
- (void)pageViewController:(PASPageViewController *)pageViewController
   didSelectViewController:(UIViewController *)viewController;

/// Called on the delegate to obtain a UIViewControllerAnimatedTransitioning object which can be used to animate a non-interactive transition.
- (id <UIViewControllerAnimatedTransitioning>)pageViewController:(PASPageViewController *)pageViewController
			  animationControllerForTransitionFromViewController:(UIViewController *)fromViewController
												toViewController:(UIViewController *)toViewController;

/// this is called shortly before the transtition, when returned nil, the interaction will not be interactive
- (id <UIViewControllerInteractiveTransitioning>)pageViewController:(PASPageViewController *)pageViewController
			   interactionControllerForTransitionFromViewController:(UIViewController *)fromViewController
												   toViewController:(UIViewController *)toViewController;

/// This gives the delegate a chance to configure the interaction controller(s)
- (void)pageViewController:(PASPageViewController *)pageViewController setupInteractionControllerForTransitionFromViewController:(UIViewController *)fromViewController
		  toViewController:(UIViewController *)toViewController;
@end
