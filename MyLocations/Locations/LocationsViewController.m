//
//  LocationsViewController.m
//  MyLocations
//
//  Created by HNF's wife on 16/9/16.
//  Copyright © 2016年 huangningfa@163.com. All rights reserved.
//

#import "LocationsViewController.h"
#import <CoreData/CoreData.h>
#import "LocationCell.h"
#import "LocationDetailsViewController.h"
#import "Location.h"

@interface LocationsViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation LocationsViewController

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultsController) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
        fetchRequest.entity = entity;
        
        NSSortDescriptor *sortDescriptor1 = [NSSortDescriptor sortDescriptorWithKey:@"category" ascending:YES];
        NSSortDescriptor *sortDescriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES];
        fetchRequest.sortDescriptors = @[sortDescriptor1, sortDescriptor2];
        
        fetchRequest.fetchBatchSize = 20;
        
        NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:@"category" cacheName:@"Locations"];
        fetchedResultsController.delegate = self;
        _fetchedResultsController = fetchedResultsController;
    }
    
    return _fetchedResultsController;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    _managedObjectContext = managedObjectContext;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification object:_managedObjectContext queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        if ([self isViewLoaded]) {
            [NSFetchedResultsController deleteCacheWithName:@"Locations"];
            [self performFetch];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [NSFetchedResultsController deleteCacheWithName:@"Locations"];
    [self performFetch];
    
    self.navigationItem.rightBarButtonItem = [self editButtonItem];

    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorColor = [[UIColor alloc] initWithWhite:1.0 alpha:0.2];
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
}

- (void)dealloc {
    self.fetchedResultsController.delegate = nil;
}

- (void)performFetch {
    NSError *error;
    [self.fetchedResultsController performFetch:&error];
    if (error) {
        NSLog(@"%@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MyManagedObjectContextSaveDidFailNotification" object:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EditLocation"]) {
        UINavigationController *nav = segue.destinationViewController;
        LocationDetailsViewController *controller = (LocationDetailsViewController *)nav.topViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        Location *location = [self.fetchedResultsController objectAtIndexPath:indexPath];
        controller.locationToEdit = location;
        controller.managedObjectContext = self.managedObjectContext;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDelegate

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    CGRect labelRect = CGRectMake(15, self.tableView.sectionHeaderHeight - 14, 300, 14);
    UILabel *label = [[UILabel alloc] initWithFrame:labelRect];
    label.font = [UIFont boldSystemFontOfSize:11];
    label.text = [self.tableView.dataSource tableView:self.tableView titleForHeaderInSection:section];
    label.textColor = [[UIColor alloc] initWithWhite:1.0 alpha:0.4];
    label.backgroundColor = [UIColor clearColor];
    
    CGRect separatorRect = CGRectMake(15, self.tableView.sectionHeaderHeight - 0.5, self.tableView.bounds.size.width - 15, 0.5);
    UIView *separator = [[UIView alloc] initWithFrame:separatorRect];
    separator.backgroundColor = self.tableView.separatorColor;
    
    CGRect viewRect = CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.sectionHeaderHeight);
    UIView *view = [[UIView alloc] initWithFrame:viewRect];
    view.backgroundColor = [[UIColor alloc] initWithWhite:0 alpha:0.85];
    [view addSubview:label];
    [view addSubview:separator];
    
    return view;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.fetchedResultsController.sections[section] numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return  [[self.fetchedResultsController.sections[section] name] uppercaseString];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LocationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LocationCell" forIndexPath:indexPath];
    Location *location = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [cell configureForLocation:location];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        Location *location = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [location removePhotoFile];

        [self.managedObjectContext deleteObject:location];
        NSError *error = nil;
        [self.managedObjectContext save:&error];
        if (error) {
            NSLog(@"%@", error);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MyManagedObjectContextSaveDidFailNotification" object:nil];
        }
    }
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    Location *location;
    LocationCell *cell;
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:(UITableViewRowAnimationFade)];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationFade)];
            break;
        case NSFetchedResultsChangeUpdate:
            location = [controller objectAtIndexPath:indexPath];
            cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [cell configureForLocation:location];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationFade)];
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:(UITableViewRowAnimationFade)];
            break;
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:(UITableViewRowAnimationFade)];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:(UITableViewRowAnimationFade)];
            break;
        case NSFetchedResultsChangeUpdate:
            
            break;
        case NSFetchedResultsChangeMove:
            
            break;
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
