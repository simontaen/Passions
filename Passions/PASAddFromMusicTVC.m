//
//  PASAddFromMusicTVC.m
//  Passions
//
//  Created by Simon Tännler on 07/12/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import "PASAddFromMusicTVC.h"
#import "UIImage+Scale.h"

@interface PASAddFromMusicTVC ()
@property (nonatomic, strong) NSArray* artists; // of MPMediaItem
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
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

- (IBAction)doneButtonHandler:(UIBarButtonItem *)sender
{
	// Go back to the previous view
	[self dismissViewControllerAnimated:YES completion:nil];
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
	
	__weak typeof(cell) weakCell = cell;
	dispatch_queue_t q = dispatch_queue_create("MusicArtwork", 0);
	dispatch_async(q, ^{
		
		MPMediaItemArtwork *artwork = [item valueForProperty: MPMediaItemPropertyArtwork];
		UIImage *artworkImage = [artwork imageWithSize:cell.imageView.image.size];
		UIImage *newImage;
		
		if (artworkImage) {
			newImage = [artworkImage PASscaleToAspectFillSize:weakCell.imageView.image.size];
		} else {
			newImage = [UIImage imageNamed: @"image.png"];
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			weakCell.imageView.image = newImage;
		});
	});
	
    return cell;
}

@end
