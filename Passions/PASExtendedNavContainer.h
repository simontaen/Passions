//
//  PASExtendedNavContainer.h
//  Passions
//
//  Created by Simon Tännler on 12/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PASAddFromSamplesTVC.h"
#import "PASPageViewController.h"

extern CGFloat const kPASSegmentBarHeight;

@interface PASExtendedNavContainer : UIViewController <PASPageViewControllerChildDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

// the contained view controller
@property (nonatomic, strong) PASAddFromSamplesTVC *addTvc;

/// designated initializer
- (instancetype)initWithIndex:(NSUInteger)index;

@end

@interface UIViewController (PASExtendedNavContainerAdditions)
- (PASExtendedNavContainer *)extendedNavController;
@end
