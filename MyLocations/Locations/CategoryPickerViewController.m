//
//  CategoryPickerViewController.m
//  MyLocations
//
//  Created by HNF's wife on 16/9/17.
//  Copyright © 2016年 huangningfa@163.com. All rights reserved.
//

#import "CategoryPickerViewController.h"

@interface CategoryPickerViewController ()

@property (nonatomic, strong) NSArray *categories;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation CategoryPickerViewController

- (NSArray *)categories {
    if (!_categories) {
        _categories = @[@"No Category",
                        @"Apple Store",
                        @"Bar",
                        @"Bookstore",
                        @"Club",
                        @"Grocery Store",
                        @"Historic Building",
                        @"House",
                        @"Icecream Vendor",
                        @"Landmark",
                        @"Park"];
    }
    return _categories;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.categories enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:self.selectedCategoryName]) {
            self.selectedIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            *stop = YES;
        }
    }];
    
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorColor = [[UIColor alloc] initWithWhite:1.0 alpha:0.2];
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PickedCategory"]) {
        UITableViewCell *cell = (UITableViewCell *)sender;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (indexPath) {
            self.selectedCategoryName = self.categories[indexPath.row];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.categories.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.categories[indexPath.row];
    if ([self.categories[indexPath.row] isEqualToString:self.selectedCategoryName]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row != self.selectedIndexPath.row) {
        UITableViewCell *newCell = [self.tableView cellForRowAtIndexPath:indexPath];
        if (newCell) {
            newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        UITableViewCell *oldCell = [self.tableView cellForRowAtIndexPath:self.selectedIndexPath];
        if (oldCell) {
            oldCell.accessoryType = UITableViewCellAccessoryNone;
        }
        self.selectedIndexPath = indexPath;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor blackColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.highlightedTextColor = cell.textLabel.textColor;
    
    UIView *selectionView = [[UIView alloc] initWithFrame:CGRectZero];
    selectionView.backgroundColor = [[UIColor alloc] initWithWhite:1.0 alpha:0.2];
    cell.selectedBackgroundView = selectionView;
}

@end
