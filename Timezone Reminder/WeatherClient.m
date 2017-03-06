//
//  WeatherClient.m
//  Timezone Reminder
//
//  Created by Alexander on 01.03.17.
//  Copyright © 2017 AlexanderStepanishin. All rights reserved.
//

#import "WeatherClient.h"

static NSString * const WorldWeatherOnlineAPIKey = @"API KEY";
static NSString * const WorldWeatherOnlineURLString = @"https://api.worldweatheronline.com/premium/v1/";
//static NSString * const WorldWeatherOnlineURLString = @"http://api.worldweatheronline.com/free/v1/";

@implementation WeatherClient

+ (WeatherClient*)sharedWeatherClient
{
    static WeatherClient* _sharedWeatherClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedWeatherClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:WorldWeatherOnlineURLString]];
    });
    
    return _sharedWeatherClient;
}

- (instancetype)initWithBaseURL:(NSURL*) url
{
    self = [super initWithBaseURL:url];
    
    if (self){
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    return self;
}

- (void)updateWeatherAtLocation:(CLLocation*)location forDate:(NSDate*)date forCall:(Call*)call forWho:(NSString*)who //who="user" or "client"
{
    if ([WorldWeatherOnlineAPIKey isEqualToString:@"API KEY"]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Input API KEY" message:@"Please, input your API key for World Weather Online API to use it's functions" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:actionOK];
        if ([self.delegate respondsToSelector:@selector(presentViewController:animated:completion:)]){
            CallVCr *callVCrPointer = (CallVCr*) self.delegate;
            [callVCrPointer presentViewController:alert animated:YES completion:nil];
        }
        
    } else {
        //build parameters
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.dateFormat = @"yyyy-MM-dd";
        formatter.timeZone = [[APTimeZones sharedInstance] timeZoneWithLocation:location];
        NSString *requestDateString = [formatter stringFromDate:date];
        
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
        parameters[@"q"] = [NSString stringWithFormat:@"%f,%f",location.coordinate.latitude,location.coordinate.longitude];
        parameters[@"format"]=@"json";
        parameters[@"key"] = WorldWeatherOnlineAPIKey;
        parameters[@"date"] = requestDateString;
        
        //start a fetch
        __weak Call* weakCall = call;
        
        [self GET:@"weather.ashx" parameters:parameters progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
              if ([self.delegate respondsToSelector:@selector(weatherClient:didUpdateWithWeather:forCall:forWho:)]){
                  [self.delegate weatherClient:self didUpdateWithWeather:responseObject forCall:weakCall forWho:who];
              }
              
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            if ([self.delegate respondsToSelector:@selector(weatherClient:didFailWithError:)]){
                [self.delegate weatherClient:self didFailWithError:error];
            }
        }];
    }
}

@end
