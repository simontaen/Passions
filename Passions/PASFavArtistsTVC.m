//
//  PASFavArtistsTVC.m
//  Passions
//
//  Created by Simon Tännler on 03/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASFavArtistsTVC.h"
#import "UIImageView+AFNetworking.h"

@interface PASFavArtistsTVC()

@end

@implementation PASFavArtistsTVC

#pragma mark - View Lifecycle

- (void)loadView
{
    [super loadView];
	
	// The className to query on
	self.parseClassName = @"Artist";
	
	// The key of the PFObject to display in the label of the default cell style
	self.textKey = @"name";
	
	// The title for this table in the Navigation Controller.
	self.title = @"Favorite Artists";
	
	// Whether the built-in pull-to-refresh is enabled
	self.pullToRefreshEnabled = YES;
	
	// Whether the built-in pagination is enabled
	self.paginationEnabled = YES;
	
	// The number of objects to show per page
	self.objectsPerPage = 20;
}

-(void)viewDidLoad
{
    [super viewDidLoad];

    //[PFPush sendPushMessageToChannelInBackground:@"global" withMessage:@"Hello After viewDidLoad"];
}

#pragma mark - UITableViewDataSource Editing

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
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
	if ([[PFUser currentUser] isDirty]) {
		// this must be a new user
		[[PFUser currentUser] save];
		[self getArtists:[self sampleArtists]];
	}
	
	
    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
	[query whereKey:@"favByUsers" containsAllObjectsInArray:@[[PFUser currentUser]]];
	
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
	
    [query orderByAscending:self.textKey];
	
    return query;
}



// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
	static NSString *CellIdentifier = @"FavArtist";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
	
    // Configure the cell
    cell.textLabel.text = [object objectForKey:self.textKey];
    cell.detailTextLabel.text = [self stringForNumberOfAlbums:(NSNumber *)[object objectForKey:@"totalAlbums"]];
	
	// get images, ordered big to small
	NSArray *images = [object objectForKey:@"images"];
	
	if (images.count != 0) {
		// round down, this is only a thumbnail
		int middle = (int)(images.count / 2 - ((images.count % 2) / 2));
		
//		[cell.imageView setImageWithURL:[NSURL URLWithString:images[middle]]
//					   placeholderImage:[UIImage imageNamed:@"image.png"]];
//		
//		cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
//		//cell.imageView.contentMode = UIViewContentModeScaleToFill;
//		
//		cell.imageView.clipsToBounds=YES;
		
		
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:images[middle]]];
		[request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
		
		__weak typeof(cell) weakCell = cell;
		[cell.imageView setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"image.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			
			// resize the image - http://stackoverflow.com/questions/17675930/loading-image-with-afnetworking-resizing
			UIImage *newImage = [self resizeImage:image withWidth:weakCell.imageView.bounds.size.width withHeight:weakCell.imageView.bounds.size.height];
			
			dispatch_async(dispatch_get_main_queue(), ^{
				weakCell.imageView.image = newImage;
			});

		} failure:nil];
	}
	
    return cell;
}

- (UIImage*)resizeImage:(UIImage*)image withWidth:(int)width withHeight:(int)height
{
    CGSize newSize = CGSizeMake(width, height);
    float widthRatio = newSize.width/image.size.width;
    float heightRatio = newSize.height/image.size.height;
	
    if(widthRatio > heightRatio)
    {
        newSize=CGSizeMake(image.size.width*heightRatio,image.size.height*heightRatio);
    }
    else
    {
        newSize=CGSizeMake(image.size.width*widthRatio,image.size.height*widthRatio);
    }
	
	
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
    return newImage;
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
 
 // The cell should show a spinner and load more data automatically
 
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
 
 cell.selectionStyle = UITableViewCellSelectionStyleNone;
 cell.textLabel.text = @"Load more...";
 
 return cell;
 }
 */

#pragma mark - Serach and create Artists

- (void)getArtists:(NSArray *)artists
{
	
	NSMutableArray *queries = [NSMutableArray array];
	for (NSString *artist in artists) {
		PFQuery *query = [PFQuery queryWithClassName:@"Artist"];
		[query whereKey:@"name" equalTo:artist];
		[queries addObject:query];
	}
	
	PFQuery *orQuery = [PFQuery orQueryWithSubqueries:queries];
	
	[orQuery findObjectsInBackgroundWithBlock:^(NSArray *artists, NSError *error) {
		if (!error) {
			if (artists.count > 0) {
				// the current implementation never creates additional artists if you match a subset
				// also we only get exact matched on the artist name -> need to call corrections
				for (PFObject *artist in artists) {
					NSLog(@"Found %@", [artist objectForKey:@"name"]);
					// add yourself to favByUsers
					[artist addObject:[PFUser currentUser] forKey:@"favByUsers"];
					[artist saveInBackground];
				}
				// some callback if all is completed to reload tableView would be good
				
			} else {
				[self createArtists:artists];
			}
			//[self deleteArtists:self.artists];
			//[self getArtists:[self sampleArtists]];
			
		} else {
			NSLog(@"%@", error);
		}
	}];
}

- (void)deleteArtists:(NSArray *)artists
{
	for (PFObject *artist in artists) {
		[artist delete];
	}
}

- (NSArray *)createArtists:(NSArray *)artists
{
	NSMutableArray *newArtists = [NSMutableArray array];
	
	for (NSString *artist in artists) {
		// Create a new Artist object and create relationship with PFUser
		PFObject *newArtist = [PFObject objectWithClassName:@"Artist"];
		[newArtist setObject:artist	forKey:@"name"];
		[newArtist setObject:@[[PFUser currentUser]] forKey:@"favByUsers"]; // One-to-Many relationship created here!
		
		// Allow public write access (other users need to modify the Artist when they favorite it)
		PFACL *artistACL = [PFACL ACL];
		[artistACL setPublicReadAccess:YES];
		[artistACL setPublicWriteAccess:YES];
		[newArtist setACL:artistACL];
		
		// Cache it
		[newArtists addObject:newArtist];
		
		// Save new Artist object in Parse
		[newArtist saveInBackground];
		
		// DEBUG
		// change number of total Albums and save again
		//[newArtist setObject:@2 forKey:@"totalAlbums"];
		//[newArtist save];
	}
	return newArtists;
}


#pragma mark - Testing

- (NSArray *)sampleArtists
{
	static NSArray *sampleArtists;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		//sampleArtists = @[@"Beatles", @"AC/DC", @"Pink Floid", @"Guns 'n roses"];
		//sampleArtists = @[@"Deadmouse"];
		sampleArtists = @[
						  @"The Beatles", @"Air", @"Pink Floid", @"Rammstein", @"Bloodhound Gang",
						  @"Ancien Régime", @"Genius/GZA ", @"Belle & Sebastian", @"Björk",
						  @"Ugress", @"ADELE", @"The Asteroids Galaxy Tour", @"Bar 9",
						  @"Baskerville", @"Beastie Boys", @"Bee Gees", @"Bit Shifter",
						  @"Bomfunk MC's", @"C-Mon & Kypski", @"The Cardigans", @"Carly Commando",
						  @"Caro Emerald", @"Coldplay", @"Coolio", @"Cypress Hill",
						  @"David Bowie", @"Dukes of Stratosphear", @"[dunkelbunt]",
						  @"Eminem", @"Enigma", @"Deadmouse"
						  ];
		
		
	});
	return sampleArtists;
}

@end
