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
#import "BeaconConfigViewController.h"

@interface RecordDataViewController () <ESTBeaconManagerDelegate>

@property (nonatomic) ESTBeaconManager *estBeaconManager;
@property (nonatomic) NSArray *sections;
@property (nonatomic) NSMutableArray *estBeacons;
@property (nonatomic) BOOL isRecording;
@property (nonatomic) NSTimer *recordingTimer;
@property (nonatomic, weak) UITextField *focussedField;

@end

@implementation RecordDataViewController

#define DEFAULT_INTERVAL 1.0

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableHeaderView = self.header;
    
    self.estBeaconManager = [[ESTBeaconManager alloc] init];
    self.estBeaconManager.delegate = self;
    
    // create sample region object (you can additionaly pass major / minor values)
    ESTBeaconRegion* region = [[ESTBeaconRegion alloc]
                               initWithProximityUUID:[self genericUUID]
                               identifier:@"sdkBeacons"];
    
    // start looking for estimtoe beacons in region
    // when beacon ranged beaconManager:didRangeBeacons:inRegion: invoked
    [self.estBeaconManager startRangingBeaconsInRegion:region];
    
    self.isRecording = NO;
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
    }
    else
    {
        buttonItem = [self barButtonItemForStyle:UIBarButtonSystemItemSave];
    }
    
    self.navigationItem.rightBarButtonItem = buttonItem;
    
}

- (void)startRecording
{
    double interval = [self.intervalField.text doubleValue];
    
    if (interval == 0)
        interval = DEFAULT_INTERVAL;
    
    self.recordingTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                              target:self
                                            selector:@selector(timerInterval:)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)stopRecording
{
    if (self.recordingTimer)
        [self.recordingTimer invalidate];
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
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
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
    beaconMeasuredPower = [NSString stringWithFormat:@"%f",
                   beacon.measuredPower.floatValue];
    beaconTxPower = @"?";
    beaconRSSI = [NSString stringWithFormat:@"%ld",
                  (long)beacon.rssi];
    beaconAccuracy = [NSString stringWithFormat:@"%f",
                      beacon.distance.floatValue];
    
    DLog(@"MeasuredPx: %@", beacon.measuredPower);
    
    
    
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
/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    BeaconConfigViewController *beaconConfigViewController = [[BeaconConfigViewController alloc] initWithNibName:@"BeaconConfigViewController" bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:beaconConfigViewController animated:YES];
}

@end
