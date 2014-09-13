//
//  PASTimelineCVC.m
//  Passions
//
//  Created by Simon Tännler on 07/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASTimelineCVC.h"

@interface PASTimelineCVC ()

@end

@implementation PASTimelineCVC

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[PASResources printViewLayoutStack:self];
	[PASResources printViewControllerLayoutStack:self];
	[PASResources printGestureRecognizerStack:self];
}

@end
