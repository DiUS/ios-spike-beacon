//
//  BaseExperimentTests.m
//  iBeaconExperiments
//
//  Created by Brenton Crowley on 13/06/2014.
//  Copyright (c) 2014 DiUS. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BaseExperimentViewController.h"

@interface BaseExperimentTests : XCTestCase

@property BaseExperimentViewController *baseVC;
@property NSString *uuidString;
@property NSInteger major;
@property NSInteger minor;

@end

@implementation BaseExperimentTests

- (void)setUp
{
    [super setUp];
    
    self.baseVC = [[BaseExperimentViewController alloc] init];
    self.uuidString = [[self.baseVC genericUUID] UUIDString];
    self.major = 0;
    self.minor = 0;
    
}

- (void)tearDown
{
    
    self.baseVC = nil;
    
    [super tearDown];
}

- (void)testKeyForUUIDStringMajorMinor
{
    NSString *testKey = [NSString stringWithFormat:@"%@%u%u",
                         self.uuidString,
                         self.major,
                         self.minor];
    
    NSString *resultKey = [self.baseVC keyForUUID:self.uuidString
                                            major:self.major
                                            minor:self.minor];
    
    XCTAssertTrue([testKey isEqualToString:resultKey],
                  @"Test key: %@ should equal result gained from \
                  resultKey: %@, but it does not",
                  testKey,
                  resultKey);
}

@end
