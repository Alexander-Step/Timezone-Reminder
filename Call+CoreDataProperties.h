//
//  Call+CoreDataProperties.h
//  Timezone Reminder
//
//  Created by Alexander on 19.02.17.
//  Copyright © 2017 AlexanderStepanishin. All rights reserved.
//

#import "Call+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Call (CoreDataProperties)

+ (NSFetchRequest<Call *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSDate *clientDate;
@property (nullable, nonatomic, copy) NSString *clientStringPlace;
@property (nullable, nonatomic, copy) NSString *clientWeather;
@property (nullable, nonatomic, copy) NSString *textInfo;
@property (nullable, nonatomic, copy) NSDate *userDate;
@property (nullable, nonatomic, copy) NSString *userStringPlace;
@property (nullable, nonatomic, copy) NSString *userWeather;
@property (nonatomic) int32_t userSecondsFromGMT;
@property (nonatomic) int32_t clientSecondsFromGMT;

@end

NS_ASSUME_NONNULL_END
