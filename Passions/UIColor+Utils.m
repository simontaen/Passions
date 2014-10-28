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
		musicTintColor = [UIColor orangeColor];
	});
	return musicTintColor;
}

+ (UIColor *)spotifyTintColor
{
	static UIColor *spotifyTintColor;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		spotifyTintColor = [UIColor greenColor];
	});
	return spotifyTintColor;
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

+ (UIColor*)defaultTintColor;
{
	static UIColor* defaultTintColor;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		UIView* view = [[UIView alloc] init];
		defaultTintColor = view.tintColor;
	});
	return defaultTintColor;
}

@end
