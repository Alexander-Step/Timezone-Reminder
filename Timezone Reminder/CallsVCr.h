//
//  CallsTVCr.h
//  Timezone Reminder
//
//  Created by Alexander on 17.02.17.
//  Copyright © 2017 AlexanderStepanishin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CallTVCell.h"
#import "MapVC.h"
#import "Call+CoreDataProperties.h"
#import "CallVCr.h"

@interface CallsVCr : UIViewController <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@end
