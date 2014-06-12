//
//  BaseExperimentViewController.m
//  iBeaconExperiments
//
//  Created by Brenton Crowley on 12/06/2014.
//  Copyright (c) 2014 DiUS. All rights reserved.
//

#import "BaseExperimentViewController.h"

@interface BaseExperimentViewController ()

@end

const NSString *kGreen = @"green";
const NSString *kBlue = @"blue";
const NSString *kPurple = @"purple";
const NSString *kUUID = @"uuid";
const NSString *kMajor = @"major";
const NSString *kMinor = @"minor";

@implementation BaseExperimentViewController

#pragma mark - Overrides

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Public

- (NSUUID *)genericUUID
{
    return [[NSUUID alloc]
            initWithUUIDString:@"b9407f30-f5f8-466e-aff9-25556b57fe6d"];
}

- (CLLocationManager *)locationManager
{
    if (!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDelegate:self];
    }
    
    return _locationManager;
}

- (NSDictionary *)estimoteBeaconData
{
    if (!_estimoteBeaconData)
    {
        NSString *uuid = [[self genericUUID] UUIDString];
        
        NSDictionary *green = [NSDictionary dictionaryWithObjects:@[uuid,
                                                                    @50730,
                                                                    @33558
                                                                    ]
                                                          forKeys:@[kUUID,
                                                                    kMajor,
                                                                    kMinor]
                               ];
        
        NSDictionary *purple = [NSDictionary dictionaryWithObjects:@[uuid,
                                                                    @15295,
                                                                    @49236
                                                                    ]
                                                          forKeys:@[kUUID,
                                                                    kMajor,
                                                                    kMinor]
                                ];
        
        NSDictionary *blue = [NSDictionary dictionaryWithObjects:@[uuid,
                                                                    @23491,
                                                                    @36886
                                                                    ]
                                                          forKeys:@[kUUID,
                                                                    kMajor,
                                                                    kMinor]
                              ];
        
        _estimoteBeaconData = [NSDictionary dictionaryWithObjects:@[green,
                                                                    purple,
                                                                    blue]
                                                          forKeys:@[kGreen,
                                                                    kPurple,
                                                                    kBlue]
                               ];
    }
    
    return _estimoteBeaconData;
}

- (void)registerBeaconRegionWithUUID:(NSUUID *)proximityUUID
                       andIdentifier:(NSString*)identifier
{
    
    // Create the beacon region to be monitored.
    CLBeaconRegion *beaconRegion = [[CLBeaconRegion alloc]
                                    initWithProximityUUID:proximityUUID
                                    identifier:identifier];
    
    // Register the beacon region with the location manager.
    [self.locationManager startMonitoringForRegion:beaconRegion];
}

- (void)deregisterBeaconRegionByIdentifier:(NSString*)identifier
{
    if (self.locationManager.monitoredRegions.count < 1)
        return;
    
    for (CLBeaconRegion *region in self.locationManager.monitoredRegions)
    {
        if ([region.identifier isEqualToString:identifier])
            [self.locationManager stopMonitoringForRegion:region];
    }
}

#pragma mark - Private

- (void)invalidate
{
    // override
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region
{
    DLog(@"Did enter region");
}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region
{
    DLog(@"Did exit region");
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    DLog(@"Did fail");
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region
{
//    DLog(@"Did Range Beacons");
    
}

- (void)locationManager:(CLLocationManager *)manager
    didStartMonitoringForRegion:(CLRegion *)region
{
    DLog(@"Did start monitoring region. Total regions: %d",
         manager.monitoredRegions.count);
    
    [manager requestStateForRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager
        rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region
              withError:(NSError *)error
{
    DLog(@"Ranging beacons did fail");
}

- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state
              forRegion:(CLRegion *)region
{
    DLog(@"State for region: %d", state);
    
    switch (state)
    {
        case CLRegionStateInside:
            [manager startRangingBeaconsInRegion:(CLBeaconRegion*)region];
            break;
    
        default:
            if ([self.locationManager.rangedRegions containsObject:region])
                [manager stopRangingBeaconsInRegion:(CLBeaconRegion *)region];
            break;
    }
}


@end
