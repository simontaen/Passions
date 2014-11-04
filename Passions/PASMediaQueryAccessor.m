//
//  PASMediaQueryAccessor.m
//  Passions
//
//  Created by Simon Tännler on 04/11/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASMediaQueryAccessor.h"

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
	
	return self;
}

#pragma mark - Public Methods

+ (BOOL)PAS_usesMusicApp
{
	NSArray *artists = [self PAS_artistsOrderedByPlaycount];
	
	if (artists.count < 5 && [[artists firstObject] PAS_playcount] < 7) {
		return NO;
	} else {
		return YES;
	}
}

+ (NSArray *)PAS_artistsOrderedByName
{
	id obj = objc_getAssociatedObject(self, @selector(PAS_artistsOrderedByName));
	if (!obj) {
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
		
		objc_setAssociatedObject(self, @selector(PAS_artistsOrderedByName), collections, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		return collections;
	}
	return obj;
}

+ (NSArray *)PAS_artistsOrderedByPlaycount
{
	id obj = objc_getAssociatedObject(self, @selector(PAS_artistsOrderedByPlaycount));
	if (!obj) {
		[MPMediaItemCollection _setupForPlaycountAccess];
		return objc_getAssociatedObject(self, @selector(PAS_artistsOrderedByPlaycount));
	}
	return obj;
}

+ (NSUInteger)PAS_playcountForArtistWithName:(NSString *)artistName
{
	id obj = objc_getAssociatedObject(self, @selector(PAS_playcountForArtistWithName:));
	if (!obj) {
		[MPMediaItemCollection _setupForPlaycountAccess];
		obj = objc_getAssociatedObject(self, @selector(PAS_playcountForArtistWithName:));
	}
	NSNumber *playcount = ((NSDictionary *)obj)[artistName];
	return [playcount unsignedIntegerValue];
}

+ (void)_setupForPlaycountAccess
{
	NSArray *artistsByName = [MPMediaItemCollection PAS_artistsOrderedByName];
	NSMutableDictionary* artistPlaycounts = [NSMutableDictionary dictionaryWithCapacity:artistsByName.count];
	
	NSArray *artistsByPlaycount = [artistsByName sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
		NSString *obj1Name = [obj1 PAS_artistName];
		if (!artistPlaycounts[obj1Name]) {
			artistPlaycounts[obj1Name] = [self _playcountOfCollection:obj1];
		}
		
		NSString *obj2Name = [obj2 PAS_artistName];
		if (!artistPlaycounts[obj2Name]) {
			artistPlaycounts[obj2Name] = [self _playcountOfCollection:obj2];
		}
		
		NSInteger result = [(NSNumber *)artistPlaycounts[obj1Name] unsignedIntegerValue] - [(NSNumber *)artistPlaycounts[obj2Name] unsignedIntegerValue];
		
		if (result > 0) {
			return NSOrderedAscending;
		} else if (result < 0) {
			return NSOrderedDescending;
		}
		return NSOrderedSame;
	}];
	
	objc_setAssociatedObject(self, @selector(PAS_artistsOrderedByPlaycount), artistsByPlaycount, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	objc_setAssociatedObject(self, @selector(PAS_playcountForArtistWithName:), artistPlaycounts, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+ (NSNumber *)_playcountOfCollection:(MPMediaItemCollection *)collection
{
	NSUInteger playcount = 0;
	for (MPMediaItem *item in [collection items]) {
		playcount += [item PAS_playcount];
	}
	return [NSNumber numberWithInteger:playcount];
}





@end
