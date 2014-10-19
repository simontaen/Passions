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
@end

@implementation PASRootVC

#pragma mark - Init

- (void)awakeFromNib
{
	[super awakeFromNib];
	// register to get notified when an album should be shown
	[[NSNotificationCenter defaultCenter] addObserverForName:kPASShowAlbumDetails
													  object:nil queue:nil
												  usingBlock:^(NSNotification *note) {
													  [self transitionToViewControllerAtIndex:1 interactive:NO];
												  }];
	// init and add the page view controllers view controllers
	self.viewControllers = @[[self _favArtistsNavController], [self _timelineNavController]];
}

#pragma mark - View Lifecycle

- (UINavigationController *)_favArtistsNavController
{
	// Create a nav controller to hack around the status bar problem (also creates containing view controller)
	return [self.storyboard instantiateViewControllerWithIdentifier:@"FavArtistsNav"];
}

- (UINavigationController *)_timelineNavController
{
	return [self.storyboard instantiateViewControllerWithIdentifier:@"TimelineNav"];
}

@end
