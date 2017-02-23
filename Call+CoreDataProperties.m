//
//  Call+CoreDataProperties.m
//  Timezone Reminder
//
//  Created by Alexander on 20.02.17.
//  Copyright © 2017 AlexanderStepanishin. All rights reserved.
//

#import "Call+CoreDataProperties.h"

@implementation Call (CoreDataProperties)

+ (NSFetchRequest<Call *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Call"];
}

@dynamic clientDate;
@dynamic clientWeather;
@dynamic textInfo;
@dynamic userDate;
@dynamic userWeather;
@dynamic userSecondsFromGMT;
@dynamic clientSecondsFromGMT;
@dynamic userLatitude;
@dynamic userLongitude;
@dynamic clientLatitude;
@dynamic clientLongitude;

@end
