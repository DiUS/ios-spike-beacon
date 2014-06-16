//
//  AveragerViewController.m
//  iBeaconExperiments
//
//  Created by Brenton Crowley on 13/06/2014.
//  Copyright (c) 2014 DiUS. All rights reserved.
//

#import "AveragerViewController.h"

@interface AveragerViewController ()

@property (nonatomic) NSMutableArray *beaconHistory;
@property (nonatomic) NSMutableDictionary *averagedBeacons;
@property (nonatomic) NSArray *rangedBeaconKeys;

@end

#define AVE_RANGE 5

@implementation AveragerViewController

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

- (NSMutableArray *)beaconHistory
{
    if (!_beaconHistory)
        _beaconHistory = [NSMutableArray array];
    
    return _beaconHistory;
}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region
{
    [self.beaconHistory insertObject:beacons atIndex:0];
    
    if (self.beaconHistory.count > AVE_RANGE)
        [self.beaconHistory removeLastObject];
    
    self.averagedBeacons = [NSMutableDictionary dictionary];
    
    for (NSArray *beaconGroup in self.beaconHistory)
    {
        for (CLBeacon *beacon in beaconGroup)
        {
            NSString *key = [self keyForUUID:beacon.proximityUUID.UUIDString
                                       major:beacon.major.integerValue
                                       minor:beacon.minor.integerValue];
            
            NSMutableDictionary *beaconData = self.averagedBeacons[key];
            
            if (!beaconData)
            {
                self.averagedBeacons[key] = beaconData =
                [NSMutableDictionary dictionary];
            }
            
            
            NSMutableArray *proximities = beaconData[kProximity];
            
            if (!proximities)
                beaconData[kProximity] = [NSMutableArray array];
            
            [beaconData[kProximity] insertObject:
             [NSNumber numberWithDouble:beacon.proximity]
                                    atIndex:0
             ];
            
            NSMutableArray *accuracies = beaconData[kAccuracy];
            
            if (!accuracies)
                beaconData[kAccuracy] = [NSMutableArray array];
            
            [beaconData[kAccuracy] addObject:
             [NSNumber numberWithDouble:beacon.accuracy]
             ];
            
            NSMutableArray *rssiers = beaconData[kRSSI];
            
            if (!rssiers)
                beaconData[kRSSI] = [NSMutableArray array];
            
            [beaconData[kRSSI] addObject:
             [NSNumber numberWithDouble:beacon.rssi]
             ];
        }
    }
    
    self.rangedBeaconKeys = [self.averagedBeacons allKeys];
    
    [self.tableView reloadData];
}


- (double)aveValueForKey:(NSString *)key
               forBeacon:(NSMutableDictionary *)beaconDict
{
    NSMutableArray *list = beaconDict[key];
    
    [list sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber *prox1 = (NSNumber *)obj1;
        NSNumber *prox2 = (NSNumber *)obj2;
        
        return [prox1 compare:prox2];
    }];
    
    NSUInteger outlierPadding = list.count * 0.1f;
    NSArray *sample = [list subarrayWithRange:NSMakeRange(
                                                          outlierPadding,
                                                          list.count - (outlierPadding * 2))
                       ];
    
    double ave = [[sample valueForKeyPath:@"@avg.doubleValue"] doubleValue];
    
    return ave;
}

- (int)modeProximityForBeaconDict:(NSDictionary *)beaconDict
{
    int proximity = CLProximityUnknown;
    
    NSCountedSet *proxCount = [[NSCountedSet alloc]
                               initWithArray:beaconDict[kProximity]];
    
    NSNumber *modeFrequency;
    NSUInteger highest = 0;
    for (NSNumber *num in proxCount)
    {
        if ([proxCount countForObject:num] > highest)
        {
            highest = [proxCount countForObject:num];
            modeFrequency = num;
        }
    }
    
    proximity = modeFrequency.intValue;
    
    return proximity;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return self.rangedBeaconKeys.count;
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
    
    NSString *beaconKey = self.rangedBeaconKeys[indexPath.row];
    NSMutableDictionary *beaconDict = self.averagedBeacons[beaconKey];
    
    cell.textLabel.text = [NSString stringWithFormat:@"Ave Prox: %@ %ld",
                           [self proximityStringForIndex:
                            floor([self
                                   modeProximityForBeaconDict:beaconDict])],
                           (long)floor([self
                                        modeProximityForBeaconDict:beaconDict])
                           
                           ];
    cell.detailTextLabel.text =
    [NSString stringWithFormat:@"Ave Acc: %f, Ave RSSI: %f",
     [self aveValueForKey:kAccuracy
                forBeacon:beaconDict],
     [self aveValueForKey:kRSSI
                forBeacon:beaconDict]
     ];
    
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *beaconKey = self.rangedBeaconKeys[indexPath.row];
    
    NSDictionary *beaconData = self.estimoteBeaconData[beaconKey];
    
    cell.contentView.backgroundColor = beaconData[kUIColour];
}

@end
