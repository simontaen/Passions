//
//  Album.h
//  Passions
//
//  Created by Simon Tännler on 29/07/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Artist, Tag, Track;

@interface Album : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) NSNumber * albumId;
@property (nonatomic, retain) NSDate * releaseDate;
@property (nonatomic, retain) NSSet *artists;
@property (nonatomic, retain) NSSet *tracks;
@property (nonatomic, retain) NSSet *topTags;
@end

@interface Album (CoreDataGeneratedAccessors)

- (void)addArtistsObject:(Artist *)value;
- (void)removeArtistsObject:(Artist *)value;
- (void)addArtists:(NSSet *)values;
- (void)removeArtists:(NSSet *)values;

- (void)addTracksObject:(Track *)value;
- (void)removeTracksObject:(Track *)value;
- (void)addTracks:(NSSet *)values;
- (void)removeTracks:(NSSet *)values;

- (void)addTopTagsObject:(Tag *)value;
- (void)removeTopTagsObject:(Tag *)value;
- (void)addTopTags:(NSSet *)values;
- (void)removeTopTags:(NSSet *)values;

@end
