//
//  HomeVoxNotificationRegion.m
//  VoiceAppTest_v04
//
//  Created by Richard Lorenzen on 3/22/15.
//  Copyright (c) 2015 Richard Lorenzen. All rights reserved.
//

#import "HomeVoxNotificationRegion.h"


@implementation HomeVoxNotificationRegion

-(id)init
{
    if (self = [super init])
    {
        _lastState = CLRegionStateUnknown;
        _lastProximity = CLProximityUnknown;
        _lastRSSI = 0;
    }
    return self;
}

-(id)initWithCoder:(NSCoder*)coder
{
    if (self = [self init])
    {
        // Very simple - read our values from the coder
        _beaconUUID = [coder decodeObjectForKey:@"beaconUUID"];
        _beaconMajor = [coder decodeObjectForKey:@"beaconMajor"];
        _beaconMinor = [coder decodeObjectForKey:@"beaconMinor"];
        _helloMessage = [coder decodeObjectForKey:@"helloMessage"];
        _goodbyeMessage = [coder decodeObjectForKey:@"goodbyeMessage"];
        _lastState = [[coder decodeObjectForKey:@"lastState"] integerValue];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder*)coder
{
    // Very simple - just encode all of our data fields with the coder
    [coder encodeObject:_beaconUUID forKey:@"beaconUUID"];
    [coder encodeObject:_beaconMajor forKey:@"beaconMajor"];
    [coder encodeObject:_beaconMinor forKey:@"beaconMinor"];
    [coder encodeObject:_helloMessage forKey:@"helloMessage"];
    [coder encodeObject:_goodbyeMessage forKey:@"goodbyeMessage"];
    [coder encodeObject:[NSNumber numberWithInteger:_lastState] forKey:@"lastState"];
}


@end
