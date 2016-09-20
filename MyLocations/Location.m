//
//  Location.m
//  MyLocations
//
//  Created by HNF's wife on 16/9/17.
//  Copyright © 2016年 huangningfa@163.com. All rights reserved.
//

#import "Location.h"

@interface Location ()

@end

@implementation Location

// Insert code here to add functionality to your managed object subclass

- (CLLocationCoordinate2D)coordinate {
    return CLLocationCoordinate2DMake(self.latitude, self.longitude);
}

- (NSString *)title {
    if (self.locationDescription && self.locationDescription.length != 0) {
        return self.locationDescription;
    }else {
        return @"(No Description)";
    }
}

- (NSString *)subtitle {
    return self.category;
}

- (BOOL)hasPhoto {
    return self.photoID != nil;
}

- (NSString *)photoPath {
    NSString *fileName = [NSString stringWithFormat:@"Photo-%ld.jpg", self.photoID.integerValue];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [documentPath stringByAppendingPathComponent:fileName];
}

- (UIImage *)photoImage {
    return [UIImage imageWithContentsOfFile:[self photoPath]];
}

- (void)removePhotoFile {
    if ([self hasPhoto]) {
        NSString *path = [self photoPath];
        NSFileManager *manager = [NSFileManager defaultManager];
        if ([manager fileExistsAtPath:path]) {
            NSError *error;
            [manager removeItemAtPath:path error:&error];
            if (error) {
                NSLog(@"%@", error);
            }
        }
    }
}

+ (NSInteger)nextPhotoID {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger photoID = [userDefaults integerForKey:@"PhotoID"];
    [userDefaults setInteger:photoID + 1 forKey:@"PhotoID"];
    [userDefaults synchronize];
    return photoID;
}


@end
