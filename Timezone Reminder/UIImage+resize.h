//
//  UIImage+resize.h
//  Hashtag Alarm
//
//  Created by Alexander on 03.03.17.
//  Copyright © 2017 AlexanderStepanishin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (resize) 

- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize;

@end
