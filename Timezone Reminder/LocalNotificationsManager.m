//
//  LocalNotificationsManager.m
//  Timezone Reminder
//
//  Created by Alexander on 02.03.17.
//  Copyright © 2017 AlexanderStepanishin. All rights reserved.
//

#import "LocalNotificationsManager.h"

@implementation LocalNotificationsManager

+ (LocalNotificationsManager*) sharedLocalNotificationsManager
{
    static LocalNotificationsManager* _sharedLocalNotificationsManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedLocalNotificationsManager = [[self alloc] init];
    });
    return _sharedLocalNotificationsManager;
}

- (instancetype) init
{
    self = [super init];
    return self;
}

- (void) addNotificationsForCalls: (NSArray*) calls
{
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    
    //add new notifications
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    for (Call* iterCall in calls){
        content.title = @"In 20 minutes you wanted to:";
        content.body = iterCall.textInfo;
        content.sound = [UNNotificationSound defaultSound];
        
        //calculate time interval for this call notification
        NSDate *now = [NSDate date];
        NSDate *notificationDate = iterCall.userDate;
        NSTimeInterval timeIntervalForTrigger = ([notificationDate timeIntervalSinceDate:now] - (60*20));

        
        if (timeIntervalForTrigger > 0){
            UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:timeIntervalForTrigger repeats:NO];
            NSUInteger rnd = arc4random()%999999999;
            NSString *idString = [NSString stringWithFormat:@"%ld",rnd];
            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:idString content:content trigger:trigger];
            [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                NSLog(@"Notification added.");
            }];
            
        }
        
    }
}

@end
