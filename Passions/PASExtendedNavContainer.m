//
//  PASExtendedNavContainer.m
//  Passions
//
//  Created by Simon Tännler on 12/10/14.
//  Copyright (c) 2014 edgeguard. All rights reserved.
//

#import "PASExtendedNavContainer.h"
#import "PASAddFromSamplesTVC.h"
#import "PASAddFromMusicTVC.h"

CGFloat const kSegmentBarHeight = 40;

@interface PASExtendedNavContainer ()

@property (nonatomic, strong) PASAddFromSamplesTVC *addTvc;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIToolbar *segmentBar;
@end

@implementation PASExtendedNavContainer

#pragma mark - Init

- (instancetype)initWithIndex:(NSUInteger)index
{
	self = [super initWithNibName:nil bundle:nil];
	if (!self) return nil;
	_addTvc = [self _viewControllerAtIndex:index];
	return self;
}

- (PASAddFromSamplesTVC *)_viewControllerAtIndex:(NSUInteger)index
{
	BOOL isSimulator = [[UIDevice currentDevice].model containsString:@"Simulator"];
	
	if ((isSimulator && index == 0) ||
		(!isSimulator && index > 0)) {
		return [[PASAddFromSamplesTVC alloc] initWithNibName:nil bundle:nil];
	} else {
		return [[PASAddFromMusicTVC alloc] initWithNibName:nil bundle:nil];
	}
}

#pragma mark - Accessors

- (NSString *)title
{
	// this is a container, forwared the call
	return self.addTvc.title;
}

#pragma mark - View Lifecycle

//- (void)loadView
//{
//	[super loadView];
//	
//	self.view = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
//	
//	CGFloat myX = self.view.bounds.origin.x;
//	CGFloat myY = self.view.bounds.origin.y;
//	CGFloat myWith = self.view.bounds.size.width;
//	CGFloat myHeight = self.view.bounds.size.height;
//	
//	UIToolbar *myBar = [[UIToolbar alloc] initWithFrame:CGRectMake(myX, myY, myWith, kSegmentBarHeight)];
//	self.segmentBar = myBar;
//	[self.view addSubview:myBar];
//	
//	UISegmentedControl *mySegCont = [[UISegmentedControl alloc] initWithItems:@[@"alphabetical", @"by playcount"]];
//	self.segmentedControl.frame = CGRectMake(16, 8, myWith - 32, kSegmentBarHeight - 14);
//	self.segmentedControl = mySegCont;
//	[self.segmentBar addSubview:mySegCont];
//	
//	UIView *myTable = [[UIView alloc] initWithFrame:CGRectMake(myX, kSegmentBarHeight, myWith, myHeight - kSegmentBarHeight)];
//	self.containerView = myTable;
//	[self.view addSubview:myTable];
//}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Setup segmentedControl
	self.segmentedControl.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
	self.segmentedControl.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
	[self.segmentedControl addTarget:self action:@selector(segmentChanged:) forControlEvents:UIControlEventValueChanged];
	
	// add the child view controller
	[self.addTvc.tableView setTranslatesAutoresizingMaskIntoConstraints:YES];
	self.addTvc.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.addTvc.tableView.frame = self.containerView.bounds;
	
	[self addChildViewController:self.addTvc];
	[self.containerView addSubview:self.addTvc.view];
	
	[self.addTvc didMoveToParentViewController:self];
}

#pragma mark - Ordering

- (IBAction)segmentChanged:(UISegmentedControl *)sender
{
	NSLog(@"Selected Segment: %ld", (long)[sender selectedSegmentIndex]);
}

@end
