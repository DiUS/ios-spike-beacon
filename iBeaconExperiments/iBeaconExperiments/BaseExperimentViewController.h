//
//  BaseExperimentViewController.h
//  iBeaconExperiments
//
//  Created by Brenton Crowley on 12/06/2014.
//  Copyright (c) 2014 DiUS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseExperimentViewController : UIViewController <CLLocationManagerDelegate>

extern NSString *kUUID;
extern NSString *kMajor;
extern NSString *kMinor;
extern NSString *kGreen;
extern NSString *kPurple;
extern NSString *kBlue;

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSDictionary *estimoteBeaconData;

- (NSUUID *)genericUUID;
- (void)registerBeaconRegionWithUUID:(NSUUID *)proximityUUID
                       andIdentifier:(NSString*)identifier;
- (void)deregisterBeaconRegionByIdentifier:(NSString*)identifier;

@end
