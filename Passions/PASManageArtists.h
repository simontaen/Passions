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

/// completion called NOT on the main thread
- (void)didSelectArtistWithName:(NSString *)artistName
					 completion:(void (^)(NSError *error))completion;

- (BOOL)isFavoriteArtist:(NSString *)artistName isResolved:(BOOL)isResolved;
- (BOOL)isArtistInProgress:(NSString *)artistName;
- (BOOL)favingInProcess;

- (void)addInitialFavArtistsWithCompletion:(void (^)())completion;

- (void)writeToDisk;

@end
