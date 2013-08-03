//
//  UIApplication+Utilities.m
//
//  Created by Simon Tännler on 13/07/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import "UIApplication+Utilities.h"
#import <libkern/OSAtomic.h>


@implementation UIApplication (Utilities)

// see https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man3/atomic.3.html#//apple_ref/doc/man/3/atomic
static volatile int32_t _networkActivityCounter = 0;

- (void)enableNetworkActivity
{
	OSAtomicIncrement32(&_networkActivityCounter);
	self.networkActivityIndicatorVisible = YES;
	//NSLog(@"Increased");
}

- (void)disableNetworkActivity
{
	if (OSAtomicDecrement32(&_networkActivityCounter) <= 0) {
		self.networkActivityIndicatorVisible = NO;
//		NSLog(@"OFF");
//	} else {
//		NSLog(@"Decreased");
	}
}

@end
