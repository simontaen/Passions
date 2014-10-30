//
//  UIColor+Utils.m
//  Passions
//
//  Created by Simon Tännler on 27/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "UIColor+Utils.h"

@implementation UIColor (Utils)

+ (UIColor *)defaultNavBarTintColor
{
	static UIColor *defaultNavBarTintColor;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		defaultNavBarTintColor = [UIColor colorWithRed:(247/255.0) green:(247/255.0) blue:(247/255.0) alpha:1];
	});
	return defaultNavBarTintColor;
}

+ (UIColor *)musicTintColor
{
	static UIColor *musicTintColor;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		musicTintColor = [UIColor colorWithRed:249/255.0 green:86/255.0 blue:72/255.0 alpha:1];
	});
	return musicTintColor;
}

+ (UIColor *)spotifyTintColor
{
	static UIColor *spotifyTintColor;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		spotifyTintColor = [UIColor colorWithRed:99/255.0 green:142/255.0 blue:0/255.0 alpha:1];
	});
	return spotifyTintColor;
}

+ (UIColor *)starTintColor
{
	static UIColor *starTintColor;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		starTintColor = [UIColor colorWithRed:237/255.0 green:240/255.0 blue:43/255.0 alpha:1];
	});
	return starTintColor;
}

+ (UIColor*)defaultTintColor
{
	static UIColor* defaultTintColor;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		UIView* view = [[UIView alloc] init];
		defaultTintColor = view.tintColor;
	});
	return defaultTintColor;
}

+ (UIColor *)tableViewSeparatorColor
{
	static UIColor* tableViewSeparatorColor;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		tableViewSeparatorColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4];
	});
	return tableViewSeparatorColor;
}

@end
