//
//  Call+CoreDataProperties.m
//  
//
//  Created by Alexander on 01.03.17.
//
//

#import "Call+CoreDataProperties.h"

@implementation Call (CoreDataProperties)

+ (NSFetchRequest<Call *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Call"];
}

@dynamic clientAddressString;
@dynamic clientDate;
@dynamic clientLatitude;
@dynamic clientLongitude;
@dynamic clientSecondsFromGMT;
@dynamic clientWeather;
@dynamic textInfo;
@dynamic userAddressString;
@dynamic userDate;
@dynamic userLatitude;
@dynamic userLongitude;
@dynamic userSecondsFromGMT;
@dynamic userWeather;
@dynamic userWeatherIconString;
@dynamic clientWeatherIconString;

@end
