//
//  AveragerTests.m
//  iBeaconExperiments
//
//  Created by Brenton Crowley on 16/06/2014.
//  Copyright (c) 2014 DiUS. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AveragerViewController.h"
#import "AveragerViewController+Tests.h"

@interface AveragerTests : XCTestCase

@property (nonatomic) AveragerViewController *vc;

@end

@implementation AveragerTests

- (void)setUp
{
    [super setUp];
    
    self.vc = [[AveragerViewController alloc] init];
    
}

- (void)tearDown
{
    self.vc = nil;
    [super tearDown];
}

- (void)testModeForBeaconDictIsUnknown
{
    NSDictionary *beaconDict = @{kProximity: @[
                                [NSNumber numberWithInt:CLProximityUnknown],
                                [NSNumber numberWithInt:CLProximityUnknown],
                                [NSNumber numberWithInt:CLProximityFar],
                                [NSNumber numberWithInt:CLProximityNear],
                                [NSNumber numberWithInt:CLProximityNear]
                                ]};
    
    int proximity = [self.vc modeProximityForBeaconDict:beaconDict];
    
    XCTAssertTrue(proximity == CLProximityUnknown,
                  @"proximity: %ld should equal the most occuring value in\
                  beaconDict, but does not: %u",
                  (long)CLProximityUnknown,
                  proximity);
}

- (void)testModeForBeaconDictIsNotUnknown
{
    NSDictionary *beaconDict = @{kProximity: @[
                                 [NSNumber numberWithInt:CLProximityUnknown],
                                 [NSNumber numberWithInt:CLProximityFar],
                                 [NSNumber numberWithInt:CLProximityNear],
                                 [NSNumber numberWithInt:CLProximityNear],
                                 [NSNumber numberWithInt:CLProximityNear]
                                         ]};
    int proximity = [self.vc modeProximityForBeaconDict:beaconDict];
    
    XCTAssertFalse(proximity == CLProximityUnknown,
                  @"proximity: %ld should equal the most occuring value in\
                  beaconDict, but does not: %d",
                  (long)CLProximityUnknown,
                  proximity);
}

@end
