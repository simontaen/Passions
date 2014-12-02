//
//  PASColorPickerCache.h
//  Passions
//
//  Created by Simon Tännler on 02/12/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LEColorPicker.h"

@interface PASColorPickerCache : NSObject

+ (instancetype) sharedMngr;

/// completion always called on the main thread
- (void)pickColorsFromImage:(UIImage*)image
					withKey:(NSString *)key
				 completion:(void (^)(LEColorScheme *colorScheme))completion;

- (void)writeToDisk;

@end
