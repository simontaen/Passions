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
@property (nonatomic, weak) IBOutlet UIButton *spotifyLoginButton;
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
			// We are authenticated, fetch new data
			self.spotifyLoginButton.hidden = YES;
			[self fetchSpotifyArtists];

			// Persist the new session
			self.session = session;
			NSData *sessionData = [NSKeyedArchiver archivedDataWithRootObject:self.session];
			[UICKeyChainStore setData:sessionData forKey:NSStringFromClass([self class])];
		}
	};
	
	if (!self.session) {
		// No valid session found, first register for nofications when done
		[[NSNotificationCenter defaultCenter] addObserverForName:kPASSpotifyClientId
														  object:nil queue:nil
													  usingBlock:^(NSNotification *note) {
														  id obj = note.userInfo[kPASSpotifyClientId];
														  NSAssert([obj isKindOfClass:[NSURL class]], @"kPASSpotifyClientId must carry a NSURL");
														  [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:(NSURL *)obj
																							  tokenSwapServiceEndpointAtURL:[PASResources spotifyTokenSwap]
																												   callback:authCallback];
														  // this is a one time only thing
														  [[NSNotificationCenter defaultCenter] removeObserver:nil
																										  name:kPASSpotifyClientId
																										object:self];
													  }];
		// show login button
		[self showLoginWithSpotify];
		
	} else if (![self.session isValid]) {
		// Renew the session
		[[SPTAuth defaultInstance] renewSession:self.session withServiceEndpointAtURL:[PASResources spotifyTokenRefresh] callback:authCallback];
	} else {
		[self fetchSpotifyArtists];
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

#pragma mark - Spotify Data Fetching

-(void)fetchSpotifyArtists
{
	NSLog(@"Authentication successfull, loading data");
}

#pragma mark - Spotify Auth

- (void)showLoginWithSpotify
{
	UIImage *img = [PASResources spotifyLogin];
	CGFloat imgWidth = img.size.width;
	CGFloat imgHeight = img.size.height;
	
	CGRect myFrame = CGRectMake(self.view.frame.size.width / 2 - imgWidth / 2, self.view.frame.size.height / 2 - imgHeight / 2, imgWidth, imgHeight);
	UIButton *btn = [[UIButton alloc] initWithFrame:myFrame];
	self.spotifyLoginButton = btn;
	
	[btn setImage:img forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(loginWithSpotify:) forControlEvents:UIControlEventTouchUpInside];
	
	[self.view addSubview:btn];
}

-(IBAction)loginWithSpotify:(UIButton *)sender
{
	self.spotifyLoginButton.userInteractionEnabled = NO;
	NSURL *loginPageURL = [[SPTAuth defaultInstance] loginURLForClientId:kPASSpotifyClientId
													 declaredRedirectURL:[PASResources	spotifyCallbackUri]];
	[[UIApplication sharedApplication] openURL:loginPageURL];
}

@end
