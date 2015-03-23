//
//  HomeVoxNotificationRegion.h
//  VoiceAppTest_v04
//
//  Created by Richard Lorenzen on 3/22/15.
//  Copyright (c) 2015 Richard Lorenzen. All rights reserved.
//

@import Foundation;
@import CoreLocation;

@interface HomeVoxNotificationRegion : NSObject

@property (strong, nonatomic) NSString* beaconUUID;         // UUID for beacon in this event
@property (strong, nonatomic) NSNumber* beaconMajor;        // Major ID of beacon in this event (optional)
@property (strong, nonatomic) NSNumber* beaconMinor;        // Minor ID of beacon in this event (optional)

@property (strong, nonatomic) NSString* helloMessage;       // Message to display when user enters the beacon region
@property (strong, nonatomic) NSString* goodbyeMessage;     // Message to display when user exits the beacon region

@property (assign, nonatomic) CLRegionState lastState;      // State of beacon as of last update

@property (assign, nonatomic) CLProximity lastProximity;            // Proximity of beacon as of last update
@property (assign, nonatomic) CLLocationAccuracy lastAccuracy;      // Accuracy of beacon as of last update
@property (assign, nonatomic) NSInteger lastRSSI;                   // Signal strength of beacon as of last update


@end
