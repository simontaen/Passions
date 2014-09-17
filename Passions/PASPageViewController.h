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
@property (nonatomic) int selectedViewControllerIndex;

/// the currently displaying view controller
@property (weak, nonatomic, readonly) UIViewController *selectedViewController;

/// all the view controllers this container displays
@property (nonatomic, copy) NSArray *viewControllers;

@end

@protocol PASPageViewControllerDelegate <NSObject>
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
@end
