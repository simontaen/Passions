//
//  PASPageViewController.h
//  Passions
//
//  Created by Simon Tännler on 11/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PASPageControlView.h"

@interface PASPageViewController : UIViewController
// setting this will move the page!
@property (nonatomic) int selectedViewControllerIndex;
//the currently displaying view controller
@property (weak, nonatomic, readonly) UIViewController *selectedViewController;
// all the view controllers this container displays
@property (nonatomic, copy) NSArray *viewControllers;
// all the gesture recognizers
@property (strong, nonatomic, readonly) NSArray *gestureRecognizers;
@end
