//
//  PASColorPickerCache.m
//  Passions
//
//  Created by Simon Tännler on 02/12/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASColorPickerCache.h"
#import "UICKeyChainStore.h"
#import "GBVersiontracking.h"

@interface PASColorPickerCache()
@property (nonatomic, strong) LEColorPicker *picker;
@property (nonatomic, strong) NSMutableDictionary* cache;
@end

@implementation PASColorPickerCache

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
	// register for memory warnings
	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidReceiveMemoryWarningNotification
													  object:nil queue:nil
												  usingBlock:^(NSNotification *note) {
													  [self writeToDisk];
													  self.picker = nil;
													  self.cache = nil;
												  }];
	return self;
}

#pragma mark - Accessors

- (LEColorPicker *)picker
{
	if (!_picker) {
		_picker = [LEColorPicker new];
	}
	return _picker;
}

-(NSMutableDictionary *)cache
{
	if (!_cache) {
		if ([GBVersionTracking isFirstLaunchForBuild]) {
			// on first build launch, clear cache data
			_cache = [NSMutableDictionary new];
			
		} else {
			NSData *cacheData = [UICKeyChainStore dataForKey:NSStringFromClass([self class])];
			
			if (cacheData) {
				_cache = (NSMutableDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:cacheData];
			} else {
				_cache = [NSMutableDictionary new];
			}
		}
	}
	return _cache;
}

#pragma mark - Cache Retrieval

- (void)pickColorsFromImage:(UIImage*)image
					withKey:(NSString *)key
				 completion:(void (^)(LEColorScheme *colorScheme))completion
{
	NSParameterAssert(key);
	
	LEColorScheme *colors = self.cache[key];
	
	if (!colors) {
		if (image) {
			[self.picker pickColorsFromImage:image onComplete:^(LEColorScheme *colorScheme) {
				self.cache[key] = colorScheme;
				completion(colorScheme);
			}];
			return;
			
		} else {
			// dummy
			LEColorScheme *colors = [LEColorScheme new];
			colors.backgroundColor = [UIColor clearColor];
			colors.primaryTextColor = [UIColor darkTextColor];
			colors.secondaryTextColor = [UIColor lightTextColor];
		}
	}
	
	if ([NSThread isMainThread]) {
		completion(colors);
		
	} else {
		dispatch_async(dispatch_get_main_queue(), ^{
			completion(colors);
		});
	}
}

#pragma mark - Housholding

- (void)writeToDisk
{
	NSData *cacheData = [NSKeyedArchiver archivedDataWithRootObject:self.cache];
	[UICKeyChainStore setData:cacheData forKey:NSStringFromClass([self class])];
}

#pragma mark - dealloc

- (void)dealloc
{
	[self writeToDisk];
	// [super dealloc]; //(provided by the compiler)
}

@end
