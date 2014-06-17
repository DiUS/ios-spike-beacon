//
//  BeaconConfigViewController.m
//  iBeaconExperiments
//
//  Created by Lincoln Fitzsimons on 16/06/2014.
//  Copyright (c) 2014 DiUS. All rights reserved.
//

#import "BeaconConfigViewController.h"



@interface BeaconConfigViewController ()

// UI Properties
@property (strong, nonatomic) IBOutlet UILabel *stateLabel;
@property (strong, nonatomic) IBOutlet UILabel *uuidLabel;
@property (strong, nonatomic) IBOutlet UILabel *powerLabel;
@property (strong, nonatomic) IBOutlet UIStepper *powerStepper;
@property (strong, nonatomic) IBOutlet UIButton *updateButton;

@end

@implementation BeaconConfigViewController

+ (NSNumber *)numberForBeaconPower:(ESTBeaconPower)power {
    switch(power) {
        case ESTBeaconPowerLevel1: return [NSNumber numberWithInt:1]; break;
        case ESTBeaconPowerLevel2: return [NSNumber numberWithInt:2]; break;
        case ESTBeaconPowerLevel3: return [NSNumber numberWithInt:3]; break;
        case ESTBeaconPowerLevel4: return [NSNumber numberWithInt:4]; break;
        case ESTBeaconPowerLevel5: return [NSNumber numberWithInt:5]; break;
        case ESTBeaconPowerLevel6: return [NSNumber numberWithInt:6]; break;
        case ESTBeaconPowerLevel7: return [NSNumber numberWithInt:7]; break;
        case ESTBeaconPowerLevel8: return [NSNumber numberWithInt:8]; break;
        default:
            return nil; break;
    }
}


+ (ESTBeaconPower)beaconPowerForLevel:(NSNumber *)power {
    switch(power.intValue) {
        case 1: return ESTBeaconPowerLevel1; break;
        case 2: return ESTBeaconPowerLevel2; break;
        case 3: return ESTBeaconPowerLevel3; break;
        case 4: return ESTBeaconPowerLevel4; break;
        case 5: return ESTBeaconPowerLevel5; break;
        case 6: return ESTBeaconPowerLevel6; break;
        case 7: return ESTBeaconPowerLevel7; break;
        case 8: return ESTBeaconPowerLevel8; break;
        default:
            return 0; break;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Connect to beacon
    if(self.beacon) {
        self.beacon.delegate = self;
        self.stateLabel.text = @"Connecting..";
        [self.beacon connectToBeacon];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.beacon disconnectBeacon];
}


#pragma mark - ESTBeacon Delegate
- (void)beaconConnectionDidSucceeded:(ESTBeacon *)beacon
{
    // Update UI
    NSString *key = [self keyForUUID:beacon.proximityUUID.UUIDString
                               major:beacon.major.integerValue
                               minor:beacon.minor.integerValue];
    
    NSDictionary *beaconData = self.estimoteBeaconData[key];
    
    self.stateLabel.text = @"Connected";
    self.uuidLabel.text = [[self.beacon proximityUUID] UUIDString];
    self.uuidLabel.backgroundColor = beaconData[kUIColour];
    self.updateButton.enabled = YES;
    
    [self.beacon readBeaconPowerWithCompletion:^(ESTBeaconPower value, NSError *error)
    {
        NSNumber *powerLevel = [BeaconConfigViewController numberForBeaconPower:value];
        self.powerLabel.text = powerLevel.stringValue;
        self.powerStepper.value = powerLevel.doubleValue;
    }];
    
}

- (void)beaconConnectionDidFail:(ESTBeacon *)beacon withError:(NSError *)error
{
    // Show message and go back
    self.stateLabel.text = @"Disconnected";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Behaviour

-(IBAction)stepperChanged:(UIStepper *)sender
{
    self.powerLabel.text = [NSString stringWithFormat:@"%d", [[NSNumber numberWithDouble:self.powerStepper.value] intValue]];
}

-(IBAction)updateClicked:(UIButton *)sender
{
    NSNumber *powerLevel = [NSNumber numberWithInteger:self.powerLabel.text.integerValue];
    ESTBeaconPower power = [BeaconConfigViewController beaconPowerForLevel:powerLevel];
    self.stateLabel.text = @"Updating";
    [self.beacon writeBeaconPower: power withCompletion:^(ESTBeaconPower value, NSError *error) {
        self.stateLabel.text = @"Updated";
    }];
}

@end
