//
//  UIRefreshControl+RefreshingUtility.m
//  Passions
//
//  Created by Simon Tännler on 11/11/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import "UIRefreshControl+RefreshingUtility.h"
#import <libkern/OSAtomic.h>

@implementation UIRefreshControl (RefreshingUtility)

// see https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man3/atomic.3.html#//apple_ref/doc/man/3/atomic
static volatile int32_t _networkActivityCounter = 0;

- (void)RUTincrementRefreshing;
{
	if (OSAtomicIncrement32(&_networkActivityCounter) == 1) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self beginRefreshing];
		});
		NSLog(@"ON");
	} else {
		NSLog(@"Increased");
	}
}

- (void)RUTdecrementRefreshing;
{
	if (OSAtomicDecrement32(&_networkActivityCounter) <= 0) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[self endRefreshing];
		});
		NSLog(@"OFF");
	} else {
		NSLog(@"Decreased");
	}
}

@end
