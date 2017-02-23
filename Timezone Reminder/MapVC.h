//
//  MapVC.h
//  Timezone Reminder
//
//  Created by Alexander on 21.02.17.
//  Copyright © 2017 AlexanderStepanishin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Call+CoreDataProperties.h"
#import <MapKit/MapKit.h>
#import "CallsVCr.h"

@interface MapVC : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) CLLocation *userLocation;
@property (strong, nonatomic) CLLocation *clientLocation;

@end
