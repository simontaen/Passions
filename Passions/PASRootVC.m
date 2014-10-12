//
//  PASRootVC.m
//  Passions
//
//  Created by Simon Tännler on 12/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASRootVC.h"
#import "PASTimelineCVC.h"
#import "PASInteractiveTransition.h"

@interface PASRootVC ()
@property (nonatomic, strong) PASInteractiveTransition *bla;
@end

@implementation PASRootVC

#pragma mark - Init

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	// init and add the page view controllers view controllers
	self.viewControllers = @[[self _favArtistsNavController], [self _timelineCVC]];
}

#pragma mark - View Lifecycle

- (UINavigationController *)_favArtistsNavController
{
	// Create a nav controller to hack around the status bar problem (also creates containing view controller)
	return [self.storyboard instantiateViewControllerWithIdentifier:@"FavArtistsNav"];
}

- (PASTimelineCVC *)_timelineCVC
{
	return [self.storyboard instantiateViewControllerWithIdentifier:@"PASTimelineCVC"];
}

@end
