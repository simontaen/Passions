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

@property (nonatomic, strong, readonly) NSArray *artistCollectionsOrderedByName; // of MPMediaItemCollection
@property (nonatomic, strong, readonly) NSArray *artistCollectionsOrderedByPlaycount; // of MPMediaItemCollection
@property (nonatomic, assign, readonly) BOOL usesMusicApp;

- (NSUInteger)playcountForArtistWithName:(NSString *)artistName;
- (void)prepareCaches;

@end
