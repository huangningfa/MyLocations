//
//  Location.h
//  MyLocations
//
//  Created by HNF's wife on 16/9/17.
//  Copyright © 2016年 huangningfa@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MapKit/MapKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Location : NSManagedObject <MKAnnotation>

// Insert code here to declare functionality of your managed object subclass

@property (nonatomic, assign, readonly) BOOL hasPhoto;

@property (nonatomic, strong, readonly) UIImage *photoImage;

@property (nonatomic, copy, readonly) NSString *photoPath;


- (void)removePhotoFile;

+ (NSInteger)nextPhotoID;

@end

NS_ASSUME_NONNULL_END

#import "Location+CoreDataProperties.h"
