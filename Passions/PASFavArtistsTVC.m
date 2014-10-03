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
#import "PFArtist.h"
#import "PASAddArtistsNC.h"

@interface PASFavArtistsTVC() <PASAddArtistsTVCDelegate>

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

#pragma mark - Accessors

// goes to add artists, needs to know about current favorites
- (NSArray *)artistNames
{
	NSMutableArray *artistNames = [[NSMutableArray alloc] initWithCapacity:self.objects.count];
	for (PFArtist *artist in self.objects) {
		[artistNames addObject:artist.name];
	}
	return artistNames;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.edgesForExtendedLayout = UIRectEdgeLeft|UIRectEdgeBottom|UIRectEdgeRight;
	
	// DEBUG
	//self.view.backgroundColor = [UIColor greenColor];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	//[PASResources printViewControllerLayoutStack:self];
}

#pragma mark - UITableViewDataSource Editing

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	// I can't remove the Artist from self.objects manually, need to reload, but seems to slow for the animation.
	[tableView beginUpdates];
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		PFArtist *artist = [self _artistAtIndexPath:indexPath];
		
		// De-favorite the user from the artist and reload the table view
		[PFArtist removeCurrentUserFromArtist:artist withBlock:^(BOOL succeeded, NSError *error) {
			if (succeeded) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[self loadObjects];
				});
			}
		}];
		
	} else if (editingStyle == UITableViewCellEditingStyleInsert) {
		// Create a new instance of the appropriate class, and save it to Parse
	}
	[tableView endUpdates];
}

#pragma mark - Parse

- (PFArtist *)_artistAtIndexPath:(NSIndexPath *)indexPath
{
	return (PFArtist *)[self objectAtIndexPath:indexPath];
}

- (void)objectsDidLoad:(NSError *)error
{
	[super objectsDidLoad:error];
	// This method is called every time objects are loaded from Parse via the PFQuery
}

- (void)objectsWillLoad
{
	[super objectsWillLoad];
	// This method is called before a PFQuery is fired to get more objects
}

// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.
- (PFQuery *)queryForTable
{
	//	PFUser *user = [PFUser currentUser];
	//	NSLog(@"isDataAvailable = %@", ([user isDataAvailable] ? @"YES" : @"NO"));
	//	NSLog(@"isDirty = %@", ([user isDirty] ? @"YES" : @"NO"));
	//	NSLog(@"isNew = %@", ([user isNew] ? @"YES" : @"NO"));
	//	NSLog(@"isDirtyForKey = %@", ([user isDirtyForKey:@"objectId"] ? @"YES" : @"NO"));
	
	if ([[PFUser currentUser] isDirty]) {
		// TODO: this is where we create the user, make sure you set an ACL
		// this must be a new user
		// create the assosiation for push notifications
		[[PFUser currentUser] setObject:[PFInstallation currentInstallation].objectId forKey:@"installation"];
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
	static NSString *CellIdentifier = @"FavArtist";
	PFArtist *artist = (PFArtist *)object;
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	
	// Configure the cell
	cell.textLabel.text = artist.name;
	cell.detailTextLabel.text = [self _stringForNumberOfAlbums:artist.totalAlbums];
	
	// get images, ordered big to small
	NSArray *images = artist.images;
	
	if (images.count != 0) {
		// round down, this is only a thumbnail
		int middle = (int)(images.count / 2 - ((images.count % 2) / 2));
		
		// https://developer.apple.com/library/ios/documentation/WindowsViews/Conceptual/ViewPG_iPhoneOS/WindowsandViews/WindowsandViews.html
		// http://stackoverflow.com/questions/3182649/ios-sdk-uiviewcontentmodescaleaspectfit-vs-uiviewcontentmodescaleaspectfill
		// imageView of UITableViewCell automatically resizes to image, mostly ignoring contentMode, this means
		// http://nshipster.com/image-resizing/ does not work
		
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

- (NSString *)_stringForNumberOfAlbums:(NSNumber *)noOfAlbums
{
	// TODO: undefined should default to "Processing...", since fetchFullAlbums
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

#pragma mark - PASAddArtistsTVCDelegate

- (void)viewController:(PASAddFromSamplesTVC *)vc didAddArtists:(BOOL)didAddArtists
{
	if (didAddArtists) {
		[self _refreshUI];
	}
	// Go back to the previous view
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Navigation

- (void)_refreshUI
{
	// TODO: make it more clear to the user that he added objects
	[self loadObjects];
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"setFavArtistNames:"]) {
		if ([segue.destinationViewController respondsToSelector:@selector(setFavArtistNames:)]) {
			[segue.destinationViewController performSelector:@selector(setFavArtistNames:) withObject:[self artistNames]];
		}
		if ([segue.destinationViewController respondsToSelector:@selector(setMyDelegate:)]) {
			[segue.destinationViewController performSelector:@selector(setMyDelegate:) withObject:self];
		}
	}
}

@end
