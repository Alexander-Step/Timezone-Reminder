//
//  CallVC.h
//  Timezone Reminder
//
//  Created by Alexander on 17.02.17.
//  Copyright © 2017 AlexanderStepanishin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CallTVCell.h"
#import "PlaceVC.h"
#import "Call+CoreDataProperties.h"
#import <CoreLocation/CoreLocation.h>
#import "APTimeZones.h"
#import "CLLocation+APTimeZones.h"
#import "AppDelegate.h"

@interface CallVCr : UIViewController <CLLocationManagerDelegate>

@property (nonatomic) BOOL isNewCall;
@property (nonatomic, strong) Call *callToEdit;

@end
