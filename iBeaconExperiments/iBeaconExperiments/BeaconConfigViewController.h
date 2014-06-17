//
//  BeaconConfigViewController.h
//  iBeaconExperiments
//
//  Created by Lincoln Fitzsimons on 16/06/2014.
//  Copyright (c) 2014 DiUS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ESTBeacon.h>
#import "BaseExperimentViewController.h"

@interface BeaconConfigViewController : BaseExperimentViewController <ESTBeaconDelegate>

@property (strong, nonatomic) ESTBeacon *beacon;

@end
