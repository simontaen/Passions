//
//  PASMyPVC.m
//  Passions
//
//  Created by Simon Tännler on 12/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASMyPVC.h"
#import "PASAddFromSamplesTVC.h"
#import "PASAddFromMusicTVC.h"

@interface PASMyPVC ()
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIToolbar *segmentbar;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation PASMyPVC

#pragma mark - Accessors

- (void)setFavArtists:(NSMutableArray *)favArtists
{
	for (PASAddFromSamplesTVC *vc in self.viewControllers) {
		vc.favArtists = favArtists;
	}
}

- (void)setTitle:(NSString *)title
{
	[super setTitle:title];
	self.titleLabel.text = title;
}

#pragma mark - Init

- (void)awakeFromNib
{
	[super awakeFromNib];

	// init and add the page view controllers view controllers
	self.viewControllers = @[[self _viewControllerAtIndex:0], [self _viewControllerAtIndex:1]];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	UIBarButtonItem *lbbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
																		  target:self
																		  action:@selector(doneButtonHandler:)];
	UILabel *title = [[UILabel alloc] init];
	title.text = self.title;
	UIBarButtonItem *mbbi = [[UIBarButtonItem alloc] initWithCustomView:title];
	self.titleLabel = title;

	UIBarButtonItem *rbbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																		  target:self
																		  action:@selector(doneButtonHandler:)];
	UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			   target:nil action:nil];
	// add the navigation item
	self.toolbar.items = @[lbbi, flexSpace, mbbi, flexSpace, rbbi];
	
	// DEBUG
	self.view.backgroundColor = [UIColor greenColor];
}

- (PASAddFromSamplesTVC *)_viewControllerAtIndex:(NSUInteger)index
{
	static PASAddFromSamplesTVC *addFromSamplesTVC;
	static PASAddFromMusicTVC *addFromMusicTVC;
	
	if (!addFromMusicTVC && !addFromMusicTVC) {
		addFromSamplesTVC = [[PASAddFromSamplesTVC alloc] initWithStyle:UITableViewStylePlain];
		addFromMusicTVC = [[PASAddFromMusicTVC alloc] initWithStyle:UITableViewStylePlain];
	}
	
	PASAddFromSamplesTVC *addArtistsTVC;
	switch (index) {
		case 0:
			if ([[UIDevice currentDevice].model containsString:@"Simulator"]) {
				addArtistsTVC = addFromSamplesTVC;
			} else {
				addArtistsTVC = addFromMusicTVC;
			}
			
			break;
			
		case 1:
			if ([[UIDevice currentDevice].model containsString:@"Simulator"]) {
				addArtistsTVC = addFromMusicTVC;
			} else {
				addArtistsTVC = addFromSamplesTVC;
			}
			break;
			
		default:
			addArtistsTVC = nil;
	}
	
	return addArtistsTVC;
}

#pragma mark - Navigation

- (IBAction)doneButtonHandler:(UIBarButtonItem *)sender
{
	PASAddFromSamplesTVC *dissapearingTVC = ((PASAddFromSamplesTVC*) self.selectedViewController);
	if ([self.myDelegate respondsToSelector:@selector(viewController:didEditArtists:)]) {
		[self.myDelegate viewController:dissapearingTVC didEditArtists:[dissapearingTVC didEditArtists]];
	}
}

@end
