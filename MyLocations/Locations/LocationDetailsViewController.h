//
//  LocationDetailsViewController.h
//  MyLocations
//
//  Created by HNF's wife on 16/9/16.
//  Copyright © 2016年 huangningfa@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@class Location;
@interface LocationDetailsViewController : UITableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, strong) CLPlacemark *placemark;

@property (nonatomic, strong) Location *locationToEdit;

@end
