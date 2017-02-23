//
//  Call+CoreDataProperties.h
//  Timezone Reminder
//
//  Created by Alexander on 20.02.17.
//  Copyright © 2017 AlexanderStepanishin. All rights reserved.
//

#import "Call+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Call (CoreDataProperties)

+ (NSFetchRequest<Call *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *clientDate;
@property (nullable, nonatomic, copy) NSString *clientWeather;
@property (nullable, nonatomic, copy) NSString *textInfo;
@property (nullable, nonatomic, copy) NSDate *userDate;
@property (nullable, nonatomic, copy) NSString *userWeather;
@property (nonatomic) int64_t userSecondsFromGMT;
@property (nonatomic) int64_t clientSecondsFromGMT;
@property (nonatomic) double userLatitude;
@property (nonatomic) double userLongitude;
@property (nonatomic) double clientLatitude;
@property (nonatomic) double clientLongitude;

@end

NS_ASSUME_NONNULL_END
