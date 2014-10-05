//
//  PASParseObjectWithImages.h
//  Passions
//
//  Created by Simon Tännler on 05/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import <Parse/Parse.h>
#import "FICEntity.h"

@interface PASParseObjectWithImages : PFObject <FICEntity>

@property (nonatomic, copy, readonly) NSURL *sourceImageURL;

@end
