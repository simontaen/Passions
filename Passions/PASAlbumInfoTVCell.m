//
//  PASAlbumInfoTVCell.m
//  Passions
//
//  Created by Simon Tännler on 09/11/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASAlbumInfoTVCell.h"
#import "PASColorPickerCache.h"

@implementation PASAlbumInfoTVCell

#pragma mark - Static

#pragma mark - "Accessors"

- (void)showEntity:(id<FICEntity>)entity inTableView:(UITableView *)tableView
{
	[[PASColorPickerCache sharedMngr] pickColorsFromImage:nil
												  withKey:[entity UUID]
											   completion:^(LEColorScheme *colorScheme) {
												   dispatch_async(dispatch_get_main_queue(), ^{
													   tableView.backgroundColor = colorScheme.backgroundColor;
													   self.backgroundColor = colorScheme.backgroundColor;
													   self.mainText.textColor = colorScheme.primaryTextColor;
													   self.detailText.textColor = colorScheme.primaryTextColor;
												   });
											   }];
}

#pragma mark - Static

+ (NSString *)reuseIdentifier
{
	return @"PASAlbumInfoTVCell";
}

@end
