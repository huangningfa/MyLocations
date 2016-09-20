//
//  CurrentLocationViewController.m
//  MyLocations
//
//  Created by HNF's wife on 16/9/14.
//  Copyright © 2016年 huangningfa@163.com. All rights reserved.
//

#import "CurrentLocationViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "LocationDetailsViewController.h"

@interface CurrentLocationViewController () <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *tagButton;
@property (weak, nonatomic) IBOutlet UIButton *getButton;
@property (weak, nonatomic) IBOutlet UILabel *latitudeTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeTextLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (nonatomic, strong) UIButton *logoButton;

@end

@implementation CurrentLocationViewController{
    CLLocationManager *_locationManager;
    CLLocation *_location;
    BOOL _updatingLocation;
    NSError *_lastLocationError;
    
    CLGeocoder *_geocoder;
    CLPlacemark *_placemark;
    BOOL _performingReverseGeocoding;
    NSError *_lastGeocodingError;
    NSTimer *_timer;
    
    BOOL _logoVisible;
    
    SystemSoundID _soundID;
}

- (UIButton *)logoButton {
    if (!_logoButton) {
        UIButton *button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [button setBackgroundImage:[UIImage imageNamed:@"Logo"] forState:(UIControlStateNormal)];
        [button sizeToFit];
        [button addTarget:self action:@selector(getLocation) forControlEvents:(UIControlEventTouchUpInside)];
        CGFloat centerX = CGRectGetMidX(self.view.bounds);
        CGFloat centerY = 220;
        button.center = CGPointMake(centerX, centerY);
        _logoButton = button;
    }
    return _logoButton;
}

- (IBAction)getLocation {
    CLAuthorizationStatus authStatus = [CLLocationManager authorizationStatus];
    
    if (authStatus == kCLAuthorizationStatusNotDetermined) {
        [_locationManager requestWhenInUseAuthorization];
        return;
    }
    if (authStatus == kCLAuthorizationStatusDenied || authStatus == kCLAuthorizationStatusRestricted) {
        [self showLocationServicesDeniedAlert];
        return;
    }
    if (_logoVisible) {
        [self hideLogoView];
    }
    if (_updatingLocation) {
        [self stopLocationManager];
    }else {
        _location = nil;
        _lastLocationError = nil;
        _placemark = nil;
        _lastGeocodingError = nil;
        [self startLocationManager];
    }
    [self updateLabels];
    [self configureGetButton];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _locationManager = [[CLLocationManager alloc] init];
    _updatingLocation = NO;
    _geocoder = [[CLGeocoder alloc] init];
    _performingReverseGeocoding = NO;
    _logoVisible = NO;
    _soundID = 0;
    
    [self updateLabels];
    [self configureGetButton];
    [self loadSoundEffect:@"Sound.caf"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showLocationServicesDeniedAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location Services Disabled" message:@"Please enable location services for this app in Settings." preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:(UIAlertActionStyleDefault) handler:nil];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)startLocationManager {
    if ([CLLocationManager locationServicesEnabled]) {
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        [_locationManager startUpdatingLocation];
        _updatingLocation = YES;
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(didTimeOut) userInfo:nil repeats:NO];
    }
}

- (void)stopLocationManager {
    if (_updatingLocation) {
        [_locationManager stopUpdatingLocation];
        _locationManager.delegate = nil;
        _updatingLocation = NO;
        
        if (_timer) {
            [_timer invalidate];
        }
    }
}

- (void)didTimeOut {
    if (_location == nil) {
        [self stopLocationManager];
        
        _lastLocationError = [NSError errorWithDomain:@"MyLocationsErrorDomain" code:1 userInfo:nil];
        
        [self updateLabels];
        [self configureGetButton];
    }
}

- (void)updateLabels {
    if (_location) {
        self.latitudeLabel.text = [NSString stringWithFormat:@"%0.8f", _location.coordinate.latitude];
        self.longitudeLabel.text = [NSString stringWithFormat:@"%0.8f", _location.coordinate.longitude];
        _tagButton.hidden = NO;
        _messageLabel.text = @"";
        
        if (_placemark) {
            _addressLabel.text = [self stringFromPlacemark:_placemark];
        }else if (_performingReverseGeocoding) {
            _addressLabel.text = @"Searching for Address...";
        }else if (_lastGeocodingError != nil) {
            _addressLabel.text = @"Error Finding Address";
        }else {
            _addressLabel.text = @"No Address Found";
        }
        
        _latitudeTextLabel.hidden = NO;
        _longitudeTextLabel.hidden = NO;
    }else {
        _latitudeLabel.text = @"";
        _longitudeLabel.text = @"";
        _addressLabel.text = @"";
        _tagButton.hidden = YES;
        
        NSString *statusMessage;
        if (_lastLocationError) {
            if (_lastLocationError.domain == kCLErrorDomain && _lastLocationError.code == kCLErrorDenied) {
                statusMessage = @"Location Services Disabled";
            }else {
                statusMessage = @"Error Getting Location";
            }
        }else if (![CLLocationManager locationServicesEnabled]) {
            statusMessage = @"Location Services Disabled";
        }else if (_updatingLocation) {
            statusMessage = @"Searching...";
        }else {
            statusMessage = @"";
            [self showLogoView];
        }
        _messageLabel.text = statusMessage;
        _latitudeTextLabel.hidden = YES;
        _longitudeTextLabel.hidden = YES;
    }
}

- (NSString *)stringFromPlacemark:(CLPlacemark *)placemark {
    NSMutableString *line1 = [NSMutableString string];
    [line1 appendString:placemark.subThoroughfare];
    [line1 appendFormat:@" %@", placemark.thoroughfare];
    
    NSMutableString *line2 = [NSMutableString string];
    [line2 appendString:placemark.locality];
    [line2 appendFormat:@" %@", placemark.administrativeArea];
    [line2 appendFormat:@" %@", placemark.postalCode];
    
    [line1 appendFormat:@"\n%@", line2];
    return line1;
}

- (void)configureGetButton {
    NSInteger spinnerTag = 1000;
    if (_updatingLocation) {
        [self.getButton setTitle:@"Stop" forState:(UIControlStateNormal)];
        if ([self.view viewWithTag:spinnerTag] == nil) {
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhite)];
            spinner.center = self.messageLabel.center;
            CGPoint center = spinner.center;
            center.y += spinner.bounds.size.height/2 + 15;
            spinner.center = center;
            [spinner startAnimating];
            spinner.tag = spinnerTag;
            [self.containerView addSubview:spinner];
        }
    }else {
        [self.getButton setTitle:@"Get My Location" forState:(UIControlStateNormal)];
        
        if ([self.view viewWithTag:spinnerTag]) {
            [[self.view viewWithTag:spinnerTag] removeFromSuperview];
        }
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {   
    if ([segue.identifier isEqualToString:@"TagLocation"]) {
        UINavigationController *nav = segue.destinationViewController;
        LocationDetailsViewController *controller = (LocationDetailsViewController *)nav.topViewController;
        controller.coordinate = _location.coordinate;
        controller.placemark = _placemark;
        controller.managedObjectContext = _managedObjectContext;
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *newLocation = [locations lastObject];
    
    if (newLocation.timestamp.timeIntervalSinceNow < -5) {
        return;
    }
    
    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
    
    CLLocationDistance distance = CLLocationDistanceMax;
    if (_location) {
        distance = [newLocation distanceFromLocation:_location];
    }
    
    if (_location == nil || _location.horizontalAccuracy > newLocation.horizontalAccuracy) {
        _lastLocationError = nil;
        _location = newLocation;
        [self updateLabels];
        
        if (newLocation.horizontalAccuracy <= _locationManager.desiredAccuracy) {
            [self stopLocationManager];
            [self configureGetButton];
            
            if (distance > 0) {
                _performingReverseGeocoding = NO;
            }
        }
        
        if (!_performingReverseGeocoding) {
            _performingReverseGeocoding = YES;
            [_geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                _lastGeocodingError = error;
                if (error == nil && placemarks !=nil && placemarks.count != 0) {
                    if (_placemark == nil) {
                        [self playSoundEffect];
                    }
                    _placemark = placemarks.lastObject;
                }else {
                    _placemark = nil;
                }
                
                _performingReverseGeocoding = NO;
                [self updateLabels];
                
            }];
        }
    }else if (distance < 1.0) {
        NSTimeInterval timeInterval = [newLocation.timestamp timeIntervalSinceDate:_location.timestamp];
        if (timeInterval > 10) {
            [self stopLocationManager];
            [self updateLabels];
            [self configureGetButton];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (error.code == kCLErrorLocationUnknown) {
        return;
    }
    _lastLocationError = error;
    [self stopLocationManager];
    [self updateLabels];
    [self configureGetButton];
}

#pragma mark - Logo View

- (void)showLogoView {
    if (!_logoVisible) {
        _logoVisible = YES;
        self.containerView.hidden = YES;
        [self.view addSubview:self.logoButton];
    }
}

- (void)hideLogoView {
    if (!_logoVisible) {
        return;
    }
    _logoVisible = NO;
    self.containerView.hidden = NO;
    CGPoint center = CGPointMake(self.view.bounds.size.width*2, 40 + self.containerView.bounds.size.height/2);
    self.containerView.center = center;
    
    CGFloat centerX = CGRectGetMidX(self.view.bounds);
    
    CABasicAnimation *panelMover = [CABasicAnimation animationWithKeyPath:@"position"];
    panelMover.removedOnCompletion = NO;
    panelMover.fillMode = kCAFillModeForwards;
    panelMover.duration = 0.6;
    panelMover.fromValue = [NSValue valueWithCGPoint:self.containerView.center];
    panelMover.toValue = [NSValue valueWithCGPoint:CGPointMake(centerX, self.containerView.center.y)];
    panelMover.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    panelMover.delegate = self;
    [self.containerView.layer addAnimation:panelMover forKey:@"panelMover"];
    
    CABasicAnimation *logoMover = [CABasicAnimation animationWithKeyPath:@"position"];
    logoMover.removedOnCompletion = NO;
    logoMover.fillMode = kCAFillModeForwards;
    logoMover.duration = 0.5;
    logoMover.fromValue = [NSValue valueWithCGPoint:self.logoButton.center];
    logoMover.toValue = [NSValue valueWithCGPoint:CGPointMake(-centerX, self.logoButton.center.y)];
    logoMover.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [self.logoButton.layer addAnimation:logoMover forKey:@"logoMover"];
    
    CABasicAnimation *logoRotator = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    logoRotator.removedOnCompletion = NO;
    logoRotator.fillMode = kCAFillModeForwards;
    logoRotator.duration = 0.5;
    logoRotator.fromValue = @0.0;
    logoRotator.toValue = @(-2 * M_PI);
    logoRotator.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [self.logoButton.layer addAnimation:logoRotator forKey:@"logoRotator"];
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self.containerView.layer removeAllAnimations];
    self.containerView.center = CGPointMake(self.view.bounds.size.width/2, 40 + self.containerView.bounds.size.height/2);
    
    [self.logoButton.layer removeAllAnimations];
    [self.logoButton removeFromSuperview];
}

#pragma mark - Sound Effect

- (void)loadSoundEffect:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
    if (path) {
        NSURL *fileURL = [NSURL fileURLWithPath:path isDirectory:NO];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &_soundID);
    }
}

- (void)unloadSoundEffect {
    AudioServicesDisposeSystemSoundID(_soundID);
    _soundID = 0;
}

- (void)playSoundEffect {
    AudioServicesPlaySystemSound(_soundID);
}

@end
