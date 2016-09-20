//
//  Location+CoreDataProperties.h
//  MyLocations
//
//  Created by HNF's wife on 16/9/17.
//  Copyright © 2016年 huangningfa@163.com. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Location.h"
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Location (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *category;
@property (nonatomic) NSDate *date;
@property (nonatomic) double latitude;
@property (nullable, nonatomic, retain) NSString *locationDescription;
@property (nonatomic) double longitude;
@property (nullable, nonatomic) NSNumber *photoID;
@property (nullable, nonatomic, retain) CLPlacemark *placemark;

@end

NS_ASSUME_NONNULL_END
