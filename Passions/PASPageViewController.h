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

@property (nonatomic) int selectedViewControllerIndex;
@property (nonatomic, copy) NSArray *viewControllers;

@property (nonatomic, weak, readonly) PASPageControlView *pageControlView;

@end
