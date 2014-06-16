//
//  AveragerViewController.h
//  iBeaconExperiments
//
//  Created by Brenton Crowley on 13/06/2014.
//  Copyright (c) 2014 DiUS. All rights reserved.
//

/*
    Rather than react to readings every time CLLocation manager updates,
    it would be better to create averages to have a more stable reading.
    
    This class will attempt to average readings over a 5 second interval
    reducing the jerkiness of unknown readings.
*/

#import <UIKit/UIKit.h>
#import "BaseExperimentViewController.h"

@interface AveragerViewController : BaseExperimentViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
