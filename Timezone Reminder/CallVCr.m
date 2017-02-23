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

@property (strong, nonatomic) CLLocationManager *locationManager;

-(void) setDatePickersAccordingToCall: (Call*) call;
-(void) keyboardDidShow: (NSNotification*) notification;
-(void) keyboardWillHide: (NSNotification*) notification;
-(void) moveInfoTextViewFromRect: (CGRect) beginRect toRect: (CGRect) endRect;
-(void) refreshUserAndClientLocationsProperties;

@end

@implementation CallVCr
{
    NSInteger keyboardHeight;
    CGRect lowerPositionTextViewFrame;
    CGRect upperPositionTextViewFrame;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //initLocationManager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 8.0){
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
#warning can get locations only on real iPhone
    
    if (self.isNewCall == YES){
        
        //create new call in property to save it in context in the end
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *viewContext = appDelegate.persistentContainer.viewContext;
        //NSManagedObjectContext *backgroundContext = appDelegate.persistentContainer.newBackgroundContext;
        self.callToEdit = [[Call alloc] initWithEntity:
                           [NSEntityDescription entityForName:@"Call" inManagedObjectContext:viewContext]
                        insertIntoManagedObjectContext:viewContext];
        self.callToEdit.textInfo = @"Make a call";
        
        //user part
        self.callToEdit.userDate = [NSDate date];
#warning creating new location to run on simulator (uncomment userTimezone and use didUpdateLocation)
        self.callToEdit.userLatitude = 53.9; //Minsk Latitude
        self.callToEdit.userLongitude = 27.5667; //Minsk Longitude
        self.userLocation = [[CLLocation alloc] initWithLatitude:self.callToEdit.userLatitude
                                                       longitude:self.callToEdit.userLongitude];
        NSTimeZone *userTimezone = [[APTimeZones sharedInstance] timeZoneWithLocation:self.userLocation];
        self.callToEdit.userSecondsFromGMT = userTimezone.secondsFromGMT;
        NSInteger userSecondsFrom1970 = [(NSDate*)self.callToEdit.userDate timeIntervalSince1970];
        
        //client part
        //silicon valley for default
        self.callToEdit.clientLatitude = 37.773972;
        self.callToEdit.clientLongitude = -122.431297;
        self.clientLocation = [[CLLocation alloc] initWithLatitude:self.callToEdit.clientLatitude
                                                         longitude:self.callToEdit.clientLongitude];
        NSTimeZone *clientTimezone = [[APTimeZones sharedInstance] timeZoneWithLocation:self.clientLocation];
        self.callToEdit.clientSecondsFromGMT = clientTimezone.secondsFromGMT;
        
        //calculating time difference
        NSInteger secondsFromGMTDifference = self.callToEdit.userSecondsFromGMT - self.callToEdit.clientSecondsFromGMT;
        NSInteger clientSecondsFrom1970;
        if (self.callToEdit.userSecondsFromGMT > self.callToEdit.clientSecondsFromGMT){
            clientSecondsFrom1970 = userSecondsFrom1970 - secondsFromGMTDifference;
        } else {
            clientSecondsFrom1970 = userSecondsFrom1970 + secondsFromGMTDifference;
        }
        self.callToEdit.clientDate = [NSDate dateWithTimeIntervalSince1970:clientSecondsFrom1970];
#warning add weather
        //self.callToEdit.userWeather = ;
        //self.callToEdit.clientWeather = ;
    } else {
        
        //set outlets and properties according to opened call
        [self refreshUserAndClientLocationsProperties];
        self.userDatePicker.date = self.callToEdit.userDate;
        self.partnerDatePicker.date = self.callToEdit.clientDate;
        self.infoTextView.text = self.callToEdit.textInfo;
    }
    
    [self setDatePickersAccordingToCall: self.callToEdit];
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
}

-(void) viewWillAppear:(BOOL)animated
{
    [self refreshUserAndClientLocationsProperties];
}

-(void) refreshUserAndClientLocationsProperties
{
    CLLocation *userLocation = [[CLLocation alloc] initWithLatitude:self.callToEdit.userLatitude
                                                          longitude:self.callToEdit.userLongitude];
    CLLocation *clientLocation = [[CLLocation alloc] initWithLatitude:self.callToEdit.clientLatitude
                                                            longitude:self.callToEdit.clientLongitude];
    self.userLocation = userLocation;
    self.clientLocation = clientLocation;
}

-(void) setDatePickersAccordingToCall: (Call*) call
{
    self.userDatePicker.date = call.userDate;
    self.partnerDatePicker.date = call.clientDate;
}

- (IBAction)save:(UIBarButtonItem *)sender {
    
    //save context and dismiss view controller
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    NSError *error;
    if (![appDelegate.persistentContainer.viewContext save:&error]) {
        NSLog(@"error while saving context in IBAction save: %@", error.userInfo);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)pickUserDate:(UIDatePicker *)sender {
}


- (IBAction)pickPartnerDate:(UIDatePicker *)sender {
    
}

#pragma mark CLLocationManager delegate

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
#warning method works only on real iPhone
    /*CLLocation *recentLocation = [locations lastObject];
    self.userLocation = recentLocation;*/
}

#pragma mark UITextView delegate

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSLog(@"textView shouldChangeTextInRange:");
    NSLog(@"text = %@", text);
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
    self.partnerDatePicker.enabled = NO;
    self.choseYourLocationButton.enabled = NO;
    self.choseClientLocationButton.enabled = NO;
#warning add weather labels shading
    
    //get keyboard height to instance variable
    NSLog(@"keyboardFrameDidChange:");
    //get height of keyboard from user info dictionary
    CGRect keyboardFrame = [[notification.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    keyboardHeight = keyboardFrame.size.height;
    NSLog(@"keyboardHeight = %ld", keyboardHeight);
    
    //calculate Frames and animate textView Frame transition
    lowerPositionTextViewFrame = [self.infoTextView frame];
    NSInteger navigationBarHeight = self.navigationController.navigationBar.frame.size.height;
    NSInteger screenWidth = self.view.frame.size.width;
    NSInteger upperPositionTextviewHeight = self.view.frame.size.height-navigationBarHeight-keyboardHeight;
    upperPositionTextViewFrame = CGRectMake(0, navigationBarHeight, screenWidth, upperPositionTextviewHeight);
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
    self.partnerDatePicker.enabled = YES;
    self.choseYourLocationButton.enabled = YES;
    self.choseClientLocationButton.enabled = YES;
#warning add weather labels unshading
    
    //animate textView transition to standart position
    [self moveInfoTextViewFromRect:upperPositionTextViewFrame toRect:lowerPositionTextViewFrame];
}


 #pragma mark - Navigation

 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
     MapVC *mapVC = (MapVC*)[segue destinationViewController];
     NSLog(@"CALLVCR self.userLocation = %@", self.userLocation);
     NSLog(@"CALLVCR self.clientLocation = %@", self.clientLocation);
     
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
 

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
