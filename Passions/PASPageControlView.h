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

// not needed - would tell the control WHAT to display
//- (NSArray *)itemsForMenuView:(STKMenuView *)menuView;

// not needed - would tell the control WHICH exact item to start with
//- (int)selectedIndexForMenuView:(PASPageControlView *)pageControlView;

// this is the method telling me where I am
- (void)pageControlView:(PASPageControlView *)pageControlView didMoveToIndex:(int)index;

@end

@protocol PASPageControlViewDataSource <NSObject>

//- (UIViewController *)pageControlView:(PASPageControlView *)pageControlView viewControllerBeforeViewController:(UIViewController *)viewController;
//- (UIViewController *)pageControlView:(PASPageControlView *)pageControlView viewControllerAfterViewController:(UIViewController *)viewController;

// Tell the control how many pages there are
- (NSInteger)presentationCountForPageControlView:(PASPageControlView *)pageControlView;

// Tell the control at which index to indicate the current page
- (NSInteger)presentationIndexForPageControlView:(PASPageControlView *)pageControlView;

@end

@interface PASPageControlView : UIPageControl
@property (nonatomic, weak) id <PASPageControlViewDelegate, PASPageControlViewDataSource> delegate;
@end
