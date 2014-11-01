//
//  PASAddFromSpotifyTVC.m
//  Passions
//
//  Created by Simon Tännler on 01/11/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASAddFromSpotifyTVC.h"
#import "MPMediaItemCollection+SourceImage.h"
#import "MPMediaItem+Passions.h"
#import "UIColor+Utils.h"
#import <Spotify/Spotify.h>
#import "UICKeyChainStore.h"

@interface PASAddFromSpotifyTVC ()
@property (nonatomic, strong) SPTSession *session;
@end

@implementation PASAddFromSpotifyTVC

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Try to get a stored Seesion
	NSData *sessionData = [UICKeyChainStore dataForKey:NSStringFromClass([self class])];
	self.session = [NSKeyedUnarchiver unarchiveObjectWithData:sessionData];
	
	
	// This is the callback that'll be triggered when auth is completed (or fails).
	SPTAuthCallback authCallback = ^(NSError *error, SPTSession *session) {
		
		if (error != nil) {
			NSLog(@"%@", error);
			
		} else {
			// Persist the new session
			self.session = session;
			NSData *sessionData = [NSKeyedArchiver archivedDataWithRootObject:self.session];
			[UICKeyChainStore setData:sessionData forKey:NSStringFromClass([self class])];
		}
	};

	if (!self.session) {
		// No valid session found, show login button
		[self showLoginWithSpotify];
		
	} else if (![self.session isValid]) {
		// Renew the session
		[[SPTAuth defaultInstance] renewSession:self.session withServiceEndpointAtURL:[PASResources spotifyTokenRefresh] callback:authCallback];
	}
}


#pragma mark - Accessors

- (NSString *)title
{
	return @"Spotify";
}

#pragma mark - Subclassing

- (UIColor *)chosenTintColor
{
	return [UIColor spotifyTintColor];
}

- (NSArray *)artistsOrderedByName
{
	return [MPMediaItemCollection PAS_artistsOrderedByName];
}

- (NSArray *)artistsOrderedByPlaycount
{
	return [MPMediaItemCollection PAS_artistsOrderedByPlaycount];
}

- (NSString *)nameForArtist:(id)artist
{
	NSAssert([artist isKindOfClass:[MPMediaItemCollection class]], @"%@ cannot get name for artists of class %@", NSStringFromClass([self class]), NSStringFromClass([artist class]));
	return [artist PAS_artistName];
}

- (NSUInteger)playcountForArtist:(id)artist withName:(NSString *)name
{
	NSAssert([artist isKindOfClass:[MPMediaItemCollection class]], @"%@ cannot get playcount for artists of class %@", NSStringFromClass([self class]), NSStringFromClass([artist class]));
	return [MPMediaItemCollection PAS_playcountForArtistWithName:name];
}

#pragma mark - Spotify Auth

- (void)showLoginWithSpotify
{
	
}

@end
