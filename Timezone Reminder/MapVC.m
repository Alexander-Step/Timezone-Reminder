//
//  MapVC.m
//  Timezone Reminder
//
//  Created by Alexander on 21.02.17.
//  Copyright © 2017 AlexanderStepanishin. All rights reserved.
//

#import "MapVC.h"

@interface MapVC ()

- (IBAction)tap:(UITapGestureRecognizer *)sender;
- (IBAction)save:(UIBarButtonItem *)sender;

@end

@implementation MapVC
{
    MKPointAnnotation *userPoint;
    MKPointAnnotation *clientPoint;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;
    
    //set mapView region, span, put point on a map
    if (self.userLocation){
        CLLocationCoordinate2D centerCoordinate = self.userLocation.coordinate;
        MKCoordinateSpan span = MKCoordinateSpanMake(5, 5);
        self.mapView.region = MKCoordinateRegionMake(centerCoordinate, span);
        
    } else if (self.clientLocation){
        CLLocationCoordinate2D centerCoordinate = self.clientLocation.coordinate;
        MKCoordinateSpan span = MKCoordinateSpanMake(5, 5);
        self.mapView.region = MKCoordinateRegionMake(centerCoordinate, span);
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    //add annotation to the mapView
    if (self.userLocation){
        self->userPoint = [[MKPointAnnotation alloc] init];
        self->userPoint.coordinate = self.userLocation.coordinate;
        self->userPoint.title = @"Your location";
        self->clientPoint = nil;
        [self.mapView addAnnotation:userPoint];
        
    } else if (self.clientLocation){
        self->clientPoint = [[MKPointAnnotation alloc] init];
        self->clientPoint.coordinate = self.clientLocation.coordinate;
        self->clientPoint.title = @"Client location";
        self->userPoint = nil;
        [self.mapView addAnnotation:clientPoint];
    }
}
                                
#pragma mark MKMapView delegate
-(MKAnnotationView*)mapView:(MKMapView*) mapView viewForAnnotation:(nonnull id<MKAnnotation>)annotation
{
    MKPinAnnotationView *pinAnnotationView  = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                                     reuseIdentifier:@"personLocationAnnotation"];
    [pinAnnotationView setAnimatesDrop:YES];
    [pinAnnotationView setCanShowCallout:NO];
    return pinAnnotationView;
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

- (IBAction)tap:(UITapGestureRecognizer *)sender {
    
    if (sender.state == UIGestureRecognizerStateEnded){
        
        //get location
        CGPoint tapPoint = [sender locationInView:self.mapView];
        CLLocationCoordinate2D tapCoordinate = [self.mapView convertPoint:tapPoint
                                                     toCoordinateFromView:self.mapView];
        double tapLatitude = tapCoordinate.latitude;
        double tapLongitude = tapCoordinate.longitude;
        
        //save to user or client location instance veriable, remove old pin+put a new pinAnnotation
        if (self.userLocation){
            self.userLocation = [[CLLocation alloc] initWithLatitude:tapLatitude
                                                           longitude:tapLongitude];
            [self.mapView removeAnnotation:self->userPoint];
            self->userPoint = [[MKPointAnnotation alloc] init];
            self->userPoint.coordinate = self.userLocation.coordinate;
            self->userPoint.title = @"Your location";
            self->clientPoint = nil;
            [self.mapView addAnnotation:userPoint];
            
        } else if (self.clientLocation){
            self.clientLocation = [[CLLocation alloc] initWithLatitude:tapLatitude
                                                           longitude:tapLongitude];
            [self.mapView removeAnnotation:self->clientPoint];
            self->clientPoint = [[MKPointAnnotation alloc] init];
            self->clientPoint.coordinate = self.clientLocation.coordinate;
            self->clientPoint.title = @"Client location";
            self->userPoint = nil;
            [self.mapView addAnnotation:clientPoint];
        }
    }
}

- (IBAction)save:(UIBarButtonItem *)sender {

    //get CallVCr
    NSArray *vcsInNavigationController = self.navigationController.viewControllers;
    NSInteger countOfVCrs = vcsInNavigationController.count;
    CallVCr *callVCr = (CallVCr*) [vcsInNavigationController objectAtIndex:(countOfVCrs-2)];
    
    //make changes to context and get new place name
    if (self.userLocation){
        double latitude = self->userPoint.coordinate.latitude;
        double longitude = self->userPoint.coordinate.longitude;
        callVCr.callToEdit.userLatitude = latitude;
        callVCr.callToEdit.userLongitude = longitude;
        callVCr.userLocationUpdatedByUser = YES;
        callVCr.clientLocationUpdatedByUser = NO;

    } else if (self.clientLocation){
        double latitude = self->clientPoint.coordinate.latitude;
        double longitude = self->clientPoint.coordinate.longitude;
        callVCr.callToEdit.clientLatitude = latitude;
        callVCr.callToEdit.clientLongitude = longitude;
        callVCr.clientLocationUpdatedByUser = YES;
        callVCr.userLocationUpdatedByUser = NO;
    }
    
    //save context dismiss
    AppDelegate *appDelegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *viewContext = appDelegate.persistentContainer.viewContext;
    NSError *error;
    if (![viewContext save:&error]){
        NSLog(@"Error while saving context: %@", [error userInfo]);
    };
    
    //disiss MapVC
    [self.navigationController popViewControllerAnimated:YES];
}
    
@end
