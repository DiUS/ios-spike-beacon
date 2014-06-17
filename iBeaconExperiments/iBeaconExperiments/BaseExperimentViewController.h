//
//  BaseExperimentViewController.h
//  iBeaconExperiments
//
//  Created by Brenton Crowley on 12/06/2014.
//  Copyright (c) 2014 DiUS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseExperimentViewController : UIViewController <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) NSMutableDictionary *estimoteBeaconData;

- (NSUUID *)genericUUID;
- (void)registerBeaconRegionWithUUID:(NSUUID *)proximityUUID
                       andIdentifier:(NSString*)identifier;
- (void)deregisterBeaconRegionByIdentifier:(NSString*)identifier;
- (NSString *)keyForUUID:(NSString *)uuid
                   major:(NSInteger)major
                   minor:(NSInteger)minor;
- (NSString *)proximityStringForIndex:(NSInteger)index;
- (void)writeCSVString:(NSString *)csvString
           forFilename:(NSString *)filename;
- (NSArray *)filesInDocumentsFolder;
- (void)deleteAllFiles;

@end
