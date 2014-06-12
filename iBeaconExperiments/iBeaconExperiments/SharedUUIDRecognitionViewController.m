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
    
    [self registerBeaconRegionWithUUID:[self genericUUID]
                         andIdentifier:@"estimote"];
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellID];
    }
    
    CLBeacon *beacon = self.beacons[indexPath.row];
    
    
    cell.textLabel.text = [NSString stringWithFormat:@"Beacon"];
    cell.detailTextLabel.text =
        [NSString stringWithFormat:@"Major: %d, Minor: %d",
            beacon.major.integerValue,
            beacon.minor.integerValue];
    
    return cell;
}

#pragma mark - UITableViewDelegate

@end