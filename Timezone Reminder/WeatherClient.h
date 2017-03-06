//
//  WeatherClient.h
//  Timezone Reminder
//
//  Created by Alexander on 01.03.17.
//  Copyright © 2017 AlexanderStepanishin. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "CLLocation+APTimeZones.h"
#import "CallVCr.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol WeatherClientDelegate;

@interface WeatherClient : AFHTTPSessionManager

NS_ASSUME_NONNULL_BEGIN

@property (nonatomic, weak, nullable) id <WeatherClientDelegate> delegate;
@property (nonnull, strong) UIAlertController *alert;

+ (WeatherClient*)sharedWeatherClient;
- (instancetype)initWithBaseURL:(nullable NSURL*) url;
- (void)updateWeatherAtLocation:(CLLocation*)location forDate:(NSDate*)date forCall:(Call*)call forWho:( NSString*)who; //who="user" or "client"
NS_ASSUME_NONNULL_END
@end

@protocol WeatherClientDelegate <NSObject>
@optional
- (void) weatherClient:(nullable WeatherClient*)client didUpdateWithWeather:(nullable id)weather forCall:(nullable Call*)call forWho:(nullable NSString*)who;
- (void)weatherClient:(nullable WeatherClient*)client didFailWithError:(nullable NSError*)error;


@end
