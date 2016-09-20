//
//  MapViewController.m
//  MyLocations
//
//  Created by HNF's wife on 16/9/18.
//  Copyright © 2016年 huangningfa@163.com. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>
#import "Location.h"
#import "LocationDetailsViewController.h"

@interface MapViewController () <MKMapViewDelegate, UINavigationBarDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) NSArray *locations;

@end

@implementation MapViewController

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    _managedObjectContext = managedObjectContext;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextObjectsDidChangeNotification object:_managedObjectContext queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        if ([self isViewLoaded]) {
            [self updateLocations];
        }
    }];
}

- (void)updateLocations {
    [self.mapView removeAnnotations:self.locations];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
    fetchRequest.entity = entity;
    
    NSError *error;
    self.locations = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    
    [self.mapView addAnnotations:self.locations];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self updateLocations];
    if (self.locations) {
        [self showLocations];
    }
}

- (IBAction)showUser:(id)sender {
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 1000, 1000);
    [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
}

- (IBAction)showLocations {
    MKCoordinateRegion region = [self regionForAnnotations:self.locations];
    [self.mapView setRegion:region animated:YES];
}

- (MKCoordinateRegion)regionForAnnotations:(NSArray *)annotations {
    MKCoordinateRegion region;
    Location *location = nil;
    CLLocationCoordinate2D topLeftCoord = CLLocationCoordinate2DMake(-90, 180);
    CLLocationCoordinate2D bottomRightCoord = CLLocationCoordinate2DMake(90, -180);
    CLLocationCoordinate2D center;
    CGFloat extraSpace = 1.1;
    MKCoordinateSpan span;
    switch (annotations.count) {
        case 0:
            region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, 1000, 1000);
            break;
        case 1:
            location = annotations[0];
            region = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000, 1000);
            break;
        default:
            for (Location *location in annotations) {
                topLeftCoord.latitude = MAX(topLeftCoord.latitude, location.coordinate.latitude);
                topLeftCoord.longitude = MIN(topLeftCoord.longitude, location.coordinate.longitude);
                bottomRightCoord.latitude = MIN(bottomRightCoord.latitude, location.coordinate.latitude);
                bottomRightCoord.longitude = MAX(bottomRightCoord.longitude, location.coordinate.longitude);
            }
            center = CLLocationCoordinate2DMake(topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2, topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2);
            span = MKCoordinateSpanMake(fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace, fabs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace);
            region = MKCoordinateRegionMake(center, span);
            break;
            
    }
    return [self.mapView regionThatFits:region];
}

- (void)showLocationDetails:(UIButton *)sender {
    [self performSegueWithIdentifier:@"EditLocation" sender:sender];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EditLocation"]) {
        UINavigationController *nav = segue.destinationViewController;
        LocationDetailsViewController *controller = (LocationDetailsViewController *)nav.topViewController;
        controller.managedObjectContext = self.managedObjectContext;
        
        UIButton *button = (UIButton *)sender;
        Location *location = self.locations[button.tag];
        controller.locationToEdit = location;
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    NSString *identifier = @"Location";
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (annotationView == nil) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        annotationView.animatesDrop = NO;
        annotationView.pinTintColor = [UIColor colorWithRed:0.32 green:0.82 blue:0.4 alpha:1];
        annotationView.tintColor = [[UIColor alloc] initWithWhite:0.0 alpha:0.5];
        
        UIButton *rightButton = [UIButton buttonWithType:(UIButtonTypeDetailDisclosure)];
        [rightButton addTarget:self action:@selector(showLocationDetails:) forControlEvents:(UIControlEventTouchUpInside)];
        annotationView.rightCalloutAccessoryView = rightButton;
    }else {
        annotationView.annotation = annotation;
    }
    
    UIButton *button = (UIButton *)annotationView.rightCalloutAccessoryView;
    NSInteger index = [self.locations indexOfObject:annotation];
    button.tag = index;
    
    return annotationView;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
