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

@protocol WeatherClientDelegate;

@interface WeatherClient : AFHTTPSessionManager

@property (nonatomic, weak) id <WeatherClientDelegate> delegate;

+ (WeatherClient*)sharedWeatherClient;
- (instancetype)initWithBaseURL:(NSURL*) url;
- (void)updateWeatherAtLocation:(CLLocation*)location forDate:(NSDate*)date forCall:(Call*)call forWho:(NSString*)who; //who="user" or "client"

@end

@protocol WeatherClientDelegate <NSObject>
@optional
- (void) weatherClient:(WeatherClient*)client didUpdateWithWeather:(id)weather forCall:(Call*)call forWho:(NSString*)who;
- (void)weatherClient:(WeatherClient*)client didFailWithError:(NSError*)error;

@end
