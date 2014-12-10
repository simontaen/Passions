//
//  QueryCollectionViewController.m
//  CPFQueryViewController
//
//  Created by Hampus Nilsson on 10/6/12.
//  Copyright (c) 2012 FreedomCard. All rights reserved.
//

#import "CPFQueryCollectionViewController.h"
#import <Parse/Parse.h>
#import "GBVersiontracking.h"
#import "MBProgressHUD.h"
#import "PASPageViewController.h"

// Define our own version of DDLogInfo(...) which will only send its input to the
// output if we are in debug mode and a assertion logger which will cause an
// assertion if we are in debug mode and a in non-debug mode it will output the
// assertion via DDLogInfo(...)
#ifdef DEBUG
	#define ALog(...) [[NSAssertionHandler currentHandler] handleFailureInFunction:@(__PRETTY_FUNCTION__) file:@(__FILE__) lineNumber:__LINE__ description:__VA_ARGS__]
#else // !DEBUG
	#define ALog(...) DDLogInfo(@"*** %s: %@", __PRETTY_FUNCTION__, [NSString stringWithFormat:__VA_ARGS__])
#endif // DEBUG

@interface CPFQueryCollectionViewController()
@property (nonatomic, assign) NSUInteger expectedObjects;
@property (nonatomic, readwrite) BOOL isLoading;
@property (nonatomic, strong) MBProgressHUD *loadingHud;
@end

@implementation CPFQueryCollectionViewController

// Private method called from all initializers
- (void)_initDefaults
{
    _loadingViewEnabled = YES;
    _paginationEnabled = NO;
    _objectsPerPage = 15;
    _objects = [NSArray new];
}

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self)
        [self _initDefaults];
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
        [self _initDefaults];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
        [self _initDefaults];
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
        [self _initDefaults];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Perform the first query
	[self _performQuery:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if (!self.isLoading && !self.objects) {
		// objects have been cleaned
		self.objects = [NSArray new];
		[self _performQuery:NO];
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// clear objects when we're not loading and not on screen
	if (!self.isLoading && self.pageViewController.selectedViewController != self.parentViewController) {
		// view is not on screen, viewWillAppear is definitely going to be called
		self.objects = nil;
	}
}

#pragma mark - Accessors

- (void)setIsLoading:(BOOL)isLoading
{
	if (_isLoading != isLoading) {
		_isLoading = isLoading;
		if (self.loadingViewEnabled) {
			if (isLoading) {
				dispatch_async(dispatch_get_main_queue(), ^{
					if (self.loadingHud) {
						[self.loadingHud hide:YES];
						self.loadingHud = nil;
					}
					// turn on, isLoading is only modified in _performQuery,
					// which is only called when view is loaded
					self.loadingHud = [MBProgressHUD showHUDAddedTo:self.parentViewController.view animated:YES];
					self.loadingHud.labelText = @"Loading albums";
				});
			} else if (self.loadingHud) {
				dispatch_async(dispatch_get_main_queue(), ^{
					if (self.loadingHud) {
						[self.loadingHud hide:YES];
						self.loadingHud = nil;
					}
				});
			}
		}
	}
}

#pragma mark - Parse.com logic

// Private method, called when a query should be performed
- (void)_performQuery:(BOOL)refreshing
{
	// Enter the loading state
	self.isLoading = YES;

	PFQuery *query = self.queryForCollection;
	
	if (query) {
		[self objectsWillLoad];
		
		if (self.paginationEnabled) {
			// we need to know how many objects there are to prevent
			// constant refreshing when scrolling past the end of the view
			// without getting new objects
			PFQuery *countingQuery = self.queryForCollection;
			if (countingQuery) {
				// using a new query just in case
				[countingQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
					self.expectedObjects = number;
				}];
			}
			
			[query setLimit:self.objectsPerPage];
			//fetching the next page of objects
			if (refreshing) {
				[query setSkip:self.objects.count];
			}
		}
		
		[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
			if (error) {
				DDLogError([error description]);
				self.objects = [NSArray new];
			} else {
				if (self.paginationEnabled && refreshing) {
					//add a new page of objects
					self.objects = [objects arrayByAddingObjectsFromArray:self.objects];
				} else {
					self.objects = objects;
				}
			}
			
			[self objectsDidLoad:error];
			self.isLoading = NO;
		}];
		
	} else {
		self.isLoading = NO;
	}
}

- (void)loadObjects
{
	if (!self.isLoading) [self _performQuery:NO];
}

- (void)_refreshObjects
{
	if (!self.isLoading) [self _performQuery:YES];
}

- (void)objectsWillLoad
{
	// NOP
}

- (void)objectsDidLoad:(NSError *)error
{
    [self.collectionView reloadData];
}

- (PFQuery *)queryForCollection
{
    ALog(@"Overload this in your subclass to provide a Parse Query");
    return nil;
}

- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 0)
    {
        // If you have overloaded `numberOfSectionsInCollectionView` but not `objectAtIndexPath` this might happen
        ALog(@"All objects should be contained in one single section.");
        return nil;
    }
    
    return [self.objects objectAtIndex:indexPath.row];
}

#pragma mark - Collection View Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    // No sections displayed while loading
	if (self.isLoading) {
		return 0;
	}
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSAssert(section == 0, @"QueryCollectionView should only contain one section, overload this method in a subclass.");
    return self.objects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object
{
    ALog(@"You should overload this in your subclass.");
    return nil;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Just fetch from the implementation that receives an object as a parameter
    return [self collectionView:collectionView cellForItemAtIndexPath:indexPath object:[self objectAtIndexPath:indexPath]];
}

#pragma mark - Scroll View delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //if the scrollView has reached the bottom fetch the next page of objects
    float bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height;
    if (bottomEdge >= scrollView.contentSize.height && [self hasMoreObjects]) {
		[self _refreshObjects];
    }
}

#pragma mark - Private Methods

- (BOOL)hasMoreObjects
{
	return self.paginationEnabled && self.objects.count < self.expectedObjects;
}

@end
