//
//  PASTimelineCVC.m
//  Passions
//
//  Created by Simon Tännler on 07/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASTimelineCVC.h"
#import <Parse/Parse.h>
#import "PFArtist.h"

@interface PASTimelineCVC ()

@end

@implementation PASTimelineCVC

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	//[PASResources printViewLayoutStack:self];
	//[PASResources printViewControllerLayoutStack:self];
	//[PASResources printGestureRecognizerStack:self];
	
	NSArray *favoriteArtistIds = (NSArray *)[[PFInstallation currentInstallation] objectForKey:@"favArtists"];
	
	PFQuery *artistQuery = [PFArtist query];
	[artistQuery whereKey:@"objectId" containedIn:favoriteArtistIds];
	
	[artistQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		NSMutableArray *albumsOfFavArtists = [NSMutableArray array];
		
		for (PFArtist *artist in objects) {
			[albumsOfFavArtists addObjectsFromArray:artist.albums];
		}
		NSLog(@"Found %lu Album Ids", albumsOfFavArtists.count);

		
		PFQuery *albumQuery = [PFQuery queryWithClassName:@"Album"];
		[albumQuery whereKey:@"objectId" containedIn:albumsOfFavArtists];
		
		
		[albumQuery findObjectsInBackgroundWithBlock:^(NSArray *albums, NSError *error) {
			
			NSLog(@"Found %lu albums", albums.count);
			
			for (PFObject *album in albums) {
				NSLog(@"Name %@", [album objectForKey:@"name"]);
			}
		}];
		
	}];
	
}

@end
