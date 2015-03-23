//
//  AppDelegate.h
//  VoiceAppTest_v04
//
//  Created by Richard Lorenzen on 3/22/15.
//  Copyright (c) 2015 Richard Lorenzen. All rights reserved.
//

@import UIKit;
@import CoreLocation;

@class HomeVoxNotificationRegion;

@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;

// Register a new notification region with the system
-(void)addNotificationRegion:(HomeVoxNotificationRegion*)newRegion;

// Retrieve a notification region by index
-(HomeVoxNotificationRegion*)notificationRegionAtIndex:(NSUInteger)index;

// Retrieve the total count of registered regions
-(NSInteger)notificationRegionCount;

// Remove a notification region
-(void)removeNotificationRegion:(HomeVoxNotificationRegion*)region;

// Remove a notification region by index
-(void)removeNotificationRegionAtIndex:(NSUInteger)index;


// -- Persistence --

// These methods are used to save and load notification regions from disk so that the App can keep
// track of the user's notification settings.

// Save all notification regions
-(void)saveNotificationRegions;

// Load notification regions
-(void)loadNotificationRegions;


@end

