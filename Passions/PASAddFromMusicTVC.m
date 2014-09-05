//
//  PASAddFromMusicTVC.m
//  Passions
//
//  Created by Simon Tännler on 07/12/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//

#import "PASAddFromMusicTVC.h"
#import "UIImage+Scale.h"
#import "PASResources.h"

@interface PASAddFromMusicTVC ()
@property (nonatomic, strong) NSArray* artists; // of MPMediaItem
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
// http://stackoverflow.com/a/5511403 / http://stackoverflow.com/a/13705529
@property (nonatomic, strong) dispatch_queue_t musicArtworkQueue;
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

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	self.musicArtworkQueue = dispatch_queue_create("MusicArtwork", DISPATCH_QUEUE_CONCURRENT);
}

- (IBAction)doneButtonHandler:(UIBarButtonItem *)sender
{
	// Go back to the previous view
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
	dispatch_async(self.musicArtworkQueue, ^{
		
		MPMediaItemArtwork *artwork = [item valueForProperty: MPMediaItemPropertyArtwork];
		UIImage *artworkImage = [artwork imageWithSize:cell.imageView.image.size];
		UIImage *newImage;
		
		if (artworkImage) {
			newImage = [artworkImage PASscaleToAspectFillSize:weakCell.imageView.image.size];
		} else {
			newImage = [PASResources artistThumbnailPlaceholder];
		}
		dispatch_async(dispatch_get_main_queue(), ^{
			weakCell.imageView.image = newImage;
		});
	});
	
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
	
	// grey out the row and put a spinner on it
	// disable user interaction
	
	MPMediaItem *artistItem = self.artists[indexPath.row];
	
	NSString *artist = [artistItem valueForProperty:MPMediaItemPropertyArtist];
	NSString *albumArtist = [artistItem valueForProperty:MPMediaItemPropertyAlbumArtist];
	NSLog(@"%@", artist);
	NSLog(@"%@", albumArtist);
	
	// call PFArtist favoriteArtist:(NSString *)artist byUser:(PFUser *)user];
	// grey out artist

}

@end
