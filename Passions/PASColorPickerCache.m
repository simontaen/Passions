//
//  PASColorPickerCache.m
//  Passions
//
//  Created by Simon Tännler on 02/12/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASColorPickerCache.h"
#import "UICKeyChainStore.h"

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
	
	NSData *cacheData = [UICKeyChainStore dataForKey:NSStringFromClass([self class])];
	self.cache = (NSMutableDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:cacheData];
	
	if (!self.cache) {
		self.cache = [NSMutableDictionary new];
	}
	
	return self;
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

@end
