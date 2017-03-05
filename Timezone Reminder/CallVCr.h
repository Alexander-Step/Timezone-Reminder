//
//  CallVC.h
//  Timezone Reminder
//
//  Created by Alexander on 17.02.17.
//  Copyright © 2017 AlexanderStepanishin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CallTVCell.h"
#import "Call+CoreDataProperties.h"
#import <CoreLocation/CoreLocation.h>
#import "APTimeZones.h"
#import "CLLocation+APTimeZones.h"
#import "AppDelegate.h"
#import <MapKit/MapKit.h>
#import "MapVC.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <Contacts/Contacts.h>
#import "AFNetworking.h"
#import "WeatherClient.h"
#import "UIImageView+AFNetworking.h"
#import "LocalNotificationsManager.h"
#import "UIImage+resize.h"

@protocol WeatherClientDelegate;

@interface CallVCr : UIViewController <CLLocationManagerDelegate, UITextViewDelegate, WeatherClientDelegate>

@property (nonatomic) BOOL isNewCall;
@property (nonatomic, strong) Call *callToEdit;
@property (nonatomic, strong) CLLocation *userLocation;
@property (nonatomic, strong) CLLocation *clientLocation;
@property (nonatomic) BOOL userLocationUpdatedByUser;
@property (nonatomic) BOOL clientLocationUpdatedByUser;

@end
