//
//  PASMediaQueryAccessor.m
//  Passions
//
//  Created by Simon Tännler on 04/11/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASMediaQueryAccessor.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MPMediaItem+Passions.h"
#import "MPMediaItemCollection+Passions.h"

@interface PASMediaQueryAccessor()
@property (nonatomic, strong, readwrite) NSArray *artistCollectionsOrderedByName; // of MPMediaItemCollection
@property (nonatomic, strong, readwrite) NSArray *artistCollectionsOrderedByPlaycount; // of MPMediaItemCollection

@property (nonatomic, strong) NSDictionary *artistPlaycounts; // NSString (artistName) -> NSNumber (Playcount)
@property (nonatomic, strong) NSNumber *usesMusicAppNumber;

@end

@implementation PASMediaQueryAccessor

#pragma mark - Init

+ (instancetype) sharedMngr
{
	static PASMediaQueryAccessor *_mngr = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_mngr = [PASMediaQueryAccessor new];
	});
	return _mngr;
}

- (instancetype) init {
	self = [super init];
	if (!self) return nil;
	// register for memory warnings
	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification
													  object:nil queue:nil
												  usingBlock:^(NSNotification *note) {
													  self.artistCollectionsOrderedByName = nil;
													  self.artistCollectionsOrderedByPlaycount = nil;
													  self.artistPlaycounts = nil;
												  }];
	return self;
}

#pragma mark - Public Methods

- (BOOL)usesMusicApp
{
	if (!self.usesMusicAppNumber) {
		NSArray *artistCollections = [self artistCollectionsOrderedByPlaycount];
		NSNumber *highestPlaycount = self.artistPlaycounts[[[artistCollections firstObject] PAS_artistName]];
		
		if (artistCollections.count < 5 && [highestPlaycount integerValue] < 7) {
			self.usesMusicAppNumber = @NO;
		} else {
			self.usesMusicAppNumber = @YES;
		}
	}
	return [self.usesMusicAppNumber boolValue];
}

- (NSArray *)artistCollectionsOrderedByName
{
	if (!_artistCollectionsOrderedByName) {
		NSMutableSet *filterPredicates = [[NSMutableSet alloc] initWithCapacity:1];
		
		MPMediaPropertyPredicate *mediaType = [MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithInteger:MPMediaTypeMusic|MPMediaTypeMusicVideo]
																			   forProperty:MPMediaItemPropertyMediaType
																			comparisonType:MPMediaPredicateComparisonEqualTo];
		[filterPredicates addObject:mediaType];
		
		MPMediaQuery *query = [[MPMediaQuery alloc] initWithFilterPredicates:filterPredicates];
		query.groupingType = MPMediaGroupingArtist;
		
		NSArray *collections = [query collections];
		if (!collections) {
			// preventing a potential crash
			collections = [NSArray array];
		}
		_artistCollectionsOrderedByName = collections;
	}
	return _artistCollectionsOrderedByName;
}

- (NSArray *)artistCollectionsOrderedByPlaycount
{
	if (!_artistCollectionsOrderedByPlaycount) {
		[self prepareCaches];
	}
	return _artistCollectionsOrderedByPlaycount;
}

- (NSUInteger)playcountForArtistWithName:(NSString *)artistName
{
	if (!self.artistPlaycounts) {
		[self prepareCaches];
	}
	NSNumber *playcount = self.artistPlaycounts[artistName];
	return [playcount unsignedIntegerValue];
}

- (void)prepareCaches
{
	NSMutableDictionary* artistPlaycounts = [NSMutableDictionary dictionaryWithCapacity:self.artistCollectionsOrderedByName.count];
	
	self.artistCollectionsOrderedByPlaycount = [self.artistCollectionsOrderedByName sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		NSString *obj1Name = [obj1 PAS_artistName];
		if (!artistPlaycounts[obj1Name]) {
			artistPlaycounts[obj1Name] = [PASMediaQueryAccessor _playcountOfArtistCollection:obj1];
		}
		
		NSString *obj2Name = [obj2 PAS_artistName];
		if (!artistPlaycounts[obj2Name]) {
			artistPlaycounts[obj2Name] = [PASMediaQueryAccessor _playcountOfArtistCollection:obj2];
		}
		
		NSInteger result = [(NSNumber *)artistPlaycounts[obj1Name] unsignedIntegerValue] - [(NSNumber *)artistPlaycounts[obj2Name] unsignedIntegerValue];
		
		if (result > 0) {
			return NSOrderedAscending;
		} else if (result < 0) {
			return NSOrderedDescending;
		}
		return NSOrderedSame;
	}];
	
	self.artistPlaycounts = [NSDictionary dictionaryWithDictionary:artistPlaycounts];
	
	// this is the call during transitioning
	[self usesMusicApp];
}

#pragma mark - Private Static Helpers

// This is only intended to be used once per Collection
+ (NSNumber *)_playcountOfArtistCollection:(MPMediaItemCollection *)collection
{
	NSUInteger playcount = 0;
	for (MPMediaItem *item in [collection items]) {
		playcount += [item PAS_playcount];
	}
	return [NSNumber numberWithInteger:playcount];
}

@end
