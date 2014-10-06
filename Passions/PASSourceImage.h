//
//  PASSourceImage.h
//  Passions
//
//  Created by Simon Tännler on 06/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FICEntity.h"

@protocol PASSourceImage <NSObject, FICEntity>

@required

- (UIImage *)sourceImage;

@end
