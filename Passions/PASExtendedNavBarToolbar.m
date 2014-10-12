//
//  PASExtendedNavBarToolbar.m
//  Passions
//
//  Created by Simon Tännler on 12/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASExtendedNavBarToolbar.h"

@implementation PASExtendedNavBarToolbar

//| ----------------------------------------------------------------------------
//  Called when the view is about to be displayed.  May be called more than
//  once.
- (void)willMoveToWindow:(UIWindow *)newWindow
{
	// Use the layer shadow to draw a one pixel hairline under this view.
	self.layer.shadowOffset = CGSizeMake(0, 1.0f/UIScreen.mainScreen.scale);
	self.layer.shadowRadius = 0;
	
	// UINavigationBar's hairline is adaptive, its properties change with
	// the contents it overlies.  You may need to experiment with these
	// values to best match your content.
	self.layer.shadowColor = [UIColor blackColor].CGColor;
	self.layer.shadowOpacity = 0.25f;
}

@end
