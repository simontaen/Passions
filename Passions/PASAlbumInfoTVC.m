//
//  PASAlbumInfoTVC.m
//  Passions
//
//  Created by Simon Tännler on 08/11/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASAlbumInfoTVC.h"
#import "PASArtworkTVCell.h"
#import "PASAlbumInfoTVCell.h"
#import "AJSITunesAPI.h"
#import "PASPageViewController.h"

@interface PASAlbumInfoTVC ()
@property (nonatomic, strong) NSArray *tracks; // AJSITunesResult
@end

@implementation PASAlbumInfoTVC

static NSString * const kCellIdentifier = @"TrackCell";
static NSInteger const kAddCells = 2;

#pragma mark - Accessors

- (void)setAlbum:(PASAlbum *)album
{
	if (album != _album) {
		_album = album;
		self.tracks = [NSArray array];
		
		// enable only with a MBProgressHUD
//		[[AJSITunesClient sharedClient] lookupWithId:[album.iTunesId stringValue] entityType:@"song" country:nil limit:200 completion:^(NSArray *results, NSError *error) {
//			NSMutableArray *tracks = [results mutableCopy];
//			[tracks removeObject:[results firstObject]];
//			self.tracks = tracks;
//			dispatch_async(dispatch_get_main_queue(), ^{
//				[self.tableView reloadData];
//			});
//		}];
	}
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// register the custom cell
	[self.tableView registerNib:[UINib nibWithNibName:[PASArtworkTVCell reuseIdentifier] bundle:nil]
		 forCellReuseIdentifier:[PASArtworkTVCell reuseIdentifier]];
	[self.tableView registerNib:[UINib nibWithNibName:[PASAlbumInfoTVCell reuseIdentifier] bundle:nil]
		 forCellReuseIdentifier:[PASAlbumInfoTVCell reuseIdentifier]];
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
	
	// TableView Properties
	self.tableView.allowsSelection = NO;
	self.tableView.scrollEnabled = NO;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

	// Configure navigationController
	self.title = @"Album Details";

	UIBarButtonItem *rbbi = [[UIBarButtonItem alloc] initWithTitle:@"iTunes"
															 style:UIBarButtonItemStylePlain
															target:self
															action:@selector(iTunesButtonTapped:)];
	self.navigationItem.rightBarButtonItem = rbbi;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// Configure navigationController
	// Needs to be in viewWillAppear to make it work with other VC's
	self.navigationController.navigationBarHidden = NO;
	self.pageViewController.pageControlHidden = YES;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 0) {
		return self.tableView.frame.size.width;
	} else if (indexPath.row == 1) {
		return 67;
	} else {
		return 45;
	}
}

#pragma mark - UITableViewDataSource required

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.tracks.count + kAddCells;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 0) {
		PASArtworkTVCell *cell = [tableView dequeueReusableCellWithIdentifier:[PASArtworkTVCell reuseIdentifier] forIndexPath:indexPath];
		
		[cell showAlbum:self.album];
		
		return cell;
		
	} else if (indexPath.row == 1) {
		PASAlbumInfoTVCell *cell = [tableView dequeueReusableCellWithIdentifier:[PASAlbumInfoTVCell reuseIdentifier] forIndexPath:indexPath];
		
		cell.mainText.text = self.album.name;
		cell.detailText.text = [NSString stringWithFormat:@"by %@, %@", self.album.artistName, [self _stringifiedTracks]];
		
		return cell;
		
	} else {
		NSIndexPath *newIdxPath = [self _newIdxPath:indexPath];
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:newIdxPath];
		
		AJSITunesResult *track = self.tracks[newIdxPath.row];
		
		cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", track.trackNumber, track.title];
		
		return cell;
	}
}

#pragma mark - UITableViewDataSource Editing

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

#pragma mark - Redirecting to External Sites

- (IBAction)iTunesButtonTapped:(UIBarButtonItem *)sender
{
	NSURL *url = [self.album iTunesAttributedUrl];
	[PFAnalytics trackEventInBackground:@"urlOpen"
							 dimensions:@{ @"provider" : @"iTunes",
										   @"url" : [url absoluteString] }
								  block:nil];
	[[UIApplication sharedApplication] openURL:url];
}

#pragma mark - Private Methods

- (NSString *)_stringifiedTracks
{
	NSNumber *tracksNumber = self.album.trackCount;
	if (!tracksNumber) {
		return @"(Tracks unavailable)";
	} else {
		NSUInteger tracks = [tracksNumber integerValue];
		if (tracks == 1) {
			return [NSString stringWithFormat:@"%tu Track", tracks];
		} else {
			return [NSString stringWithFormat:@"%tu Tracks", tracks];
		}
	}
}

- (NSIndexPath *)_newIdxPath:(NSIndexPath *)idxPath
{
	return [NSIndexPath indexPathForRow:idxPath.row - kAddCells inSection:idxPath.section];
}

@end
