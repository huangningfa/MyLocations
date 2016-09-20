//
//  LocationCell.h
//  MyLocations
//
//  Created by HNF's wife on 16/9/18.
//  Copyright © 2016年 huangningfa@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Location;
@interface LocationCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

- (void)configureForLocation:(Location *)location;

@end
