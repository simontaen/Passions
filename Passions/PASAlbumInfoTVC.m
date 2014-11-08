//
//  PASAlbumInfoTVC.m
//  Passions
//
//  Created by Simon Tännler on 08/11/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASAlbumInfoTVC.h"
#import "PASArtworkTVCell.h"
#import "AJSITunesAPI.h"

@interface PASAlbumInfoTVC ()
@property (nonatomic, strong) NSArray *tracks; // AJSITunesResult
@end

@implementation PASAlbumInfoTVC

static NSString * const kCellIdentifier = @"TrackCell";
static NSInteger const kAddCells = 1;

#pragma mark - Accessors

- (void)setAlbum:(PASAlbum *)album
{
	if (album != _album) {
		_album = album;
		self.tracks = [NSArray array];
		
		[[AJSITunesClient sharedClient] lookupWithId:[album.iTunesId stringValue] entityType:@"song" country:nil limit:200 completion:^(NSArray *results, NSError *error) {
			NSMutableArray *tracks = [results mutableCopy];
			[tracks removeObject:[results firstObject]];
			self.tracks = tracks;
			dispatch_async(dispatch_get_main_queue(), ^{
				[self.tableView reloadData];
			});
		}];
	}
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// register the custom cell
	[self.tableView registerNib:[UINib nibWithNibName:[PASArtworkTVCell reuseIdentifier] bundle:nil]
		 forCellReuseIdentifier:[PASArtworkTVCell reuseIdentifier]];
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
	
	// TableView Properties
	self.tableView.allowsSelection = NO;

	UIBarButtonItem *rbbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																		  target:self
																		  action:@selector(doneButtonTapped:)];
	self.navigationItem.rightBarButtonItem = rbbi;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	// Configure navigationController
	self.title = self.album.name;
	self.navigationController.navigationBarHidden = NO;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 0) {
		return self.tableView.frame.size.width;
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

#pragma mark - Navigation

- (IBAction)doneButtonTapped:(UIBarButtonItem *)sender
{
	[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private Methods

- (NSIndexPath *)_newIdxPath:(NSIndexPath *)idxPath
{
	return [NSIndexPath indexPathForRow:idxPath.row - kAddCells inSection:idxPath.section];
}

@end
