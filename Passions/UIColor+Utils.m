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

+ (UIColor *)musicNavBarTintColor
{
	static UIColor *musicNavBarTintColor;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		musicNavBarTintColor = [UIColor orangeColor];
	});
	return musicNavBarTintColor;
}

+ (UIColor *)spotifyNavBarTintColor
{
	static UIColor *spotifyNavBarTintColor;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		spotifyNavBarTintColor = [UIColor greenColor];
	});
	return spotifyNavBarTintColor;
}

+ (UIColor *)starTintColor
{
	static UIColor *starTintColor;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		starTintColor = [UIColor orangeColor];
	});
	return starTintColor;
}

@end
