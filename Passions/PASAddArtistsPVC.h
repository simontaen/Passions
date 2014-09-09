//
//  PASAddArtistsPVC.h
//  Passions
//
//  Created by Simon Tännler on 07/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PASRootPVC.h"

@interface PASAddArtistsPVC : PASRootPVC <UIPageViewControllerDelegate, UIPageViewControllerDataSource>
- (IBAction)doneButtonHandler:(UIBarButtonItem *)sender;
@end
