//
//  BeaconConfigViewController.m
//  iBeaconExperiments
//
//  Created by Lincoln Fitzsimons on 16/06/2014.
//  Copyright (c) 2014 DiUS. All rights reserved.
//

#import "BeaconConfigViewController.h"

@interface BeaconConfigViewController ()

@end

@implementation BeaconConfigViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Connect to beacon
    if(self.beacon) {
        self.beacon.delegate = self;
        [self.beacon connectToBeacon];
    }
}

#pragma mark - ESTBeacon Delegate
- (void)beaconConnectionDidSucceeded:(ESTBeacon *)beacon
{
    // Update labels
}

- (void)beaconConnectionDidFail:(ESTBeacon *)beacon withError:(NSError *)error
{
    // Show message and go back
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
