//
//  PASResources.h
//  Passions
//
//  Created by Simon Tännler on 04/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

@import UIKit;

@interface PASResources : NSObject

+ (UIImage *) artistThumbnailPlaceholder;
+ (UIImage *) albumThumbnailPlaceholder;

+ (void)printViewControllerLayoutStack:(UIViewController *)viewController;
+ (void)printViewLayoutStack:(UIViewController *)vc;
+ (void)printGestureRecognizerStack:(UIViewController *)viewController;

@end
