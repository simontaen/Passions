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
#import "PASSourceImage.h"
#import "PASAlbum.h"
#import "GBVersiontracking.h"
#import "UIDevice-Hardware.h"
#import "PASManageArtists.h"
#import <Spotify/Spotify.h>
#import "PASMediaQueryAccessor.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

// Sends kPASDidEditFavArtists Notifications to signal if favorite Artists have been processed
@interface PASAppDelegate () <FICImageCacheDelegate>

@end

@implementation PASAppDelegate

static NSString * const kAlbumIdPushKey = @"a";
static NSString * const kFavArtistsRefreshPushKey = @"far";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Setup LastFmFetchr
	[LastFmFetchr fetchrWithApiKey:kPASLastFmApiKey];
	
	// Setup GBVersionTracking
	[GBVersionTracking track];
	
	[self _setupParse];
	[self _setupImageCache];
	[self _setupMusicAppCache];
	[self _setupCrashlytics];
	
	if (application.applicationState != UIApplicationStateBackground) {
		// Track an app open here if NOT from push,
		// else you would track it twice
		NSDictionary *userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
		
		if (!userInfo) {
			[PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
		} else {
			NSLog(@"UserInfo didFinishLaunchingWithOptions %@", userInfo);
		}
	}
	
	return YES;
}

#pragma mark - Crashlytics

- (void)_setupCrashlytics
{
	// Setup Crashlytics
	[Fabric with:@[CrashlyticsKit]];
	[Crashlytics sharedInstance];
	
	[Crashlytics setUserIdentifier:[PFUser currentUser].objectId];
}

#pragma mark - Parse

- (void)_setupParse
{
	[Parse setApplicationId:kPASParseAppId
				  clientKey:kPASParseClientKey];
	
	[PFUser enableAutomaticUser];
	// the app will crash if currentUser is a new user!
	// queryForTable required a saved users for the parse object ID
	
	PFACL *defaultACL = [PFACL ACL];
	
	// If you would like all objects to be private by default, remove this line.
	[defaultACL setPublicReadAccess:YES];
	[PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
	
	PFInstallation *currentInstallation = [PFInstallation currentInstallation];
	PFUser *currentUser = [PFUser currentUser];
	
	if ([GBVersionTracking isFirstLaunchEver] || ![PFUser currentUser].objectId) {
		// setup install and user on first launch
		[self _updateDeviceInfos:currentInstallation];
		[currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
			if (succeeded && !error) {
				NSLog(@"Current Installation initialized: %@", currentInstallation.objectId);
				// create the assosiation for push notifications
				[currentUser setObject:currentInstallation.objectId forKey:@"installation"];
				[currentUser setObject:@0 forKey:@"runCount"];
				[currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
					if (succeeded && !error) {
						NSLog(@"Current User initialized: %@", currentUser.objectId);
						[[PASManageArtists sharedMngr] addInitialFavArtists];
					}
				}];
			}
		}];
		
	} else if ([GBVersionTracking isFirstLaunchForBuild]) {
		// on first build launch, update the device specs
		[self _updateDeviceInfos:currentInstallation];
		[currentInstallation saveInBackground];
		// DEBUG (since I'm changing artwork quite often
		[[FICImageCache sharedImageCache] reset];
	}
}

- (void)_updateDeviceInfos:(PFInstallation *)installation
{
	[installation setObject:[UIDevice currentDevice].modelName forKey:@"modelName"];
	[installation setObject:[UIDevice currentDevice].modelIdentifier forKey:@"modelIdentifier"];
	[installation setObject:[UIDevice currentDevice].systemVersion forKey:@"systemVersion"];
}

#pragma mark - FICImageCacheDelegate

- (void)_setupImageCache
{
	FICImageFormat *mediumAlbumThumbnailImageFormat = [FICImageFormat formatWithName:ImageFormatNameAlbumThumbnailMedium
																			  family:ImageFormatFamilyAlbumThumbnails
																		   imageSize:ImageFormatImageSizeAlbumThumbnailMedium
																			   style:FICImageFormatStyle32BitBGR
																		maximumCount:800
																			 devices:FICImageFormatDevicePhone
																	  protectionMode:FICImageFormatProtectionModeNone];
	FICImageFormat *largeAlbumThumbnailImageFormat = [FICImageFormat formatWithName:ImageFormatNameAlbumThumbnailLarge
																			 family:ImageFormatFamilyAlbumThumbnails
																		  imageSize:ImageFormatImageSizeAlbumThumbnailLarge
																			  style:FICImageFormatStyle32BitBGR
																	   maximumCount:800
																			devices:FICImageFormatDevicePhone
																	 protectionMode:FICImageFormatProtectionModeNone];
	FICImageFormat *smallArtistThumbnailImageFormat = [FICImageFormat formatWithName:ImageFormatNameArtistThumbnailSmall
																			  family:ImageFormatFamilyArtistThumbnails
																		   imageSize:ImageFormatImageSizeArtistThumbnailSmall
																			   style:FICImageFormatStyle32BitBGR
																		maximumCount:200
																			 devices:FICImageFormatDevicePhone
																	  protectionMode:FICImageFormatProtectionModeNone];
	FICImageFormat *largeArtistThumbnailImageFormat = [FICImageFormat formatWithName:ImageFormatNameArtistThumbnailLarge
																			  family:ImageFormatFamilyArtistThumbnails
																		   imageSize:ImageFormatImageSizeArtistThumbnailLarge
																			   style:FICImageFormatStyle32BitBGR
																		maximumCount:200
																			 devices:FICImageFormatDevicePhone
																	  protectionMode:FICImageFormatProtectionModeNone];
	FICImageCache *sharedImageCache = [FICImageCache sharedImageCache];
	sharedImageCache.delegate = self;
	sharedImageCache.formats = @[mediumAlbumThumbnailImageFormat,
								 largeAlbumThumbnailImageFormat,
								 smallArtistThumbnailImageFormat,
								 largeArtistThumbnailImageFormat];
}

- (void)imageCache:(FICImageCache *)imageCache wantsSourceImageForEntity:(id<FICEntity>)entity withFormatName:(NSString *)formatName completionBlock:(FICImageRequestCompletionBlock)completionBlock
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		UIImage *sourceImage;
		if ([entity conformsToProtocol:@protocol(PASSourceImage)]) {
			sourceImage = [(id<PASSourceImage>)entity sourceImageWithFormatName:formatName];
			
		} else {
			// Fetch the desired source image by making a network request
			NSURL *requestURL = [entity sourceImageURLWithFormatName:formatName];
			// I could use something like AFNetworking or https://github.com/rs/SDWebImage
			// but it seems to work pretty good actually
			sourceImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:requestURL]];
		}
		
		if (!sourceImage) {
			if ([entity isKindOfClass:[PASAlbum class]]) {
				sourceImage = [PASResources albumThumbnailPlaceholder];
			} else {
				sourceImage = [PASResources artistThumbnailPlaceholder];
			}
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			completionBlock(sourceImage);
		});
	});
}

- (BOOL)imageCache:(FICImageCache *)imageCache shouldProcessAllFormatsInFamily:(NSString *)formatFamily forEntity:(id<FICEntity>)entity
{
	// you really should have the same maximumCount across the whole formatFamily if this is YES
	return YES;
}

- (void)imageCache:(FICImageCache *)imageCache errorDidOccurWithMessage:(NSString *)errorMessage
{
	NSLog(@"%@", errorMessage);
}

#pragma mark - Notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	// Store the deviceToken in the current installation and save it to Parse.
	PFInstallation *currentInstallation = [PFInstallation currentInstallation];
	[currentInstallation setDeviceTokenFromData:deviceToken];
	currentInstallation.channels = @[@"global", @"allFavArtists"];
	[self _updateDeviceInfos:currentInstallation];
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

/// Process incoming remote notifications when running or (foreground) launching from a notification
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
	NSLog(@"didReceiveRemoteNotification with UserInfo %@", userInfo);
	NSString *albumId = userInfo[kAlbumIdPushKey];
	NSString *refreshFlag = userInfo[kFavArtistsRefreshPushKey];
	
	if (albumId) {
		[self _pushHandlerNewAlbum:albumId fetchCompletionHandler:completionHandler];
		
	} else if (refreshFlag) {
		[self _pushHandlerRefreshFavArtistsWithFetchCompletionHandler:completionHandler];
	
	} else {
		completionHandler(UIBackgroundFetchResultFailed);
	}
	
	if (application.applicationState == UIApplicationStateInactive) {
		[PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
	}
}

- (void)_pushHandlerRefreshFavArtistsWithFetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kPASDidEditFavArtists
														object:self
													  userInfo:@{ kPASDidEditFavArtists : [NSNumber numberWithBool:YES] }];
	
	completionHandler(UIBackgroundFetchResultNewData);
}

- (void)_pushHandlerNewAlbum:(NSString *)objectId fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
	PASAlbum *albumSkeleton = [PASAlbum objectWithoutDataWithObjectId:objectId];
	
	[albumSkeleton fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
		PASAlbum *album = (PASAlbum *)object;
		if (error) {
			completionHandler(UIBackgroundFetchResultFailed);
		} else if (!album) {
			completionHandler(UIBackgroundFetchResultNoData);
		} else {
			[[NSNotificationCenter defaultCenter] postNotificationName:kPASShowAlbumDetails
																object:self
															  userInfo:@{ kPASShowAlbumDetails : album }];
			completionHandler(UIBackgroundFetchResultNewData);
		}
	}];
}

#pragma mark - Spotify Auth Callback

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	if ([[SPTAuth defaultInstance] canHandleURL:url withDeclaredRedirectURL:[PASResources spotifyCallbackUri]]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:kPASSpotifyClientId
															object:self
														  userInfo:@{ kPASSpotifyClientId : url }];
		return YES;
	}
	return NO;
}

#pragma mark - Music App

- (void)_setupMusicAppCache
{
	// this initializes the most expensive tasks
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[[PASMediaQueryAccessor sharedMngr] prepareCaches];
	});
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
		[self _updateDeviceInfos:currentInstallation];
		[currentInstallation saveInBackground];
	}
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
