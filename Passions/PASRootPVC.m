//
//  PASRootPVC.m
//  Passions
//
//  Created by Simon Tännler on 12/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASRootPVC.h"
#import "PASFavArtistsTVC.h"
#import "PASTimelineCVC.h"

@interface PASRootPVC ()

@end

@implementation PASRootPVC

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.viewControllers = @[[self favArtistsNavController], [self timelineCVC]];
	// DEBUG
	self.view.backgroundColor = [UIColor yellowColor];
}

- (UINavigationController *)favArtistsNavController
{
	// Create a nav controller to hack around the status bar problem (also creates containing view controller)
	return [self.storyboard instantiateViewControllerWithIdentifier:@"FavArtistsNav"];
}

- (PASTimelineCVC *)timelineCVC
{
	return [self.storyboard instantiateViewControllerWithIdentifier:@"PASTimelineCVC"];
}

@end
