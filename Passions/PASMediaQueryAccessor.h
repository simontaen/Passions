//
//  PASMediaQueryAccessor.h
//  Passions
//
//  Created by Simon Tännler on 04/11/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PASMediaQueryAccessor : NSObject

+ (instancetype) sharedMngr;

- (BOOL)PAS_usesMusicApp;
- (NSArray *)artistsOrderedByName; // of MPMediaItemCollection
- (NSArray *)artistsOrderedByPlaycount; // of MPMediaItemCollection
- (NSUInteger)playcountForArtistWithName:(NSString *)artistName;

@end
