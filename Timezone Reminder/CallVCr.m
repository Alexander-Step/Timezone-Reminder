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

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *userLocation;

-(void) setDatePickersAccordingToCall: (Call*) call;

@end

@implementation CallVCr

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
        NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
        self.callToEdit = [[Call alloc] initWithEntity:
                           [NSEntityDescription entityForName:@"Call" inManagedObjectContext:context]
                        insertIntoManagedObjectContext:context];
        self.callToEdit.textInfo = @"Make a call";
        self.callToEdit.userDate = [NSDate date];
#warning creating new location to run on simulator (uncomment userTimezone and use didUpdateLocation)
        CLLocation *userLocation = [[CLLocation alloc] initWithLatitude:30.0 longitude:30.0];
        NSTimeZone *userTimezone = [[APTimeZones sharedInstance] timeZoneWithLocation:userLocation];
        NSLog(@"[APTimeZones sharedInstance] = %@", [APTimeZones sharedInstance]);
        //NSTimeZone *userTimezone = [[APTimeZones sharedInstance] timeZoneWithLocation:self.userLocation];
        self.callToEdit.userSecondsFromGMT = userTimezone.secondsFromGMT; //change to int64 in model
        NSLog(@"userTimezone.secondsFromGMT = %lu", userTimezone.secondsFromGMT);
        self.callToEdit.clientSecondsFromGMT = 0; //rndLocation
        NSInteger secondsFromGMTDifference = self.callToEdit.userSecondsFromGMT - self.callToEdit.clientSecondsFromGMT;
        NSInteger clientSecondsFrom1970 = self.callToEdit.userSecondsFromGMT + secondsFromGMTDifference;
        self.callToEdit.clientDate = [NSDate dateWithTimeIntervalSince1970:clientSecondsFrom1970];
#warning add weather, modify secondsFromGMT
        //self.callToEdit.clientWeather = ;
        //self.callToEdit.userWeather = ;
        self.callToEdit.userStringPlace = @"Belarus, Minsk";
        self.callToEdit.clientStringPlace = @"USA, SanFrancisco";
    } else {
        //set outlets according to opened call
    }
    
    [self setDatePickersAccordingToCall: self.callToEdit];
}

-(void) setDatePickersAccordingToCall: (Call*) call
{
    self.userDatePicker.date = call.userDate;
    self.partnerDatePicker.date = call.clientDate;
}

- (IBAction)save:(UIBarButtonItem *)sender {
}

- (IBAction)pickUserDate:(UIDatePicker *)sender {
}


- (IBAction)pickPartnerDate:(UIDatePicker *)sender {
    
}

#pragma mark CLLocationManager delegate

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
#warning method works only on real iPhone
    NSLog(@"locationManager:didUpdateLocations:");
    CLLocation *recentLocation = [locations lastObject];
    self.userLocation = recentLocation;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
