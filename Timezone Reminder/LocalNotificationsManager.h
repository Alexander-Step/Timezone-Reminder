//
//  LocalNotificationsManager.h
//  Timezone Reminder
//
//  Created by Alexander on 02.03.17.
//  Copyright © 2017 AlexanderStepanishin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Call+CoreDataProperties.h"
#import <UserNotifications/UserNotifications.h>

@interface LocalNotificationsManager : NSObject

+ (LocalNotificationsManager*) sharedLocalNotificationsManager;
- (instancetype) init;

- (void) addNotificationsForCalls: (NSArray*) calls;

@end
