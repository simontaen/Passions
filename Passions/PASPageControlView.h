//
//  PASPageControlView.h
//  Passions
//
//  Created by Simon Tännler on 11/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PASPageControlView;

@protocol PASPageControlViewDelegate <NSObject>

// from UIPageViewControllerDelegate
// Sent when a gesture-initiated transition begins.
//- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers NS_AVAILABLE_IOS(6_0);

// Sent when a gesture-initiated transition ends. The 'finished' parameter indicates whether the animation finished, while the 'completed' parameter indicates whether the transition completed or bailed out (if the user let go early).
//- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed;

// this is the method to tell the delegate to where I just moved
- (void)pageControlView:(PASPageControlView *)pageControlView didMoveToIndex:(int)index;

@end

@interface PASPageControlView : UIPageControl
@property (nonatomic, weak) id <PASPageControlViewDelegate> delegate;
@end
