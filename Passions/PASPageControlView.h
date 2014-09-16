//
//  PASPageControlView.h
//  Passions
//
//  Created by Simon Tännler on 11/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//
//  RoundedRect code created by Jeff LaMarche on 11/13/08.
//  http://iphonedevelopment.blogspot.ch/2008/11/creating-transparent-uiviews-rounded.html
//

#import <UIKit/UIKit.h>

#define kDefaultStrokeColor         [UIColor whiteColor]
#define kDefaultRectColor           [UIColor whiteColor]
#define kDefaultStrokeWidth         1.0
#define kDefaultCornerRadius        30.0

@interface PASPageControlView : UIPageControl

// rounded rect
@property (nonatomic, retain) UIColor *strokeColor;
@property (nonatomic, retain) UIColor *rectColor;
@property CGFloat strokeWidth;
@property CGFloat cornerRadius;

@end
