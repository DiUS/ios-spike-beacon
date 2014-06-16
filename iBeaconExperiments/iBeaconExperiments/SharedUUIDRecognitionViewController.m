//
//  SharedUUIDRecognitionViewController.m
//  iBeaconExperiments
//
//  Created by Brenton Crowley on 12/06/2014.
//  Copyright (c) 2014 DiUS. All rights reserved.
//

#import "SharedUUIDRecognitionViewController.h"

@interface SharedUUIDRecognitionViewController ()

@property (nonatomic) NSArray *beacons;

@end

@implementation SharedUUIDRecognitionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerBeaconRegionWithUUID:[self genericUUID]
                         andIdentifier:@"estimoteS"];
}

- (NSString *)title
{
    return @"Shared UUID Recognition";
}

#pragma mark - Public

#pragma mark - Private

- (NSArray *)beacons
{
    if (!_beacons)
        _beacons = [NSArray array];
    
    return _beacons;
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region
{
    self.beacons = beacons;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.beacons.count;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"UUID: %@",
            [[self genericUUID] UUIDString]];
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
    
    CLBeacon *beacon = self.beacons[indexPath.row];
    
    NSDictionary *beaconData = self.estimoteBeaconData[
                                                       [self keyForUUID:beacon.proximityUUID.UUIDString
                                                                  major:beacon.major.integerValue
                                                                  minor:beacon.minor.integerValue]
                                                       ];
    
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@",
                           beaconData ? beaconData[kColourString] : @"Beacon"];
    
    cell.detailTextLabel.text =
    [NSString stringWithFormat:@"Major: %ld, Minor: %ld, RSSI: %ld, Acc: %f",
     (long)beacon.major.integerValue,
     (long)beacon.minor.integerValue,
     (long)beacon.rssi,
     beacon.accuracy
     ];
    
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CLBeacon *beacon = self.beacons[indexPath.row];
    
    NSDictionary *beaconData = self.estimoteBeaconData[
                                                       [self keyForUUID:beacon.proximityUUID.UUIDString
                                                                  major:beacon.major.integerValue
                                                                  minor:beacon.minor.integerValue]
                                                       ];
    
    cell.contentView.backgroundColor = beaconData[kUIColour];
}

@end
