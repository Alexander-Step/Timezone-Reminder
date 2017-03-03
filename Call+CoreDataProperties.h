//
//  Call+CoreDataProperties.h
//  
//
//  Created by Alexander on 01.03.17.
//
//

#import "Call+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface Call (CoreDataProperties)

+ (NSFetchRequest<Call *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *clientAddressString;
@property (nullable, nonatomic, copy) NSDate *clientDate;
@property (nonatomic) double clientLatitude;
@property (nonatomic) double clientLongitude;
@property (nonatomic) int64_t clientSecondsFromGMT;
@property (nullable, nonatomic, copy) NSString *clientWeather;
@property (nullable, nonatomic, copy) NSString *textInfo;
@property (nullable, nonatomic, copy) NSString *userAddressString;
@property (nullable, nonatomic, copy) NSDate *userDate;
@property (nonatomic) double userLatitude;
@property (nonatomic) double userLongitude;
@property (nonatomic) int64_t userSecondsFromGMT;
@property (nullable, nonatomic, copy) NSString *userWeather;
@property (nullable, nonatomic, copy) NSString *userWeatherIconString;
@property (nullable, nonatomic, copy) NSString *clientWeatherIconString;

@end

NS_ASSUME_NONNULL_END
