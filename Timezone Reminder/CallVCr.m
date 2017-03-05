//
//  CallVC.m
//  Timezone Reminder
//
//  Created by Alexander on 17.02.17.
//  Copyright © 2017 AlexanderStepanishin. All rights reserved.
//

#import "CallVCr.h"

@interface CallVCr ()
- (IBAction)save:(UIBarButtonItem *)sender;
- (IBAction)pickUserDate:(UIDatePicker *)sender;
- (IBAction)pickPartnerDate:(UIDatePicker *)sender;
@property (weak, nonatomic) IBOutlet UIDatePicker *userDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *partnerDatePicker;
@property (weak, nonatomic) IBOutlet UITextView *infoTextView;
@property (weak, nonatomic) IBOutlet UIButton *choseYourLocationButton;
@property (weak, nonatomic) IBOutlet UIButton *choseClientLocationButton;
@property (weak, nonatomic) IBOutlet UIImageView *userWeatherImageView;
@property (weak, nonatomic) IBOutlet UIImageView *clientWeatherImageView;
@property (weak, nonatomic) IBOutlet UIImageView *userDegreesbackgroundImageView;
@property (weak, nonatomic) IBOutlet UITextField *userWeatherTextField;
@property (weak, nonatomic) IBOutlet UIImageView *clientDegreesbackgroundImageView;
@property (weak, nonatomic) IBOutlet UITextField *clientWeatherTextField;
@property (weak, nonatomic) IBOutlet UIImageView *userDatePickerBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *clientDatePickerBackgroundImageView;

@property (strong, nonatomic) CLLocationManager *locationManager;

-(void) setAllOutletsAccordingToCallInProperties;
-(void) keyboardDidShow: (NSNotification*) notification;
-(void) keyboardWillHide: (NSNotification*) notification;
-(void) moveInfoTextViewFromRect: (CGRect) beginRect toRect: (CGRect) endRect;
-(void) calculateClientDateAccordingToUserDateAndTheirLocationsForCall: (Call*) call;
-(void) calculateUserDateAccordingToClientDateAndTheirLocationsForCall: (Call*) call;
-(void) getReverseGeocoderInfoForLocation: (CLLocation*) location forWho: (NSString*) who;
-(void) downloadWeatherForUserLocation: (CLLocation*) userLocation forCallDate: (NSDate*) callDate;
-(void) downloadWeatherForClientLocation: (CLLocation*) clientLocation forCallDate: (NSDate*) callDate;
-(void) back;
-(void) setAllTheImageBackgrounds;

@end

@implementation CallVCr
{
    NSInteger keyboardHeight;
    CGRect lowerPositionTextViewFrame;
    CGRect upperPositionTextViewFrame;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //create LocationManager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    
    //if app is not authorised yet - request authorisation
    CLAuthorizationStatus authStat = [CLLocationManager authorizationStatus];
    if ((authStat == kCLAuthorizationStatusNotDetermined) || (authStat==kCLAuthorizationStatusDenied) || (authStat == kCLAuthorizationStatusRestricted)){
        if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0){
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
    //if user disabled location services - ask him to enable them
    if (![CLLocationManager locationServicesEnabled]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location services disabled"
                                                    message:@"Turn on the location services in your iPhone settings"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleDefault
                                                      handler:nil];
        [alert addAction:actionOK];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    [self.locationManager requestLocation];

    
    if (self.isNewCall == YES){
        
        //create new call in property to save it in context in the end
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *viewContext = appDelegate.persistentContainer.viewContext;
        //NSManagedObjectContext *backgroundContext = appDelegate.persistentContainer.newBackgroundContext;
        self.callToEdit = [[Call alloc] initWithEntity:
                           [NSEntityDescription entityForName:@"Call" inManagedObjectContext:viewContext]
                        insertIntoManagedObjectContext:viewContext];
        self.callToEdit.textInfo = @"Call with: ";
        
        //user part
        self.callToEdit.userDate = [NSDate date];
        self.callToEdit.userLatitude = 53.9; //Minsk Latitude
        self.callToEdit.userLongitude = 27.5666; //Minsk Longitude
        self.callToEdit.userAddressString = @"Your location.";
        
        //client part
        //silicon valley for default
        self.callToEdit.clientLatitude = 37.773972;
        self.callToEdit.clientLongitude = -122.431297;
        self.callToEdit.clientAddressString = @"Companion location.";
        [self calculateClientDateAccordingToUserDateAndTheirLocationsForCall: self.callToEdit];
        self.callToEdit.userWeather = @"temp.";
        self.callToEdit.clientWeather = @"temp.";
    }
    
    self.infoTextView.delegate = self;
    
    //Add observer to keyboard changes to get it's height
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    //add custom back button
    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithTitle:@"\u2770 Calls"
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backBarButton;
    self.userWeatherTextField.enabled = NO;
    self.clientWeatherTextField.enabled = NO;
}

-(void) viewWillAppear:(BOOL)animated
{
    //after place changing need to reset dates (may use here another method calculateUserDate... with same result)
    [self calculateClientDateAccordingToUserDateAndTheirLocationsForCall:self.callToEdit];
    [self setAllOutletsAccordingToCallInProperties];
    
    [self downloadWeatherForUserLocation:self.userLocation forCallDate:self.callToEdit.userDate];
    [self downloadWeatherForClientLocation:self.clientLocation forCallDate:self.callToEdit.clientDate];
    
    if (self.userLocationUpdatedByUser){
        [self getReverseGeocoderInfoForLocation:self.userLocation forWho:@"user"];
        self.userLocationUpdatedByUser = NO;
    } else if (self.clientLocationUpdatedByUser){
        [self getReverseGeocoderInfoForLocation:self.clientLocation forWho:@"client"];
        self.clientLocationUpdatedByUser = NO;
    }
    
    
}

-(void) viewDidAppear:(BOOL)animated
{
    
    //align text in textView
    [self.infoTextView setContentOffset:CGPointZero animated:NO];
    [self.infoTextView scrollRangeToVisible:NSMakeRange(0, 0)];
    [self setAllTheImageBackgrounds];
}

-(void) setAllTheImageBackgrounds
{
    //set main view background
    CGSize mainViewSize = self.view.frame.size;
    UIImage *backgroundForMainView = [UIImage imageNamed:@"background"];
    backgroundForMainView = [backgroundForMainView imageByScalingProportionallyToSize:mainViewSize];
    self.view.backgroundColor = [UIColor colorWithPatternImage:backgroundForMainView];
    
    /*
    //set datePickers background
    self.userDatePickerBackgroundImageView.image = [UIImage imageNamed:@"background_datePicker_user"];
    self.clientDatePickerBackgroundImageView.image = [UIImage imageNamed:@"background_datePicker_client"];
    
    //weather degrees background
    self.userDegreesbackgroundImageView.image = [UIImage imageNamed:@"background_degrees_user"];
    self.clientDegreesbackgroundImageView.image = [UIImage imageNamed:@"background_degrees_client"];
    */
    
    //infoTextView background
    UIImage *backgroundForInfoTextView = [UIImage imageNamed:@"background_textView"];
    self.infoTextView.backgroundColor = [UIColor colorWithPatternImage:backgroundForInfoTextView];
    
}

-(void) calculateClientDateAccordingToUserDateAndTheirLocationsForCall: (Call*) call
{
    //user part
    //init property without setter
    _userLocation = [[CLLocation alloc] initWithLatitude:call.userLatitude
                                                   longitude:call.userLongitude];
    NSTimeZone *userTimezone = [[APTimeZones sharedInstance] timeZoneWithLocation:self.userLocation];
    call.userSecondsFromGMT = userTimezone.secondsFromGMT;
    NSInteger userSecondsFrom1970 = [(NSDate*)call.userDate timeIntervalSince1970];
    
    //client part
    self.clientLocation = [[CLLocation alloc] initWithLatitude:call.clientLatitude
                                                     longitude:call.clientLongitude];
    NSTimeZone *clientTimezone = [[APTimeZones sharedInstance] timeZoneWithLocation:self.clientLocation];
    call.clientSecondsFromGMT = clientTimezone.secondsFromGMT;
    
    //calculating time difference
    NSInteger secondsFromGMTDifference = call.userSecondsFromGMT - call.clientSecondsFromGMT;
    NSInteger clientSecondsFrom1970;
    if (call.userSecondsFromGMT > call.clientSecondsFromGMT){
        clientSecondsFrom1970 = userSecondsFrom1970 - secondsFromGMTDifference;
    } else {
        clientSecondsFrom1970 = userSecondsFrom1970 + secondsFromGMTDifference;
    }
    call.clientDate = [NSDate dateWithTimeIntervalSince1970:clientSecondsFrom1970];
}

-(void) calculateUserDateAccordingToClientDateAndTheirLocationsForCall: (Call*) call
{
    //client part
    self.clientLocation = [[CLLocation alloc] initWithLatitude:call.clientLatitude
                                                     longitude:call.clientLongitude];
    NSTimeZone *clientTimezone = [[APTimeZones sharedInstance] timeZoneWithLocation:self.clientLocation];
    call.clientSecondsFromGMT = clientTimezone.secondsFromGMT;
    NSInteger clientSecondsFrom1970 = [(NSDate*)call.clientDate timeIntervalSince1970];
    
    //user part
    self.userLocation = [[CLLocation alloc] initWithLatitude:call.userLatitude
                                                   longitude:call.userLongitude];
    NSTimeZone *userTimezone = [[APTimeZones sharedInstance] timeZoneWithLocation:self.userLocation];
    call.userSecondsFromGMT = userTimezone.secondsFromGMT;
    
    //calculating time difference
    NSInteger secondsFromGMTDifference = call.userSecondsFromGMT - call.clientSecondsFromGMT;
    NSInteger userSecondsFrom1970;
    if (call.userSecondsFromGMT > call.clientSecondsFromGMT){
        userSecondsFrom1970 = clientSecondsFrom1970 + secondsFromGMTDifference;
    } else {
        userSecondsFrom1970 = clientSecondsFrom1970 - secondsFromGMTDifference;
    }
    call.userDate = [NSDate dateWithTimeIntervalSince1970:userSecondsFrom1970];
}



-(void) setAllOutletsAccordingToCallInProperties
{
    self.userDatePicker.date = self.callToEdit.userDate;
    self.partnerDatePicker.date = self.callToEdit.clientDate;
    self.infoTextView.text = self.callToEdit.textInfo;
    [self.choseYourLocationButton setTitle:self.callToEdit.userAddressString forState:UIControlStateNormal];
    [self.choseClientLocationButton setTitle:self.callToEdit.clientAddressString forState:UIControlStateNormal];
    [self.userWeatherTextField setText:self.callToEdit.userWeather];
    [self.clientWeatherTextField setText:self.callToEdit.clientWeather];
    [self.view setNeedsDisplay];
}

-(void)getReverseGeocoderInfoForLocation: (CLLocation*) location forWho: (NSString*) who
{
    __weak CallVCr *blockCallVCr = self;
    
    //get place name according to ccordinates and put it in database
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error == NULL){
            
            //get name of place
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSDictionary *addressDictionary = placemark.addressDictionary;
            NSArray <NSString*> *addressLines = [addressDictionary valueForKey:@"FormattedAddressLines"];
            NSInteger linesCount = addressLines.count;
            NSString *lastLine = [addressLines objectAtIndex:(linesCount-1)];
            NSString *lastButOneLine = [addressLines objectAtIndex:(linesCount-2)];
            lastLine = [lastLine stringByAppendingString:@", "];
            NSString *addressString = [lastLine stringByAppendingString:lastButOneLine];

            //modify address in Database (there is no check of blockCallVCr object existence.)
            if ([blockCallVCr isKindOfClass:[CallVCr class]]) {
                if ([who isEqualToString:@"user"]){
                    blockCallVCr.callToEdit.userAddressString = addressString;
                    [blockCallVCr performSelector:@selector(setAllOutletsAccordingToCallInProperties)
                                       withObject:nil];
                } else if ([who isEqualToString:@"client"]){
                    blockCallVCr.callToEdit.clientAddressString = addressString;
                    [blockCallVCr performSelector:@selector(setAllOutletsAccordingToCallInProperties)
                                       withObject:nil];
                }
            }
            
        //handle errors
        } else if (error.code == kCLErrorNetwork){
            NSLog(@"Error in getting place name from geocode server (too many requests maybe): %@", error.userInfo);
        } else {
            NSLog(@"Error in getting place name from geocoder: %@", error.userInfo);
        }
    }];
}



- (IBAction)save:(UIBarButtonItem *)sender {
    
    //save context and dismiss view controller
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSError *error;
    if (![appDelegate.persistentContainer.viewContext save:&error]) {
        NSLog(@"error while saving context in IBAction save: %@", error.userInfo);
    }
    
    [[LocalNotificationsManager sharedLocalNotificationsManager] addNotificationsForCalls:@[self.callToEdit]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)pickUserDate:(UIDatePicker *)sender {
    self.callToEdit.userDate = [sender date];
    [self calculateClientDateAccordingToUserDateAndTheirLocationsForCall:self.callToEdit];
    [self setAllOutletsAccordingToCallInProperties];
}


- (IBAction)pickPartnerDate:(UIDatePicker *)sender {
    self.callToEdit.clientDate = [sender date];
    [self calculateUserDateAccordingToClientDateAndTheirLocationsForCall:self.callToEdit];
    [self setAllOutletsAccordingToCallInProperties];
}


#pragma mark CLLocationManager delegate

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    //get recent location
    CLLocation *recentLocation = [locations lastObject];
    if ([recentLocation.timestamp timeIntervalSinceNow] > 3600){
        return;
    }
    if (recentLocation){
        self.userLocation = recentLocation;
    }
    
    //update editing call and outlets if userLocation has changed
    if ((self.callToEdit.userLatitude != recentLocation.coordinate.latitude) || (self.callToEdit.userLongitude != recentLocation.coordinate.longitude)){
        
        self.callToEdit.userLatitude = recentLocation.coordinate.latitude;
        self.callToEdit.userLongitude = recentLocation.coordinate.longitude;
        
        [self calculateClientDateAccordingToUserDateAndTheirLocationsForCall:self.callToEdit];
        [self getReverseGeocoderInfoForLocation:recentLocation forWho:@"user"];
        [self setAllOutletsAccordingToCallInProperties];
    }
}

-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"Fail to update location. Error %@", [error userInfo]);
}

#pragma mark UITextView delegate

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text containsString:@"\n"]){
        self.callToEdit.textInfo = textView.text;
        [textView resignFirstResponder];
    }
    return YES;
}

#pragma mark keyboard observer methods

-(void) keyboardDidShow: (NSNotification*) notification
{
    //disable all responders except textView
    self.userDatePicker.enabled = NO;
    self.userDatePickerBackgroundImageView.alpha = 0.2;
    self.partnerDatePicker.enabled = NO;
    self.clientDatePickerBackgroundImageView.alpha = 0.2;
    self.choseYourLocationButton.enabled = NO;
    self.choseClientLocationButton.enabled = NO;
    self.userWeatherImageView.alpha = 0.2;
    self.userDegreesbackgroundImageView.alpha = 0.2;
    self.userWeatherTextField.alpha = 0.3;
    self.clientWeatherImageView.alpha = 0.2;
    self.clientDegreesbackgroundImageView.alpha = 0.2;
    self.clientWeatherTextField.alpha = 0.3;
    self.clientWeatherImageView.alpha = 0.2;
    
    //get height of keyboard from user info dictionary
    CGRect keyboardFrame = [[notification.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    keyboardHeight = keyboardFrame.size.height;
    NSLog(@"keyboardHeight = %lu", keyboardHeight);
    
    //calculate Frames and animate textView Frame transition
    lowerPositionTextViewFrame = [self.infoTextView frame];
    NSInteger navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    NSInteger statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
    NSInteger originY = statusBarHeight + navigationBarHeight;
    NSInteger screenWidth = self.view.frame.size.width;
    NSInteger upperPositionTextviewHeight = self.view.frame.size.height-navigationBarHeight-keyboardHeight;
    upperPositionTextViewFrame = CGRectMake(0, originY, screenWidth, upperPositionTextviewHeight);
    [self moveInfoTextViewFromRect:lowerPositionTextViewFrame toRect:upperPositionTextViewFrame];
    
}

-(void) moveInfoTextViewFromRect: (CGRect) beginRect toRect: (CGRect) endRect
{
    [UIView animateWithDuration:1.0 animations:^{
        self.infoTextView.frame = endRect;
    }];
}


-(void) keyboardWillHide: (NSNotification*) notification
{
    //enable all responders
    self.userDatePicker.enabled = YES;
    self.userDatePickerBackgroundImageView.alpha = 1;
    self.partnerDatePicker.enabled = YES;
    self.clientDatePickerBackgroundImageView.alpha = 1;
    self.choseYourLocationButton.enabled = YES;
    self.choseClientLocationButton.enabled = YES;
    self.userWeatherImageView.alpha = 1;
    self.userDegreesbackgroundImageView.alpha = 1;
    self.userWeatherTextField.alpha = 1;
    self.clientWeatherImageView.alpha = 1;
    self.clientDegreesbackgroundImageView.alpha = 1;
    self.clientWeatherTextField.alpha = 1;
    self.clientWeatherImageView.alpha = 1;
    
    //animate textView transition to standart position
    [self moveInfoTextViewFromRect:upperPositionTextViewFrame toRect:lowerPositionTextViewFrame];
}


#pragma mark AFNetworking

- (void) downloadWeatherForUserLocation: (CLLocation*) userLocation forCallDate: (NSDate*) callDate
{
    WeatherClient *weatherClient = [WeatherClient sharedWeatherClient];
    weatherClient.delegate = self;
    [weatherClient updateWeatherAtLocation:userLocation forDate:callDate forCall:self.callToEdit forWho:@"user"];
}


-(void) downloadWeatherForClientLocation: (CLLocation*) clientLocation forCallDate: (NSDate*) callDate
{
    WeatherClient *weatherClient = [WeatherClient sharedWeatherClient];
    weatherClient.delegate = self;
    [weatherClient updateWeatherAtLocation:clientLocation forDate:callDate forCall:self.callToEdit forWho:@"client"];

}

- (void) weatherClient:(WeatherClient*)client didUpdateWithWeather:(id)weather forCall:(Call*)call forWho:(NSString*)who
{
    //get weather text info
    NSDictionary *weatherDictionary = weather;
    weatherDictionary = weatherDictionary[@"data"];
    NSArray *weatherArray = weatherDictionary[@"weather"];
    weatherDictionary = [weatherArray objectAtIndex:0];
    NSInteger maxtempC = [weatherDictionary[@"maxtempC"] intValue];
    NSInteger mintempC = [weatherDictionary[@"mintempC"] intValue];
    NSInteger tempToDisplay = (maxtempC+mintempC)/2;
    
    //get link to picture
    weatherArray = weatherDictionary[@"hourly"];
    weatherDictionary = [weatherArray objectAtIndex:4]; //12.00-15.00
    NSArray *urls = weatherDictionary[@"weatherIconUrl"];
    weatherDictionary = urls[0];
    NSString *weatherIconURLString = weatherDictionary[@"value"];
    NSURL *weatherIconURL = [NSURL URLWithString:weatherIconURLString];
    
    if ([who isEqualToString:@"user"]){
        
        //save weather and linkto user part in model, start to retrieve weather image
        self.callToEdit.userWeather = [NSString stringWithFormat:@"%ld ℃", (long)tempToDisplay];
        self.callToEdit.userWeatherIconString =  weatherIconURLString ;
        [self.userWeatherImageView setImageWithURL:weatherIconURL  placeholderImage:[UIImage imageNamed:@"placeholder"]];
        
    } else if ([who isEqualToString:@"client"]){
        
        //save weather and link to client part in model, start to retrieve weather image
        self.callToEdit.clientWeather = [NSString stringWithFormat:@"%ld ℃", (long)tempToDisplay];
        self.callToEdit.clientWeatherIconString = weatherIconURL.absoluteString;
        [self.clientWeatherImageView setImageWithURL:weatherIconURL placeholderImage:[UIImage imageNamed:@"placeholder"]];
    }
    
    [self setAllOutletsAccordingToCallInProperties];
}

- (void)weatherClient:(WeatherClient*)client didFailWithError:(NSError*)error
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"weather fetch fail"
                                                                   message:@"Could not retrieve weather characteristics for desired date"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:nil];
    [alert addAction:actionOK];
    [self presentViewController:alert animated:YES completion:nil];
    
    
}

 #pragma mark - Navigation

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
     MapVC *mapVC = (MapVC*)[segue destinationViewController];
     
     //pass user's location
     if ([segue.identifier isEqualToString:@"user's city"]){
         mapVC.userLocation = self.userLocation;
         mapVC.clientLocation = nil;
         
     //pass client's location
     } else if ([segue.identifier isEqualToString:@"client's city"]){
         mapVC.userLocation = nil;
         mapVC.clientLocation = self.clientLocation;
     }
}

-(void) back
{
        // BACK button pressed
        if (self.isNewCall){
            
            //BACK pressed + isNewCall = delete this call
            AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
            NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
            if (!self.callToEdit.isDeleted || (self.callToEdit.managedObjectContext != nil)) {
                [context deleteObject:self.callToEdit];
                NSError *error;
                if (![context save:&error]){
                    NSLog(@"Error while saving context after deleting call: %@", error.userInfo);
                };
            }
        }
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
