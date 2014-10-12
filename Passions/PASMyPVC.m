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

@end

@implementation PASMyPVC

#pragma mark - Init

- (void)awakeFromNib
{
	[super awakeFromNib];

	// init and add the page view controllers view controllers
	self.viewControllers = @[[self _viewControllerAtIndex:0], [self _viewControllerAtIndex:1]];
}

#pragma mark - View Lifecycle

- (void)loadView
{
	[super loadView];
	
	UIToolbar *tb1 = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 20, 320, 44)];
	[self.view addSubview:tb1];
	
	UIToolbar *tb2 = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 64, 320, 44)];
	[self.view addSubview:tb2];
	
	if (!self.containerView) {
		UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(0, 108, 320, 460)];
		myView.backgroundColor = [UIColor blueColor];
		[self.view addSubview:myView];
		self.containerView = myView;
	}
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
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

@end
