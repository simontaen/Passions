//
//  PASFavArtistsTVC.m
//  Passions
//
//  Created by Simon Tännler on 03/09/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASFavArtistsTVC.h"

@interface PASFavArtistsTVC()
@property (strong, nonatomic) NSArray *artists; // PFObjects
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
	self.objectsPerPage = 5;
}

-(void)viewDidLoad
{
    [super viewDidLoad];

	//[self getArtists:[self sampleArtists]];
	
    //[PFPush sendPushMessageToChannelInBackground:@"global" withMessage:@"Hello After viewDidLoad"];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewControllerDataSource



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
//- (PFQuery *)queryForTable {
//    PFQuery *query = [PFQuery queryWithClassName:self.parseClassName];
//	
//    // If no objects are loaded in memory, we look to the cache first to fill the table
//    // and then subsequently do a query against the network.
//    if ([self.objects count] == 0) {
//        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
//    }
//	
//    [query orderByAscending:@"priority"];
//	
//    return query;
//}



// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
//	static NSString *CellIdentifier = @"FavArtist";
//	
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
//    }
//	
//    // Configure the cell
//    cell.textLabel.text = [object objectForKey:@"text"];
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"Priority: %@", [object objectForKey:@"priority"]];
//	
//    return cell;
//}


/*
 // Override if you need to change the ordering of objects in the table.
 - (PFObject *)objectAtIndex:(NSIndexPath *)indexPath {
 return [objects objectAtIndex:indexPath.row];
 }
 */

/*
 // Override to customize the look of the cell that allows the user to load the next page of objects.
 // The default implementation is a UITableViewCellStyleDefault cell with simple labels.
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
 static NSString *CellIdentifier = @"NextPage";
 
 UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
 
 if (cell == nil) {
 cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
 }
 
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
	
	[orQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (!error) {
			if (objects.count > 0) {
				// read artist from objects
				// this actually never creates additional artists if you match a subset
				self.artists = objects;
				for (PFObject *obj in objects) {
					NSLog(@"Found %@", [obj objectForKey:@"name"]);
				}
				
			} else {
				self.artists = [self createArtists:artists];
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
		[newArtist save];
		
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
		/*
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
		 */
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


#pragma mark - Navigation

/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
