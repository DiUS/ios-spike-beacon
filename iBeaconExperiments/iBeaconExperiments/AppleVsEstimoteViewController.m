//
//  AppleVsEstimoteViewController.m
//  iBeaconExperiments
//
//  Created by Brenton Crowley on 16/06/2014.
//  Copyright (c) 2014 DiUS. All rights reserved.
//

#import "AppleVsEstimoteViewController.h"
#import <EstimoteSDK/ESTBeaconManager.h>
#import <EstimoteSDK/ESTBeacon.h>
#import <EstimoteSDK/ESTBeaconRegion.h>

@interface AppleVsEstimoteViewController () <ESTBeaconManagerDelegate>

@property (nonatomic) ESTBeaconManager *estBeaconManager;
@property (nonatomic) NSArray *sections;
@property (nonatomic) NSMutableArray *clBeacons;
@property (nonatomic) NSMutableArray *estBeacons;

@end

@implementation AppleVsEstimoteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.estBeaconManager = [[ESTBeaconManager alloc] init];
    self.estBeaconManager.delegate = self;
    
    // create sample region object (you can additionaly pass major / minor values)
    ESTBeaconRegion* region = [[ESTBeaconRegion alloc]
                               initWithProximityUUID:[self genericUUID]
                               identifier:@"sdkBeacons"];
    
    // start looking for estimtoe beacons in region
    // when beacon ranged beaconManager:didRangeBeacons:inRegion: invoked
    [self.estBeaconManager startRangingBeaconsInRegion:region];
    
    [self registerBeaconRegionWithUUID:[self genericUUID]
                         andIdentifier:@"estimote"];
    

}

#pragma mark - ESTBeaconManagerDataSource

-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region
{
    [self.estBeacons removeAllObjects];
    [self.estBeacons addObjectsFromArray:beacons];
    
    [self.tableView reloadData];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region
{

    [self.clBeacons removeAllObjects];
    [self.clBeacons addObjectsFromArray:beacons];
    
    [self.tableView reloadData];
}

#pragma mark - Private

- (NSMutableArray *)estBeacons
{
    if (!_estBeacons)
        _estBeacons = [NSMutableArray array];
    
    return _estBeacons;
}

- (NSMutableArray *)clBeacons
{
    if (!_estBeacons)
        _estBeacons = [NSMutableArray array];
    
    return _estBeacons;
}

- (NSArray *)sections
{
    if (!_sections)
    {
        _sections = @[self.clBeacons, self.estBeacons];
    }
    
    return _sections;
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"Core Loction API";
    else if (section == 1)
        return @"Estimote SDK";
    else
        return @"Unknown";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *beacons = self.sections[section];
    
    return beacons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellID";
    
    UITableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell)
    {
        cell = [[UITableViewCell alloc]
                initWithStyle:UITableViewCellStyleSubtitle
                reuseIdentifier:cellID];
    }
    
    NSArray *beacons = self.sections[indexPath.section];
    NSString *beaconText = nil;
    NSString *beaconMajor = nil;
    NSString *beaconMinor = nil;
    NSString *beaconRSSI = nil;
    NSString *beaconAccuracy = nil;
    
    if ([beacons[0] class] == [CLBeacon class])
    {
        //CLBeacon
        CLBeacon *beacon = beacons[indexPath.row];
        
        NSDictionary *beaconData = self.estimoteBeaconData[
                           [self keyForUUID:beacon.proximityUUID.UUIDString
                                      major:beacon.major.integerValue
                                      minor:beacon.minor.integerValue]
                           ];
        
        beaconText = [NSString stringWithFormat:@"%@",
                      beaconData ? beaconData[kColourString] : @"Beacon"];
        beaconMajor = [NSString stringWithFormat:@"%ld",
                       (long)beacon.major.integerValue];
        beaconMinor = [NSString stringWithFormat:@"%ld",
                       (long)beacon.minor.integerValue];
        beaconRSSI = [NSString stringWithFormat:@"%ld",
                       (long)beacon.rssi];
        beaconAccuracy = [NSString stringWithFormat:@"%f",
                       beacon.accuracy];
    }
    else if ([beacons[0] class] == [ESTBeacon class])
    {
        //ESTBeacon
        ESTBeacon *beacon = beacons[indexPath.row];
        
        NSDictionary *beaconData = self.estimoteBeaconData[
                               [self keyForUUID:beacon.proximityUUID.UUIDString
                                          major:beacon.major.integerValue
                                          minor:beacon.minor.integerValue]
                               ];
        
        beaconText = [NSString stringWithFormat:@"%@",
                      beaconData ? beaconData[kColourString] : @"Beacon"];
        beaconMajor = [NSString stringWithFormat:@"%ld",
                       (long)beacon.major.integerValue];
        beaconMinor = [NSString stringWithFormat:@"%ld",
                       (long)beacon.minor.integerValue];
        beaconRSSI = [NSString stringWithFormat:@"%ld",
                      (long)beacon.rssi];
        beaconAccuracy = [NSString stringWithFormat:@"%f",
                          beacon.distance.floatValue];
    }
    
    cell.textLabel.text = beaconText;
    
    cell.detailTextLabel.text =
    [NSString stringWithFormat:@"Major: %@, Minor: %@, RSSI: %@, Acc: %@",
                                                             beaconMajor,
                                                             beaconMinor,
                                                             beaconRSSI,
                                                             beaconAccuracy
                                                         ];
    
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *beacons = self.sections[indexPath.section];
    id beacon = (NSObject *)beacons[indexPath.row];
    
    if ([beacon respondsToSelector:@selector(proximityUUID)])
    {
        NSDictionary *beaconData = self.estimoteBeaconData[
                           [self keyForUUID:[[beacon proximityUUID] UUIDString]
                                      major:[beacon major].integerValue
                                      minor:[beacon minor].integerValue]
                           ];
        
        cell.contentView.backgroundColor = beaconData[kUIColour];
    }
}

@end
