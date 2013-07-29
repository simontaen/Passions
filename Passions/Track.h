//
//  Track.h
//  Passions
//
//  Created by Simon Tännler on 29/07/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Album, Artist;

@interface Track : NSManagedObject

@property (nonatomic, retain) NSNumber * rank;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Album *album;
@property (nonatomic, retain) NSSet *artists;
@end

@interface Track (CoreDataGeneratedAccessors)

- (void)addArtistsObject:(Artist *)value;
- (void)removeArtistsObject:(Artist *)value;
- (void)addArtists:(NSSet *)values;
- (void)removeArtists:(NSSet *)values;

@end
