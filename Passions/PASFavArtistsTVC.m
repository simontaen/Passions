//
//  PASFavArtistsTVC.m
//  Passions
//
//  Created by Simon Tännler on 03/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASFavArtistsTVC.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+Scale.h"
#import "PASResources.h"
#import "PFArtist.h"

@interface PASFavArtistsTVC()

@end

@implementation PASFavArtistsTVC

#pragma mark - Init

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (!self) return nil;
	self.parseClassName = [PFArtist parseClassName];
	self.title = @"Favorite Artists";
	self.pullToRefreshEnabled = YES;
	self.paginationEnabled = YES;
	self.objectsPerPage = 20;
    return self;
}

{
}

#pragma mark - UITableViewDataSource Editing

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//  // TODO: I can't remove the Artist from self.objects manually, need to reload, but seems to slow for the animation.
//	if (editingStyle == UITableViewCellEditingStyleDelete) {
//		// Delete the row from the data source
//		PFObject *artist = [self objectAtIndexPath:indexPath];
//		[artist removeObject:[PFUser currentUser] forKey:@"favByUsers"];
//
//		[artist saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//			if (succeeded) {
//				dispatch_async(dispatch_get_main_queue(), ^{
//					[self loadObjects];
//					[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
//				});
//			}
//		}];
//
//	} else if (editingStyle == UITableViewCellEditingStyleInsert) {
//		// Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//	}
//}


#pragma mark - Parse

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    
    // This method is called every time objects are loaded from Parse via the PFQuery
}

- (void)objectsWillLoad {
    [super objectsWillLoad];
    
    // This method is called before a PFQuery is fired to get more objects
}

// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.
- (PFQuery *)queryForTable {
//	PFUser *user = [PFUser currentUser];
//	NSLog(@"isDataAvailable = %@", ([user isDataAvailable] ? @"YES" : @"NO"));
//	NSLog(@"isDirty = %@", ([user isDirty] ? @"YES" : @"NO"));
//	NSLog(@"isNew = %@", ([user isNew] ? @"YES" : @"NO"));
//	NSLog(@"isDirtyForKey = %@", ([user isDirtyForKey:@"objectId"] ? @"YES" : @"NO"));
	
	if ([[PFUser currentUser] isDirty]) {
		// this must be a new user
		// save it or else the query will crash
		[[PFUser currentUser] save];
	}
	
	PFQuery *query = [PFArtist favArtistsForCurrentUser];
	
	// If no objects are loaded in memory, we look to the cache first to fill the table
	// and then subsequently do a query against the network.
	if (self.objects.count == 0) {
		query.cachePolicy = kPFCachePolicyCacheThenNetwork;
	}
	
	return query;
}


// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
	static NSString *CellIdentifier = @"FavArtist";
	PFArtist *artist = (PFArtist *)object;
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	
    // Configure the cell
    cell.textLabel.text = artist.name;
    cell.detailTextLabel.text = [self stringForNumberOfAlbums:artist.totalAlbums];
	
	// get images, ordered big to small
	NSArray *images = artist.images;
	
	if (images.count != 0) {
		// round down, this is only a thumbnail
		int middle = (int)(images.count / 2 - ((images.count % 2) / 2));
		
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:images[middle]]];
		[request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
		
		__weak typeof(cell) weakCell = cell;
		[cell.imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			
			UIImage *newImage;
			
			if (image) {
				newImage = [image PASscaleToAspectFillSize:weakCell.imageView.image.size];
			} else {
				newImage = [PASResources artistThumbnailPlaceholder];
			}
			dispatch_async(dispatch_get_main_queue(), ^{
				weakCell.imageView.image = newImage;
			});
		} failure:nil];
	}
	
    return cell;
}

- (NSString *)stringForNumberOfAlbums:(NSNumber *)noOfAlbums
{
	if (noOfAlbums.longValue == 1) {
		return [NSString stringWithFormat:@"%lu Album", noOfAlbums.longValue];
	} else {
		return [NSString stringWithFormat:@"%lu Albums", noOfAlbums.longValue];
	}
}

/*
 // Override to customize the look of the cell that allows the user to load the next page of objects.
 // The default implementation is a UITableViewCellStyleDefault cell with simple labels.
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
 static NSString *CellIdentifier = @"NextPage";
 
 // TODO: The cell should show a spinner and load more data automatically
 
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
 
 cell.selectionStyle = UITableViewCellSelectionStyleNone;
 cell.textLabel.text = @"Load more...";
 
 return cell;
 }
 */

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	// Get the new view controller using [segue destinationViewController].
	// Pass the selected object to the new view controller.
	
	if ([segue.identifier isEqualToString:@"setFavoriteArtists:"]) {
		// goes to add artists, needs to know about current favorites
		NSMutableArray *artistNames = [[NSMutableArray alloc] initWithCapacity:self.objects.count];
		for (PFArtist *artist in self.objects) {
			[artistNames addObject:artist.name];
		}
		
		if ([segue.destinationViewController respondsToSelector:@selector(setFavArtistNames:)]) {
			[segue.destinationViewController performSelector:@selector(setFavArtistNames:) withObject:artistNames];
		}
	}
}

@end
