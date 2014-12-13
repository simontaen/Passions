//
//  QueryCollectionViewController.h
//  CPFQueryViewController
//
//  Created by Hampus Nilsson on 10/6/12.
//  Copyright (c) 2012 FreedomCard. All rights reserved.
//

@import UIKit;
#import <Parse/Parse.h>
#import "MBProgressHUD.h"

@interface CPFQueryCollectionViewController : UICollectionViewController <UICollectionViewDataSource>

/**
 * Should the collection view show an activity indicator while a query is in progress?
 */
@property (nonatomic, assign) BOOL loadingViewEnabled;

/**
 * Should the collection use pagination?
 */
@property (nonatomic, assign) BOOL paginationEnabled;

/**
 * The number of objects to show per page
 */
@property (nonatomic, assign) NSInteger objectsPerPage;

/**
 * Returns the fetched array of objects, or an empty array if nothing has been fetched.
 */
@property (nonatomic, strong) NSArray *objects;

/**
 * The progress hud
 */
@property (nonatomic, strong, readonly) MBProgressHUD *loadingHud;

/**
 * The query to use to fetch the objects.
 * You can configure caching behavior etc. as you see fit
 */
-(PFQuery *)queryForCollection;

/**
 * Is the query currently loading (being fetched)?
 */
-(BOOL)isLoading;

/**
 * Loads first page of objects.
 */
- (void)loadObjects;

/**
 * Called when a new query has been issued.
 * Overload this in a subclass if necessary. You must call [super] to make the view behave properly.
 */
- (void)objectsWillLoad;

/**
 * Called when a query finishes.
 * Overload this in a subclass if necessary. You must call [super] to make the view behave properly.
 */
- (void)objectsDidLoad:(NSError *)error;

/**
 * Get the PFObjects associated with this index path
 * Overload this and `numberOfSectionsInCollectionView` / `numberOfItemsInSection` to subdivide the table view into section.
 * call the super implementation to fetch the actual results)
 */
- (PFObject *)objectAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Get the cell associated with an index path.
 * This version also receives the object associated with that index path. It's recommended to override this
 * instead of the usual version.
 */
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object;

@end
