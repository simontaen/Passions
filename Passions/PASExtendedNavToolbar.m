//
//  PASExtendedNavToolbar.m
//  Passions
//
//  Created by Simon Tännler on 27/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASExtendedNavToolbar.h"

@implementation PASExtendedNavToolbar

- (void)willMoveToWindow:(UIWindow *)newWindow
{
	// Use the layer shadow to draw a one pixel hairline under this view.
	[self.layer setShadowOffset:CGSizeMake(0, 1.0f/UIScreen.mainScreen.scale)];
	[self.layer setShadowRadius:0];
	
	// UINavigationBar's hairline is adaptive, its properties change with
	// the contents it overlies.  You may need to experiment with these
	// values to best match your content.
	[self.layer setShadowColor:[UIColor blackColor].CGColor];
	[self.layer setShadowOpacity:0.25f];
}

@end
