//
//  PASParseObjectWithImages.h
//  Passions
//
//  Created by Simon Tännler on 05/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import <Parse/Parse.h>
#import "FICImageCache.h"

@interface PASParseObjectWithImages : PFObject //, FICEntity>

@property (nonatomic, strong) NSArray* images; // of NSString

@end
