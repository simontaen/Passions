//
//  PASAlbumInfoTVC.m
//  Passions
//
//  Created by Simon Tännler on 08/11/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASAlbumInfoTVC.h"
#import "PASArtworkTVCell.h"

@interface PASAlbumInfoTVC ()

@end

@implementation PASAlbumInfoTVC

static NSString * const kCellIdentifier = @"TrackCell";

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
	// Return the number of rows in the section.
	return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	if (indexPath.row == 0) {
		PASArtworkTVCell *cell = [tableView dequeueReusableCellWithIdentifier:[PASArtworkTVCell reuseIdentifier] forIndexPath:indexPath];
		
		[cell showAlbum:self.album];
		
		return cell;
		
	} else {
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
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

@end
