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
#import "GBVersionTracking.h"

@interface PASRootVC ()
@property (nonatomic, assign) BOOL didOnboard;
@property (nonatomic, assign) BOOL didSetupPushNotificaiton;
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
													  // Show Timeline when push arrives
													  [self transitionToViewControllerAtIndex:0 interactive:NO];
												  }];
	[[NSNotificationCenter defaultCenter] addObserverForName:kPASDidFavoriteInitialArtists
													  object:nil queue:nil
												  usingBlock:^(NSNotification *note) {
													  PASTimelineCVC *vc = (PASTimelineCVC *)self.selectedViewController;
													  [vc loadObjects];
													  // this is a one time only thing
													  [[NSNotificationCenter defaultCenter] removeObserver:nil
																									  name:kPASDidFavoriteInitialArtists
																									object:self];
												  }];
	// init and add the page view controllers view controllers
	self.viewControllers = @[[self _timeline], [self _favArtists]];
}

- (UINavigationController *)_favArtists
{
	return [self.storyboard instantiateViewControllerWithIdentifier:@"FavArtistsNav"];
}

- (UINavigationController *)_timeline
{
	return [[UINavigationController alloc] initWithRootViewController:[PASTimelineCVC new]];
}

#pragma mark - View Lifecycle

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	if (!self.didOnboard && [GBVersionTracking isFirstLaunchEver]) {
		// _onboard will setup push notifications
		[self _onboard];
	} else if (!self.didSetupPushNotificaiton) {
		// no need to onboard, just setup notifications directly
		[self _setupPushNotificaiton];
	}
}

#pragma mark - Onboarding

- (void)_onboard
{
	UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Hi!"
																   message:@"Passions lets you track your favorite Aritsts and sends you Notifications when one of them releases a new Album. To enable these Notification please allow \"Push Notification\"."
															preferredStyle:UIAlertControllerStyleAlert];
	__weak typeof(self) weakSelf = self;
	UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"Let's go!"
															style:UIAlertActionStyleDefault
														  handler:^(UIAlertAction * action) {
															  [self dismissViewControllerAnimated:YES completion:nil];
															  self.didOnboard = YES;
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
	self.didSetupPushNotificaiton = YES;
}

@end
