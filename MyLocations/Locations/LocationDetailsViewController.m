//
//  LocationDetailsViewController.m
//  MyLocations
//
//  Created by HNF's wife on 16/9/16.
//  Copyright © 2016年 huangningfa@163.com. All rights reserved.
//

#import "LocationDetailsViewController.h"
#import "CategoryPickerViewController.h"
#import "HudView.h"
#import "Location.h"
#import "MyImagePickerController.h"

@interface LocationDetailsViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *latitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *longitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *addPhotoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation LocationDetailsViewController {
    
    NSString *_descriptionText;
    NSString *_categoryName;
    NSDate *_date;
    UIImage *_image;
    
    NSObject *_observer;
}

- (void)setLocationToEdit:(Location *)locationToEdit {
    _locationToEdit = locationToEdit;
    
    _descriptionText = locationToEdit.locationDescription;
    _categoryName = locationToEdit.category;
    _date = locationToEdit.date;
    _coordinate = CLLocationCoordinate2DMake(locationToEdit.latitude, locationToEdit.longitude);
    _placemark = locationToEdit.placemark;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (_locationToEdit) {
        self.title = @"Edit Location";
        if (_locationToEdit.hasPhoto) {
            UIImage *image = _locationToEdit.photoImage;
            [self showImage:image];
        }
    }else {
        _categoryName = @"No Category";
        _date = [[NSDate alloc] init];
    }
    
    self.descriptionTextView.text = _descriptionText;
    self.categoryLabel.text = _categoryName;
    
    self.latitudeLabel.text = [NSString stringWithFormat:@"%.8f", _coordinate.latitude];
    self.longitudeLabel.text = [NSString stringWithFormat:@"%.8f", _coordinate.longitude];
    
    if (_placemark) {
        self.addressLabel.text = [self stringFromPlacemark:_placemark];
    }else {
        self.addressLabel.text = @"No Address Found";
    }
    self.dateLabel.text = [self formatDate:_date];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];
    
    [self listenForBackgroundNotification];
    
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorColor = [[UIColor alloc] initWithWhite:1.0 alpha:0.2];
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    
    self.descriptionTextView.textColor = [UIColor whiteColor];
    self.descriptionTextView.backgroundColor = [UIColor blackColor];
    
    self.addPhotoLabel.textColor = [UIColor whiteColor];
    self.addPhotoLabel.highlightedTextColor = self.addPhotoLabel.textColor;
    
    self.addressLabel.textColor = [[UIColor alloc] initWithWhite:1.0 alpha:0.4];
    self.addressLabel.highlightedTextColor = self.addressLabel.textColor;
    
}

- (void)hideKeyboard:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    if (indexPath != nil && indexPath.section == 0 && indexPath.row == 0) {
        return;
    }
    [self.descriptionTextView resignFirstResponder];
}

- (void)listenForBackgroundNotification {
    __weak typeof(self) weakSelf = self;
    _observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        if (weakSelf.presentedViewController != nil) {
            [weakSelf dismissViewControllerAnimated:NO completion:nil];
        }
        [weakSelf.descriptionTextView resignFirstResponder];
    }];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:_observer];
}

- (NSString *)stringFromPlacemark:(CLPlacemark *)placemark {
    NSMutableString *line = [NSMutableString string];
    [line appendString:placemark.subThoroughfare];
    [line appendFormat:@" %@", placemark.thoroughfare];
    [line appendFormat:@", %@", placemark.locality];
    [line appendFormat:@", %@", placemark.administrativeArea];
    [line appendFormat:@" %@", placemark.postalCode];
    [line appendFormat:@", %@", placemark.country];
    
    return line;
}

- (NSString *)formatDate:(NSDate *)date {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateStyle = NSDateFormatterMediumStyle;
    format.timeStyle = NSDateFormatterShortStyle;
    return [format stringFromDate:date];
}

- (void)showImage:(UIImage *)image {
    self.imageView.image = image;
    self.imageView.hidden = NO;
    self.imageView.frame = CGRectMake(10, 10, 260, 260);
    self.addPhotoLabel.hidden = YES;
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)done:(id)sender {
    HudView *hud = [HudView hudInView:self.navigationController.view animated:YES];
    
    Location *location;
    if (self.locationToEdit) {
        hud.text = @"Updated";
        location = self.locationToEdit;
    }else {
        hud.text = @"Tagged";
        location = [NSEntityDescription insertNewObjectForEntityForName:@"Location" inManagedObjectContext:self.managedObjectContext];
        location.photoID = nil;
    }

    location.locationDescription = _descriptionTextView.text;
    location.category = _categoryName;
    location.latitude = _coordinate.latitude;
    location.longitude = _coordinate.longitude;
    location.date = _date;
    location.placemark = _placemark;

    if (_image) {
        if (!location.hasPhoto) {
            location.photoID = [NSNumber numberWithInteger:[Location nextPhotoID]];
        }
        NSData *data = UIImageJPEGRepresentation(_image, 0.5);
        NSError *error;
        [data writeToFile:location.photoPath options:(NSDataWritingAtomic) error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
    }
    
    NSError *error;
    [self.managedObjectContext save:&error];
    if (error) {
        NSLog(@"%@", error);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MyManagedObjectContextSaveDidFailNotification" object:nil];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"PickCategory"]) {
        CategoryPickerViewController *controller = segue.destinationViewController;
        controller.selectedCategoryName = _categoryName;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)categoryPickerDidPickCategory:(UIStoryboardSegue *)segue {
    CategoryPickerViewController *controller = segue.sourceViewController;
    _categoryName = controller.selectedCategoryName;
    self.categoryLabel.text = _categoryName;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 88;
        
    }else if (indexPath.section == 1) {
        return self.imageView.hidden ? 44 : 280;
        
    }else if (indexPath.section == 2 && indexPath.row == 2) {
        CGRect frame = self.addressLabel.frame;
        frame.size = CGSizeMake(self.view.bounds.size.width - 115, 10000);
        frame.origin.x = self.view.bounds.size.width - self.addressLabel.frame.size.width - 15;
        self.addressLabel.frame = frame;
        [self.addressLabel sizeToFit];
        return self.addressLabel.frame.size.height + 20;
        
    }else {
        return 44;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 || indexPath.section == 1) {
        return indexPath;
    }else {
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self.descriptionTextView becomeFirstResponder];
    }else if (indexPath.section == 1 && indexPath.row == 0) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

        [self pickPhoto];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor blackColor];
    
    if (cell.textLabel) {
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = cell.textLabel.textColor;
    }
    
    if (cell.detailTextLabel) {
        cell.detailTextLabel.textColor = [[UIColor alloc] initWithWhite:1.0 alpha:0.4];
        cell.detailTextLabel.highlightedTextColor = cell.detailTextLabel.textColor;
    }
    
    UIView *selectionView = [[UIView alloc] initWithFrame:CGRectZero];
    selectionView.backgroundColor = [[UIColor alloc] initWithWhite:1.0 alpha:0.2];
    cell.selectedBackgroundView = selectionView;
    
    if (indexPath.row == 2) {
        UILabel *addressLabel = [cell viewWithTag:100];
        addressLabel.textColor = [UIColor whiteColor];
        addressLabel.highlightedTextColor = addressLabel.textColor;
    }
}


- (void)pickPhoto {
    if ([UIImagePickerController isSourceTypeAvailable:(UIImagePickerControllerSourceTypeCamera)]) {
        [self showPhotoMenu];
    }else {
        [self choosePhotoFromLibrary];
    }
}

- (void)showPhotoMenu {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:(UIAlertActionStyleCancel) handler:nil];
    [alertController addAction:cancelAction];
    
    UIAlertAction *takePhotoAction = [UIAlertAction actionWithTitle:@"Take Photo" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [self takePhotoWithCamera];
    }];
    [alertController addAction:takePhotoAction];
    
    UIAlertAction *chooseFromLibraryAction = [UIAlertAction actionWithTitle:@"Choose From Library" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [self choosePhotoFromLibrary];
    }];
    [alertController addAction:chooseFromLibraryAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)takePhotoWithCamera {
    UIImagePickerController *imagePicker = [[MyImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.view.tintColor = self.view.tintColor;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)choosePhotoFromLibrary {
    UIImagePickerController *imagePicker = [[MyImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.view.tintColor = self.view.tintColor;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    _image = info[UIImagePickerControllerEditedImage];
    if (_image) {
        [self showImage:_image];
    }
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
