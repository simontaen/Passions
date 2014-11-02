//
//  MPMediaItemCollection+SourceImage.m
//  Passions
//
//  Created by Simon Tännler on 06/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "MPMediaItemCollection+SourceImage.h"
#import "FICUtilities.h"
#import "UIImage+Utils.h"
#import <objc/runtime.h>
#import "PASArtist.h"
#import "MPMediaItem+Passions.h"

// http://oleb.net/blog/2011/05/faking-ivars-in-objc-categories-with-associative-references/
// http://nshipster.com/associated-objects/

@implementation MPMediaItemCollection (SourceImage)

#pragma mark - Passions

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

- (NSString *)PAS_artistName
{
	return [[self representativeItem] PAS_artistName];
}

#pragma mark - PASSourceImage

- (UIImage *)sourceImageWithFormatName:(NSString *)formatName;
{
	NSAssert([formatName isEqualToString:ImageFormatNameArtistThumbnailSmall], @"Unsupported format Name: %@", formatName);
	return [[[self representativeItem] valueForProperty:MPMediaItemPropertyArtwork] imageWithSize:ImageFormatImageSizeArtistThumbnailLarge];
}

#pragma mark - FICEntity

@dynamic UUID;

- (NSString *)UUID
{
	id obj = objc_getAssociatedObject(self, @selector(UUID));
	if (!obj) {
		NSNumber *persistentId = [self valueForProperty:MPMediaItemPropertyPersistentID];
		CFUUIDBytes UUIDBytes = FICUUIDBytesFromMD5HashOfString([persistentId stringValue]);
		NSString *uuid = FICStringWithUUIDBytes(UUIDBytes);
		objc_setAssociatedObject(self, @selector(UUID), uuid, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		return uuid;
	}
	return obj;
}

- (NSString *)sourceImageUUID
{
	return self.UUID;
}

- (NSURL *)sourceImageURLWithFormatName:(NSString *)formatName
{
	// This does not HAVE to be a valid URL
	// FIC uses this to key the pending requests
	return [NSURL URLWithString:self.UUID];
}

- (FICEntityImageDrawingBlock)drawingBlockForImage:(UIImage *)image withFormatName:(NSString *)formatName
{
	return [UIImage drawingBlockForImage:image withFormatName:formatName];
}

@end
