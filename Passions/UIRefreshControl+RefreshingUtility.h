//
//  UIRefreshControl+RefreshingUtility.h
//  Passions
//
//  Created by Simon Tännler on 11/11/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIRefreshControl (RefreshingUtility)

/** Thread save beginRefreshing increment */
- (void)RUTincrementRefreshing;
/** Thread save endRefreshing decrement */
- (void)RUTdecrementRefreshing;

@end
