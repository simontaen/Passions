//
//  PASPageViewController.h
//  Passions
//
//  Created by Simon Tännler on 11/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PASPageControlView.h"

@protocol PASPageViewControllerDelegate;

@interface PASPageViewController : UIViewController
// setting this will move the page!
@property (nonatomic) int selectedViewControllerIndex;
// the currently displaying view controller
@property (weak, nonatomic, readonly) UIViewController *selectedViewController;
// all the view controllers this container displays
@property (nonatomic, copy) NSArray *viewControllers;
// this view controllers delegate, defaults to it's own implementation
@property (weak, nonatomic) id<PASPageViewControllerDelegate> delegate;
@end

@protocol PASPageViewControllerDelegate <NSObject>
@required
- (id <UIViewControllerInteractiveTransitioning>)pageViewController:(PASPageViewController *)pageViewController
						interactionControllerForAnimationController: (id <UIViewControllerAnimatedTransitioning>)animationController;

- (id <UIViewControllerAnimatedTransitioning>)pageViewController:(PASPageViewController *)pageViewController
			  animationControllerForTransitionFromViewController:(UIViewController *)fromVC
												toViewController:(UIViewController *)toVC;
@end
