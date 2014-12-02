//
//  PASColorPickerCache.m
//  Passions
//
//  Created by Simon Tännler on 02/12/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASColorPickerCache.h"

@interface PASColorPickerCache()
@property (nonatomic, strong) LEColorPicker *picker;
@property (nonatomic, strong) NSMutableDictionary* cache;
@end

@implementation PASColorPickerCache

static PASColorPickerCache *_cache = nil;

#pragma mark - Init

+ (instancetype) sharedMngr
{
	static PASColorPickerCache *_mngr = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_mngr = [PASColorPickerCache new];
	});
	return _mngr;
}

- (instancetype) init {
	self = [super init];
	if (!self) return nil;
	
	self.picker = [LEColorPicker new];
	self.cache = [NSMutableDictionary new];
	
	return self;
}

#pragma mark - Cache Retrieval

- (void)pickColorsFromImage:(UIImage*)image
					withKey:(NSString *)key
				 completion:(void (^)(LEColorScheme *colorScheme))completion
{
	NSParameterAssert(key);
	
	LEColorScheme *colors = self.cache[key];
	
	if (colors) {
		completion(colors);
	} else {
		[self.picker pickColorsFromImage:image onComplete:^(LEColorScheme *colorScheme) {
			self.cache[key] = colorScheme;
			completion(colorScheme);
		}];
	}
}

#pragma mark - Housholding

- (void)writeToDisk
{
//	// save name corrections
//	dispatch_barrier_async(self.correctionsQ, ^{
//		NSFileManager *mng = [NSFileManager defaultManager];
//		NSURL *cacheDir = [[mng URLsForDirectory:NSApplicationSupportDirectory
//									   inDomains:NSUserDomainMask] firstObject];
//		NSURL *cacheFile = [cacheDir URLByAppendingPathComponent:NSStringFromClass([self class])];
//		
//		// make sure the cacheDir exists
//		if (![mng fileExistsAtPath:[cacheDir path]
//					   isDirectory:nil]) {
//			NSError *err = nil;
//			BOOL success = [mng createDirectoryAtURL:cacheDir
//						 withIntermediateDirectories:YES
//										  attributes:nil
//											   error:&err];
//			if (!success) {
//				DDLogError(@"Cannot create cache dir (%@)", [err localizedDescription]);
//			}
//		}
//		
//		[self.artistNameCorrections writeToURL:cacheFile atomically:NO];
//	});
}

@end
