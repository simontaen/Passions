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
	self.viewControllers = @[[self _timelineNavController], [self _favArtistsNavController]];
}

- (UINavigationController *)_favArtistsNavController
{
	// Create a nav controller to hack around the status bar problem (also creates containing view controller)
	return [self.storyboard instantiateViewControllerWithIdentifier:@"FavArtistsNav"];
}

- (UINavigationController *)_timelineNavController
{
	return [self.storyboard instantiateViewControllerWithIdentifier:@"TimelineNav"];
}

#pragma mark - View Lifecycle

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
//	if ([GBVersionTracking isFirstLaunchEver]) {
		// TODO: if first run!
		[self _onboard];
//	} else {
//		// no need to onboard, just setup notifications directly
//		[self _setupPushNotificaiton];
//	}
}

#pragma mark - Onboarding

- (void)_onboard
{
	UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Hi!"
																   message:@"Passions lets you track you favorite Aritst and sends you Notifications when one of them releases a new Album. To enable these Notification please allow \"Push Notification\"."
															preferredStyle:UIAlertControllerStyleAlert];
	__weak typeof(self) weakSelf = self;
	UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Let's go!"
															style:UIAlertActionStyleDefault
														  handler:^(UIAlertAction * action) {
															  [self dismissViewControllerAnimated:YES completion:nil];
															  [weakSelf _setupPushNotificaiton];
														  }];
	[alert addAction:defaultAction];
	
	[self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Notifications

- (void)_setupPushNotificaiton
{
	// Register for remote notifications
	UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge |
																						 UIUserNotificationTypeAlert |
																						 UIUserNotificationTypeSound |
																						 UIUserNotificationTypeNone)
																			 categories:nil];
	[[UIApplication sharedApplication] registerUserNotificationSettings:settings];
	[[UIApplication sharedApplication] registerForRemoteNotifications];
}

@end
