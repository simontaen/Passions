//
//  CoreDataCollectionViewController.h
//
//  Created by Simon Tännler on 10/11/13.
//  Copyright (c) 2013 edgeguard. All rights reserved.
//
// It glues together the UICollectionView and the NSFetchedResultsController. By answering the
// questions of the CollectionView with the resources the FetchedResultsController provides.
// Inspired by CoreDataTableViewController by Stanford CS 193P, https://gist.github.com/simontea/7388377
//
// Just subclass this and set the fetchedResultsController.
// The only UICollectionViewDataSource method you'll HAVE to implement is collectionView:cellForItemAtIndexPath:.
// And you can use the NSFetchedResultsController method objectAtIndexPath: to do it.
//
// Remember that once you create an NSFetchedResultsController, you CANNOT modify its @propertys.
// If you want new fetch parameters (predicate, sorting, etc.),
//  create a NEW NSFetchedResultsController and set this class's fetchedResultsController @property again.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface CoreDataCollectionViewController : UICollectionViewController <NSFetchedResultsControllerDelegate>

// The controller (this class fetches nothing if this is not set).
// Will match a NSFetchRequest with a UITableViewController, and keep them matched.
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

// Causes the fetchedResultsController to refetch the data.
// You almost certainly never need to call this.
// The NSFetchedResultsController class observes the context
//  (so if the objects in the context change, you do not need to call performFetch
//   since the NSFetchedResultsController will notice and update the table automatically).
// This will also automatically be called if you change the fetchedResultsController @property.
- (void)performFetch;

// Set to YES to get some debugging output in the console.
@property BOOL debug;

@end
