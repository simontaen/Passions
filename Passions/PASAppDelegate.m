//
//  PASAppDelegate.m
//  Passions
//
//  Created by Simon Tännler on 14/07/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import "PASAppDelegate.h"
#import <Parse/Parse.h>
#import "LastFmFetchr.h"
#import "FICImageCache.h"
#import "PASAlbum.h"
#import "PASArtist.h"

@interface PASAppDelegate () <FICImageCacheDelegate>

@end

@implementation PASAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Setup LastFmFetchr
	[LastFmFetchr fetchrWithApiKey:@"aed3367b0133ab707cb4e5b6b04da3e7"];
	
	// Setup Parse
	[Parse setApplicationId:@"nLPKoK0wdW9csg2mTwwPkiGEDBh4AlU3f6il9qqQ"
				  clientKey:@"jxhd6vVmIttc1EVfre4Lcza9uwlKzDrCzqZJGSI9"];
	
	[PFUser enableAutomaticUser];
	// the app will crash if currentUser is a new user!
	// queryForTable required a saved users for the parse object ID
	
    PFACL *defaultACL = [PFACL ACL];
	
    // If you would like all objects to be private by default, remove this line.
    [defaultACL setPublicReadAccess:YES];
    
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
	
    if (application.applicationState != UIApplicationStateBackground) {
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced
        // in iOS 7). In that case, we skip tracking here to avoid double
        // counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            //[PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
	
	// TODO: handle this later in the app
	// this gives you a chance to load all data from the current users favorite artists
	// freeze the background view while presenting a modal to explain why notifications are needed
	// after dismissing the modal reload the table
	// Register for remote notifications
	UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge |
																						 UIUserNotificationTypeAlert |
																						 UIUserNotificationTypeSound)
																			 categories:nil];
	[[UIApplication sharedApplication] registerUserNotificationSettings:settings];
	[[UIApplication sharedApplication] registerForRemoteNotifications];
	
	// Setup Image Cache
	// TODO: figure out a better maximumCount
	FICImageFormat *mediumAlbumThumbnailImageFormat = [FICImageFormat formatWithName:ImageFormatNameAlbumThumbnailMedium
																			  family:ImageFormatFamilyAlbumThumbnails
																		   imageSize:ImageFormatImageSizeAlbumThumbnailMedium
																			   style:FICImageFormatStyle32BitBGR
																		maximumCount:250
																			 devices:FICImageFormatDevicePhone
																	  protectionMode:FICImageFormatProtectionModeNone];
	FICImageFormat *smallArtistThumbnailImageFormat = [FICImageFormat formatWithName:ImageFormatNameArtistThumbnailSmall
																			  family:ImageFormatFamilyArtistThumbnails
																		   imageSize:ImageFormatImageSizeArtistThumbnailSmall
																			   style:FICImageFormatStyle32BitBGR
																		maximumCount:250
																			 devices:FICImageFormatDevicePhone
																	  protectionMode:FICImageFormatProtectionModeNone];
	FICImageCache *sharedImageCache = [FICImageCache sharedImageCache];
	sharedImageCache.delegate = self;
	sharedImageCache.formats = @[mediumAlbumThumbnailImageFormat, smallArtistThumbnailImageFormat];

	return YES;
}

#pragma mark - FICImageCacheDelegate

- (void)imageCache:(FICImageCache *)imageCache wantsSourceImageForEntity:(id<FICEntity>)entity withFormatName:(NSString *)formatName completionBlock:(FICImageRequestCompletionBlock)completionBlock
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		// Fetch the desired source image by making a network request
		NSURL *requestURL = [entity sourceImageURLWithFormatName:formatName];
		// TODO: this might not be ideal
		UIImage *sourceImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:requestURL]];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			completionBlock(sourceImage);
		});
	});
}

- (BOOL)imageCache:(FICImageCache *)imageCache shouldProcessAllFormatsInFamily:(NSString *)formatFamily forEntity:(id<FICEntity>)entity
{
	return NO;
}

- (void)imageCache:(FICImageCache *)imageCache errorDidOccurWithMessage:(NSString *)errorMessage
{
	NSLog(@"imageCache:errorDidOccurWithMessage: %@", errorMessage);
}

#pragma mark - Notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	// TODO: can we check if we are subscribed already?
	// TODO: this is where we create the installation, make sure you set an ACL
	// Store the deviceToken in the current installation and save it to Parse.
	PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    currentInstallation.channels = @[@"global", @"allFavArtists"];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    if (error.code == 3010) {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    } else {
        // show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
	
    if (application.applicationState == UIApplicationStateInactive) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [PFPush handlePush:userInfo];
	
    if (application.applicationState == UIApplicationStateInactive) {
        [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
}

#pragma mark - Application Lifecycle

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	PFInstallation *currentInstallation = [PFInstallation currentInstallation];
	if (currentInstallation.badge != 0) {
		currentInstallation.badge = 0;
		[currentInstallation saveEventually];
	}
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
