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
        
        NSDictionary *green = [NSDictionary dictionaryWithObjects:@[
                                            kGreen,
                                            [UIColor colorWithRed:127.0/255.0f
                                                            green:255.0/255.0f
                                                             blue:154.0/255.0f
                                                            alpha:1.0f],
                                            uuid,
                                            @50730,
                                            @33558
                                            ]
                                  forKeys:@[kColourString,
                                            kUIColour,
                                            kUUID,
                                            kMajor,
                                            kMinor]
                               ];
        
        NSDictionary *purple = [NSDictionary dictionaryWithObjects:@[
                                             kPurple,
                                             [UIColor colorWithRed:171.0/255.0f
                                                             green:121.0/255.0f
                                                              blue:238.0/255.0f
                                                             alpha:1.0f],
                                             uuid,
                                            @15295,
                                            @49236
                                            ]
                                  forKeys:@[kColourString,
                                            kUIColour,
                                            kUUID,
                                            kMajor,
                                            kMinor]
                                ];
        
        NSDictionary *blue = [NSDictionary dictionaryWithObjects:@[
                                           kBlue,
                                           [UIColor colorWithRed:133.0/255.0f
                                                           green:222.0/255.0f
                                                            blue:255.0/255.0f
                                                           alpha:1.0f],
                                           uuid,
                                            @23491,
                                            @36886
                                            ]
                                  forKeys:@[kColourString,
                                            kUIColour,
                                            kUUID,
                                            kMajor,
                                            kMinor]
                              ];
        
        NSString *greenKey = [self keyForUUID:green[kUUID]
                                major:((NSNumber *)green[kMajor]).integerValue
                                minor:((NSNumber *)green[kMinor]).integerValue
                              ];

        NSString *purpleKey = [self keyForUUID:purple[kUUID]
                            major:((NSNumber *)purple[kMajor]).integerValue
                            minor:((NSNumber *)purple[kMinor]).integerValue
                              ];
        
        NSString *blueKey = [self keyForUUID:blue[kUUID]
                                major:((NSNumber *)blue[kMajor]).integerValue
                                minor:((NSNumber *)blue[kMinor]).integerValue
                               ];
        
        _estimoteBeaconData = [NSDictionary dictionaryWithObjects:@[green,
                                                                    purple,
                                                                    blue]
                                                          forKeys:@[greenKey,
                                                                    purpleKey,
                                                                    blueKey]
                               ];
    }
    
    return _estimoteBeaconData;
}

- (NSString *)keyForUUID:(NSString *)uuid
                   major:(NSInteger)major
                   minor:(NSInteger)minor
{
    NSString *key = [NSString stringWithFormat:@"%@%ld%ld",
                         uuid,
                         (long)major,
                         (long)minor];
    
    return key;
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

- (NSString *)proximityStringForIndex:(NSInteger)index
{
    NSString *string = @"";
    
    switch (index) {
        case CLProximityImmediate:
            string = @"Immediate";
            break;
            
        case CLProximityFar:
            string = @"Far";
            break;
            
        case CLProximityNear:
            string = @"Near";
            break;
            
        case CLProximityUnknown:
            string = @"Unknown";
            break;
            
        default:
            string = @"Out of range";
            break;
    }
    
    return string;
}

#pragma mark - Private

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
    
}

- (void)locationManager:(CLLocationManager *)manager
    didStartMonitoringForRegion:(CLRegion *)region
{
    DLog(@"Did start monitoring region. Total regions: %lu",
         (unsigned long)manager.monitoredRegions.count);
    
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
