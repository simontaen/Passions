//
//  PASAddFromMusicTVC.m
//  Passions
//
//  Created by Simon Tännler on 07/12/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import "PASAddFromMusicTVC.h"

@interface PASAddFromMusicTVC ()
// of MPMediaItem
@property (nonatomic, strong) NSArray* artists;
@end

@implementation PASAddFromMusicTVC

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	[self setTitle:@"iPod Artists"];

	self.query = [MPMediaQuery artistsQuery];
	self.artists = [self.query collections];
	
	// order by a combination of
	// MPMediaItemPropertyPlayCount
	// MPMediaItemPropertyRating
	// see MPMediaItem Class Reference
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.artists count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LibraryArtist" forIndexPath:indexPath];
    
	MPMediaItemCollection *artist = self.artists[indexPath.row];
    MPMediaItem *item = [artist representativeItem];
	
	cell.textLabel.text = [item valueForProperty: MPMediaItemPropertyArtist];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu Tracks", (unsigned long)[[artist items] count]];
	
	
    MPMediaItemArtwork *artwork = [item valueForProperty: MPMediaItemPropertyArtwork];
	UIImage *artworkImage = [artwork imageWithSize:cell.imageView.bounds.size];
	
	if (artworkImage) {
		CGSize itemSize = cell.imageView.image.size;
		UIGraphicsBeginImageContext(itemSize);
		CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
		[artworkImage drawInRect:imageRect];
		cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	} else {
		cell.imageView.image = [UIImage imageNamed: @"image.png"];
	}
	
	
    return cell;
}

@end
