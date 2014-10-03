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
	
	// TODO: PFUser subclass
	NSArray *favoriteArtistIds = (NSArray *)[[PFUser currentUser] objectForKey:@"favArtists"];
	
	PFQuery *albumQuery = [PFQuery queryWithClassName:@"Album"];
	[albumQuery whereKey:@"artistId" containedIn:favoriteArtistIds];
	
	[albumQuery findObjectsInBackgroundWithBlock:^(NSArray *albums, NSError *error) {
		
		NSLog(@"Found %lu albums", (unsigned long)albums.count);
		
		for (PFObject *album in albums) {
			NSLog(@"Name %@", [album objectForKey:@"name"]);
			NSLog(@"ReleaseDate %@", [album objectForKey:@"release_date"]);
		}
	}];

	
	
}

@end
