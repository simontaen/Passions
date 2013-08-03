//
//  UIApplication+Utilities.h
//
//  Created by Simon Tännler on 13/07/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (Utilities)

// Thread save network activity modifiers
- (void)enableNetworkActivity;
- (void)disableNetworkActivity;

@end
