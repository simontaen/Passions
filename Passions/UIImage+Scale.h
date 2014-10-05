//
//  UIImage+Scale.h
//  Passions
//
//  Created by Simon Tännler on 04/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

@import UIKit;

/// see http://stackoverflow.com/a/14220605
@interface UIImage (Scale)

/// This will squeeze/strech the image until it fits the passed size (distortions!)
- (UIImage*)PASscaleToFillSize:(CGSize)size;

/// This scales the image keeping the aspect ratio, such that
/// the BIGGER side fits the passed size exactly (transparency!)
- (UIImage*)PASscaleToAspectFitSize:(CGSize)size;

/// This scales the image keeping the aspect ratio, such that
/// the SMALLER side fits the passed size exactly (cropping!)
- (UIImage*)PASscaleToAspectFillSize:(CGSize)size;

/// Similar to AspectFillSize
/// the SMALLER side fits the passed size exactly (cropping!)
+ (UIImage *)FICDSquareImageFromImage:(UIImage *)image;

@end
