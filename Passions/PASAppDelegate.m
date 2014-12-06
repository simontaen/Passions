//
//  PASAppDelegate.m
//  Passions
//
//  Created by Simon Tännler on 14/07/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import "PASAppDelegate.h"
#import "PASRootVC.h"
#import "PASTimelineCVC.h"
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
#import "PASAssertionHandler.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "DDTTYLogger.h"
#import "FRParseLogger.h"
#import <CrashlyticsLumberjack/CrashlyticsLogger.h>
#import "PASResources.h"
#import "PASColorPickerCache.h"
#import "MBProgressHUD.h"

// Sends kPASDidEditFavArtists Notifications to signal if favorite Artists have been processed
@interface PASAppDelegate () <FICImageCacheDelegate>

@end

@implementation PASAppDelegate

static NSString * const kAlbumIdPushKey = @"a";
static NSString * const kFavArtistsRefreshPushKey = @"far";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Setting a custom assertion handler"
	NSAssertionHandler* customAssertionHandler = [[PASAssertionHandler alloc] init];
	[[[NSThread currentThread] threadDictionary] setValue:customAssertionHandler
												   forKey:NSAssertionHandlerKey];
	
	// Setup AFNetworking
	[[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
	
	// Setup LastFmFetchr
	[LastFmFetchr fetchrWithApiKey:kPASLastFmApiKey];
	
	[self _setupCrashlytics];
	[self _setupParse];
	[self _setupImageCache];
	[self _setupCocoaLumberjack];
	
	if (application.applicationState != UIApplicationStateBackground) {
		// Track an app open here if NOT from push,
		// else you would track it twice
		NSDictionary *userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
		
		if (!userInfo) {
			[PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
		} else {
			DDLogInfo(@"UserInfo didFinishLaunchingWithOptions %@", userInfo);
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
}

#pragma mark - CocoaLumberjack

- (void)_setupCocoaLumberjack
{
	[DDLog addLogger:[DDTTYLogger sharedInstance] withLogLevel:LOG_LEVEL_VERBOSE];
	[[DDTTYLogger sharedInstance] setColorsEnabled:YES];

	[DDLog addLogger:[FRParseLogger sharedInstance] withLogLevel:LOG_LEVEL_INFO];
	[DDLog addLogger:[CrashlyticsLogger sharedInstance] withLogLevel:LOG_LEVEL_WARN];
}

#pragma mark - Parse

// run this AFTER Crashlytics
- (void)_setupParse
{
	// Setup GBVersionTracking
	[GBVersionTracking track];
	
	[Parse setApplicationId:kPASParseAppId
				  clientKey:kPASParseClientKey];
	
	// does the error callback still get called?
//	[Parse errorMessagesEnabled:YES];
//	[Parse offlineMessagesEnabled:YES];
	
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
		// setup installation on first launch
		[self _updateDeviceInfos:currentInstallation];
		[currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
			if (succeeded && !error) {
				DDLogInfo(@"Current Installation initialized: %@", currentInstallation.objectId);
				[self _initialUserSetup:currentUser withInstallation:currentInstallation];
				[currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
					if (succeeded && !error) {
						DDLogInfo(@"Current User initialized: %@", currentUser.objectId);
						[Crashlytics setUserIdentifier:[PFUser currentUser].objectId];
						[[PASManageArtists sharedMngr] addInitialFavArtists];
					} else {
						DDLogError(@"Could not initialize User: %@", [error localizedDescription]);
					}
				}];
			} else {
				DDLogError(@"Could not initialize Installation: %@", [error localizedDescription]);
			}
		}];
		
	} else {
		[Crashlytics setUserIdentifier:currentUser.objectId];
		[self _updateUserInfos:currentUser];
		[self _updateDeviceInfos:currentInstallation];
		
		NSUInteger runCount = [[currentUser objectForKey:@"runCount"] longLongValue];
		
		if ([GBVersionTracking isFirstLaunchForBuild]) {
			// on first build launch, make sure it really gets saved
			[currentInstallation saveInBackground];
			[currentUser saveInBackground];
			
		} else if (runCount % 3 == 0) {
			[currentInstallation saveEventually];
			[currentUser saveEventually];
		}
	}
}

- (void)_initialUserSetup:(PFUser *)user withInstallation:(PFInstallation *)installation
{
	// create the assosiation for push notifications
	[user setObject:installation.objectId forKey:@"installation"];
	[user setObject:@0 forKey:@"runCount"];
	
	// also update normal user infos
	[self _updateUserInfos:user];
}

- (void)_updateUserInfos:(PFUser *)user
{
	[user incrementKey:@"runCount"];
	[user setObject:[PASResources userCountry] forKey:@"country"];
}

/// on first ever and first build launch
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
																		   imageSize:[PASResources imageFormatImageSizeAlbumThumbnailMedium]
																			   style:FICImageFormatStyle32BitBGR
																		maximumCount:800
																			 devices:FICImageFormatDevicePhone
																	  protectionMode:FICImageFormatProtectionModeNone];
	FICImageFormat *largeAlbumThumbnailImageFormat = [FICImageFormat formatWithName:ImageFormatNameAlbumThumbnailLarge
																			 family:ImageFormatFamilyAlbumThumbnails
																		  imageSize:[PASResources imageFormatImageSizeAlbumThumbnailLarge]
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
																		   imageSize:[PASResources imageFormatImageSizeArtistThumbnailLarge]
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
			[[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];
			NSURL *requestURL = [entity sourceImageURLWithFormatName:formatName];
			[[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];

			// I could use something like AFNetworking or https://github.com/rs/SDWebImage
			// but it seems to work pretty good actually
			sourceImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:requestURL]];
		}
		
//		if (!sourceImage) {
//			if ([entity isKindOfClass:[PASAlbum class]]) {
//				sourceImage = [ImageFormatNameAlbumThumbnailMedium isEqualToString:formatName] ? [PASResources albumPlaceholderHalf] : [PASResources albumPlaceholder];
//			} else {
//				sourceImage = [ImageFormatNameArtistThumbnailSmall isEqualToString:formatName] ? [PASResources artistPlaceholderSmall] : [PASResources artistPlaceholder];
//			}
//		}
		
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
	if ([errorMessage containsString:@"returned a nil source image URL"]) {
		DDLogVerbose(@"%@", errorMessage);
	} else {
		DDLogError(@"%@", errorMessage);
	}
}

#pragma mark - Notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
	if ([GBVersionTracking isFirstLaunchEver]) {
		PASRootVC *rootVc = (PASRootVC *)self.window.rootViewController;
		UINavigationController *nav = (UINavigationController *)rootVc.selectedViewController;
		UIViewController *vc = nav.topViewController;
		if ([vc isKindOfClass:[PASTimelineCVC class]]) {
			if ([((PASTimelineCVC *)vc).objects count] == 0) {
				[MBProgressHUD showHUDAddedTo:self.window.rootViewController.view animated:YES];
			}
		}
	}
	
	// Store the deviceToken in the current installation and save it to Parse.
	PFInstallation *currentInstallation = [PFInstallation currentInstallation];
	[currentInstallation setDeviceTokenFromData:deviceToken];
	currentInstallation.channels = @[@"global", @"allFavArtists"];
	[self _updateDeviceInfos:currentInstallation];
	[currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
	if ([GBVersionTracking isFirstLaunchEver]) {
		PASRootVC *rootVc = (PASRootVC *)self.window.rootViewController;
		UINavigationController *nav = (UINavigationController *)rootVc.selectedViewController;
		UIViewController *vc = nav.topViewController;
		if ([vc isKindOfClass:[PASTimelineCVC class]]) {
			if ([((PASTimelineCVC *)vc).objects count] == 0) {
				[MBProgressHUD showHUDAddedTo:self.window.rootViewController.view animated:YES];
			}
		}
	}
	
	if (error.code == 3010) {
		DDLogVerbose(@"Push notifications are not supported in the iOS Simulator.");
	} else {
		// show some alert or otherwise handle the failure to register.
		DDLogError(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
	}
}

/// Process incoming remote notifications when running or (foreground) launching from a notification
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
	DDLogDebug(@"didReceiveRemoteNotification with UserInfo %@", userInfo);
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
	// I never call this, if the Music App is used the caches are setup when
	// the addVcContainer is initialized. When it's unused, the cache is setup
	// when the previous Vc's viewDidLoad is executed
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		// this initializes the most expensive tasks
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
	[[PASColorPickerCache sharedMngr] writeToDisk];
	[[PASManageArtists sharedMngr] writeToDisk];
}

@end
