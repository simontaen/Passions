//
//  PASManageArtists.h
//  Passions
//
//  Created by Simon Tännler on 21/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PASManageArtists : NSObject

+ (instancetype) sharedMngr;

- (void)passFavArtists:(NSArray *)favArtists;

- (BOOL)didEditArtists;

- (void)didSelectArtistWithName:(NSString *)artistName
						cleanup:(void (^)())cleanup
						 reload:(void (^)())reload
				   errorHandler:(void (^)(NSError *error))errorHandler;

- (BOOL)isFavoriteArtist:(NSString *)artistName;

- (void)addInitialFavArtists;

- (void)writeToDisk;

@end
