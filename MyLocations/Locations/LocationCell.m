//
//  LocationCell.m
//  MyLocations
//
//  Created by HNF's wife on 16/9/18.
//  Copyright © 2016年 huangningfa@163.com. All rights reserved.
//

#import "LocationCell.h"
#import "Location.h"
#import "UIImage+Resize.h"

@implementation LocationCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor blackColor];
    self.descriptionLabel.textColor = [UIColor whiteColor];
    self.descriptionLabel.highlightedTextColor = self.descriptionLabel.textColor;
    self.addressLabel.textColor = [[UIColor alloc] initWithWhite:1.0 alpha:0.4];
    self.addressLabel.highlightedTextColor = self.addressLabel.textColor;
    
    UIView *selectionView = [[UIView alloc] initWithFrame:CGRectZero];
    selectionView.backgroundColor = [[UIColor alloc] initWithWhite:1.0 alpha:0.2];
    self.selectedBackgroundView = selectionView;
    
    self.photoImageView.layer.cornerRadius = self.photoImageView.bounds.size.width / 2;
    self.photoImageView.clipsToBounds = YES;
    self.separatorInset = UIEdgeInsetsMake(0, 82, 0, 0);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configureForLocation:(Location *)location {
    if (location.locationDescription == nil || location.locationDescription.length == 0) {
        self.descriptionLabel.text = @"(No Description)";
    }else {
        self.descriptionLabel.text = location.locationDescription;
    }
    
    if (location.placemark) {
        NSMutableString *text = [NSMutableString string];
        [text appendString:location.placemark.subThoroughfare];
        [text appendFormat:@" %@", location.placemark.thoroughfare];
        [text appendFormat:@", %@", location.placemark.locality];
        self.addressLabel.text = text;
    }else {
        self.addressLabel.text = [NSString stringWithFormat:@"Lat: %.8f, Long: %.8f", location.latitude, location.longitude];
    }
    
    self.photoImageView.image = [self imageForLocation:location];
}

- (UIImage *)imageForLocation:(Location *)location {
    if (location.hasPhoto) {
        UIImage *image = location.photoImage;
        return [image resizedImageWithBounds:CGSizeMake(52, 52)];
    }
    
    return [UIImage imageNamed:@"No Photo"];
}

@end
