//
//  RecordDataViewController.m
//  iBeaconExperiments
//
//  Created by Brenton Crowley on 16/06/2014.
//  Copyright (c) 2014 DiUS. All rights reserved.
//

#import "RecordDataViewController.h"
#import <EstimoteSDK/ESTBeaconManager.h>
#import <EstimoteSDK/ESTBeacon.h>
#import <EstimoteSDK/ESTBeaconRegion.h>
#import <ESTBeaconRegion.h>
#import "BeaconConfigViewController.h"
#import <MBProgressHUD.h>

@interface RecordDataViewController () <ESTBeaconManagerDelegate,
ESTBeaconDelegate, UIActionSheetDelegate>

@property (nonatomic) ESTBeaconManager *estBeaconManager;
@property (nonatomic) NSArray *sections;
@property (nonatomic) NSMutableArray *estBeacons;
@property (nonatomic) BOOL isRecording;
@property (nonatomic) NSTimer *recordingTimer;
@property (nonatomic) NSDate *recordDate;
@property (nonatomic, weak) UITextField *focussedField;
@property (nonatomic) NSMutableString *recordedData;
@property (nonatomic) NSMutableArray *beaconsForSync;
@property (nonatomic) ESTBeaconRegion *region;

@end

@implementation RecordDataViewController

#define DEFAULT_INTERVAL 1.0

#pragma mark - Overrides

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = self.header;
    
    self.estBeaconManager = [[ESTBeaconManager alloc] init];
    self.estBeaconManager.delegate = self;
    
    self.region = [[ESTBeaconRegion alloc]
                        initWithProximityUUID:[self genericUUID]
                        identifier:@"sdkBeacons"];
    
    // start looking for estimtoe beacons in region
    // when beacon ranged beaconManager:didRangeBeacons:inRegion: invoked
    
    self.isRecording = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.estBeaconManager startRangingBeaconsInRegion:self.region];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.estBeaconManager stopRangingBeaconsInRegion:self.region];
}

#pragma mark - Private

- (UIBarButtonItem *)barButtonItemForStyle:(NSInteger)style
{
//    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc]
//                                        initWithBarButtonSystemItem:style
//                                        target:self
//                                        action:@selector(didPressRightBarButtonItem:)];
    
    NSString *title = nil;
    
    switch (style) {
        case UIBarButtonSystemItemSave:
            title = @"Record";
            break;
        case UIBarButtonSystemItemStop:
            title = @"Stop";
            break;
        default:
            title = @"Done";
            break;
    }
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:title
                                 style:UIBarButtonItemStylePlain
                                target:self
                                action:@selector(didPressRightBarButtonItem:)];
    
    return item;
}

- (NSMutableArray *)estBeacons
{
    if (!_estBeacons)
        _estBeacons = [NSMutableArray array];
    
    return _estBeacons;
}

- (NSArray *)sections
{
    if (!_sections)
    {
        _sections = @[self.estBeacons];
    }
    
    return _sections;
}

- (void)setIsRecording:(BOOL)isRecording
{
    _isRecording = isRecording;
    
    UIBarButtonItem *buttonItem = nil;
    
    if (_isRecording)
    {
        buttonItem = [self barButtonItemForStyle:UIBarButtonSystemItemStop];
        
        // connect to each of the beacons
        // retrieve the txPower value and store that in a dict with
        // major/minor id
        
        // once complete setup the mutable string for recording
        // start timer
        [self startRecording];
    }
    else
    {
        buttonItem = [self barButtonItemForStyle:UIBarButtonSystemItemSave];
        if (self.recordingTimer)
            [self stopRecording];
    }
    
    self.navigationItem.rightBarButtonItem = buttonItem;
    
}

- (void)startRecording
{
    
    self.elapsedTimeField.text = [NSString stringWithFormat:@"0"];
    self.recordDate = [NSDate date];
    self.recordingTimer = [NSTimer scheduledTimerWithTimeInterval:DEFAULT_INTERVAL
                                              target:self
                                            selector:@selector(timerInterval:)
                                            userInfo:nil
                                             repeats:YES];
    // Init with header
    self.recordedData = [NSMutableString
                 stringWithFormat:@"%@, %@, %@, %@, %@, %@, %@, %@, %@, %@\n",
                         @"UUID",
                         @"Major",
                         @"Minor",
                         @"Colour",
                         @"Time",
                         @"Proximity",
                         @"RSSI",
                         @"Accuracy",
                         @"Distance From Beacon (Real World)",
                         @"txPower"
                         ];
    
}

- (void)stopRecording
{
    if (self.recordingTimer)
        [self.recordingTimer invalidate];
    
    NSString *dateString = [self.recordDate description];
    
    NSString *filename = [NSString stringWithFormat:@"%@_%@",
                          self.filenameField.text,
                          dateString
                          ];
    
    [self writeCSVString:[self.recordedData copy] forFilename:filename];
}

- (void)logData
{
    for (ESTBeacon *beacon in self.estBeacons)
    {
        [self addDataRowForBeacon:beacon];
    }
}

- (void)addDataRowForBeacon:(ESTBeacon *)beacon
{
    NSString *key = [self keyForUUID:beacon.proximityUUID.UUIDString
                               major:beacon.major.integerValue
                               minor:beacon.minor.integerValue];

    NSDictionary *beaconData = self.estimoteBeaconData[key];
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.recordDate];
    interval = roundToTwo(interval);
    NSNumber *txPowerLevel = beaconData[kTxPower];
    
    NSString *uuid = beacon.proximityUUID.UUIDString;
    NSString *major = [NSString stringWithFormat:@"%d", beacon.major.intValue];
    NSString *minor = [NSString stringWithFormat:@"%d", beacon.minor.intValue];
    NSString *colour = beaconData[kColourString];
    NSString *time = [NSString stringWithFormat:@"%f", interval];
    NSString *proximity = [NSString stringWithFormat:@"%d", beacon.proximity];
    NSString *rssi = [NSString stringWithFormat:@"%d", beacon.rssi];
    NSString *accuracy = [NSString stringWithFormat:@"%f", roundToTwo(beacon.distance.floatValue)];
    NSString *distance = [NSString stringWithFormat:@"%@", self.distanceField.text];
    NSString *txPower = [NSString stringWithFormat:@"%d", txPowerLevel.intValue];
    
    NSString *row = [NSMutableString
                     stringWithFormat:@"%@, %@, %@, %@, %@, %@, %@, %@, %@, %@\n",
                     uuid,
                     major,
                     minor,
                     colour,
                     time,
                     proximity,
                     rssi,
                     accuracy,
                     distance,
                     txPower
                     ];
    
    [self.recordedData appendString:row];
}

float roundToTwo(float num)
{
    return round(100 * num) / 100;
}

#pragma mark Target Actions

- (void)didPressRightBarButtonItem:(UIBarButtonItem *)sender
{
    if ([sender.title isEqualToString:@"Done"])
    {
        [self textFieldShouldReturn:self.focussedField];
        self.isRecording = self.isRecording;
    }
    else
        self.isRecording = !self.isRecording;
}

- (void)timerInterval:(id)sender
{
    NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self.recordDate];
    
    self.elapsedTimeField.text = [NSString stringWithFormat:@"%d sec", (int)interval];
}


- (IBAction)syncTxPower:(id)sender
{
    [self.estBeaconManager stopRangingBeaconsInRegion:self.region];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Syncing TxPower";
    
    self.beaconsForSync = [NSMutableArray arrayWithArray:self.estBeacons];
    
    
    ESTBeacon *beacon = [self.beaconsForSync lastObject];
    
    beacon.delegate = self;
    [beacon connectToBeacon];
}

// FIXME: Files aren't yet being deleted.
- (IBAction)deleteFiles:(id)sender
{
    [[[UIActionSheet alloc] initWithTitle:@"Delete Files"
                                delegate:self
                       cancelButtonTitle:@"Cancel"
                  destructiveButtonTitle:@"Delete"
                       otherButtonTitles:nil]
     showFromToolbar:self.navigationController.toolbar];
}

#pragma mark - ESTBeaconManagerDelegate

-(void)beaconManager:(ESTBeaconManager *)manager
     didRangeBeacons:(NSArray *)beacons
            inRegion:(ESTBeaconRegion *)region
{
    [self.estBeacons removeAllObjects];
    [self.estBeacons addObjectsFromArray:beacons];
    
    if (self.isRecording)
        [self logData];
    
    [self.tableView reloadData];
}

#pragma mark ESTBeaconDelegate

- (void)beaconConnectionDidSucceeded:(ESTBeacon *)beacon
{
    NSString *key = [self keyForUUID:beacon.proximityUUID.UUIDString
                               major:beacon.major.integerValue
                               minor:beacon.minor.integerValue
                     ];
    NSMutableDictionary *beaconData = self.estimoteBeaconData[key];
    
    [beacon readBeaconPowerWithCompletion:^(ESTBeaconPower value, NSError *error)
     {
         NSNumber *powerLevel = [BeaconConfigViewController numberForBeaconPower:value];
         beaconData[kTxPower] = powerLevel;
         
         DLog(@"Did Connect to %@ beacon. TxPower: %d",
              beaconData[kColourString],
              beacon.power.intValue);
         
         [beacon disconnectBeacon];
     }];
}

- (void)beaconDidDisconnect:(ESTBeacon *)beacon withError:(NSError *)error
{
    NSString *key = [self keyForUUID:beacon.proximityUUID.UUIDString
                               major:beacon.major.integerValue
                               minor:beacon.minor.integerValue
                     ];
    NSMutableDictionary *beaconData = self.estimoteBeaconData[key];
    
    DLog(@"Did disconnect from %@ Beacon. TxPower: %@",
         beaconData[kColourString],
         beaconData[kTxPower]
         );
    
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    hud.labelText = [NSString
         stringWithFormat:@"%@ Beacon synced",
        [beaconData[kColourString] uppercaseString]
    ];
    
    [self.beaconsForSync removeLastObject];
    
    if (self.beaconsForSync.count != 0)
    {
        ESTBeacon *beacon = [self.beaconsForSync lastObject];
        
        beacon.delegate = self;
        [beacon connectToBeacon];
        
    }
    else
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.estBeaconManager startRangingBeaconsInRegion:self.region];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet
clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
        [self deleteAllFiles];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    self.isRecording = self.isRecording;
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (self.isRecording)
        return NO;
    
    self.navigationItem.rightBarButtonItem = [self barButtonItemForStyle:0];
    self.focussedField = textField;
    
    return YES;
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
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
    NSString *beaconMeasuredPower = nil;
    NSString *beaconTxPower = nil;
    NSString *beaconRSSI = nil;
    NSString *beaconAccuracy = nil;
    
    //ESTBeacon
    ESTBeacon *beacon = beacons[indexPath.row];
    
    NSDictionary *beaconData = self.estimoteBeaconData[
                           [self keyForUUID:beacon.proximityUUID.UUIDString
                                      major:beacon.major.integerValue
                                      minor:beacon.minor.integerValue]
                           ];
    
    beaconText = [NSString stringWithFormat:@"%@",
                  beaconData ? beaconData[kColourString] : @"Beacon"];
    beaconMeasuredPower = [NSString stringWithFormat:@"%d",
                   beacon.measuredPower.intValue];
    beaconTxPower = [NSString stringWithFormat:@"%@",
                     beaconData[kTxPower]];
    beaconRSSI = [NSString stringWithFormat:@"%ld",
                  (long)beacon.rssi];
    beaconAccuracy = [NSString stringWithFormat:@"%f",
                      beacon.distance.floatValue];
    
    cell.textLabel.text = beaconText;
    
    cell.detailTextLabel.text =
    [NSString stringWithFormat:@"MPx: %@, TxPower: %@, RSSI: %@, Acc: %@",
     beaconMeasuredPower,
     beaconTxPower,
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



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    BeaconConfigViewController *beaconConfigViewController = [[BeaconConfigViewController alloc] initWithNibName:@"BeaconConfigViewController" bundle:nil];
    
    // Pass the selected object to the new view controller.
    beaconConfigViewController.beacon = self.estBeacons[indexPath.row];
    
    // Push the view controller.
    [self.navigationController pushViewController:beaconConfigViewController animated:YES];
}

@end
